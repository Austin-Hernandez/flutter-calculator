import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String input = '';
  String result = '';
  bool lastInputWasEqual = false;
  bool lastInputWasOperator = false;

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        input = '';
        result = '';
        lastInputWasEqual = false;
        lastInputWasOperator = false;
      } else if (value == '⌫') {
        if (input.isNotEmpty) {
          input = input.substring(0, input.length - 1);
        }
      } else if (value == '=') {
        if (input.isEmpty || lastInputWasOperator) {
          input = input.isNotEmpty ? input.substring(0, input.length - 1) : input;
        }
        try {
          Expression exp = Expression.parse(input);
          final evaluator = const ExpressionEvaluator();
          var eval = evaluator.eval(exp, {});
          result = (eval == double.infinity || eval == double.negativeInfinity) ? 'Undefined' : eval.toString();
          input += '=' + result;
          lastInputWasEqual = true;
        } catch (e) {
          result = 'Error';
        }
      } else if ('+-*/'.contains(value)) {
        if (result == 'Undefined' || result == 'Error') {
          return; // Ignore operator input after error
        }
        if (input.isEmpty) {
          return; // Ignore operator if input is empty
        }
        if (lastInputWasEqual) {
          input = result + value;
        } else if (lastInputWasOperator) {
          input = input.substring(0, input.length - 1) + value;
        } else {
          input += value;
        }
        lastInputWasEqual = false;
        lastInputWasOperator = true;
      } else if (value == '()') {
        if (lastInputWasEqual) {
          input = '(';
          result = '';
        } else if (input.isEmpty || '+-*/('.contains(input[input.length - 1])) {
          input += '(';
        } else {
          input += ')';
        }
        lastInputWasEqual = false;
        lastInputWasOperator = false;
      } else {
        if (lastInputWasEqual) {
          input = value;
          result = '';
        } else {
          input += value;
        }
        lastInputWasEqual = false;
        lastInputWasOperator = false;
      }
    });
  }

  Widget _buildButton(String value, {double flex = 1, Color? color, Color textColor = Colors.white}) {
    return Expanded(
      flex: flex.toInt(),
      child: ElevatedButton(
        onPressed: () => _onButtonPressed(value),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(20),
          backgroundColor: color ?? Colors.grey[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          value,
          style: TextStyle(fontSize: 24, color: textColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(input, style: TextStyle(fontSize: 32, color: Colors.white)),
                SizedBox(height: 10),
                Text(result, style: TextStyle(fontSize: 48, color: Colors.green)),
              ],
            ),
          ),
          Divider(color: Colors.white),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton('C', color: Colors.red, textColor: Colors.white),
              _buildButton('⌫'),
              _buildButton('()'),
              _buildButton('/', color: Colors.white, textColor: Colors.black),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['7', '8', '9', '*'].map((value) => _buildButton(value, textColor: Colors.black, color: Colors.white)).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['4', '5', '6', '-'].map((value) => _buildButton(value, textColor: Colors.black, color: Colors.white)).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['1', '2', '3', '+'].map((value) => _buildButton(value, textColor: Colors.black, color: Colors.white)).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton('0', flex: 3, textColor: Colors.black, color: Colors.white),
              _buildButton('=', color: Colors.blue, textColor: Colors.white),
            ],
          ),
        ],
      ),
    );
  }
}
