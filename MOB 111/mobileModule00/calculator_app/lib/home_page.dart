import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';

const Color kCalculatorPrimaryColor = Color(0xFF5f87af);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController inputController = TextEditingController();
  final TextEditingController resultController = TextEditingController();

  final List<String> buttons = [
    '7', '8', '9', 'C', 'AC',
    '4', '5', '6', '+', '-',
    '1', '2', '3', '*', '/',
    '0', '.', '00', '='
  ];

  @override
  void initState() {
    super.initState();
    inputController.text = '';
    resultController.text = '';
  }

  @override
  void dispose() {
    inputController.dispose();
    resultController.dispose();
    super.dispose();
  }

  bool isOperator(String key) {
    return ['+', '-', '*', '/'].contains(key);
  }

  bool dotExists(String expression) {
    if (expression.isEmpty) return false;

    final operators = ['+', '-', '*', '/'];
    int lastOperatorIndex = -1;

    for (var op in operators) {
      int index = expression.lastIndexOf(op);
      if (index > lastOperatorIndex) {
        lastOperatorIndex = index;
      }
    }

    String currentNumber = expression.substring(lastOperatorIndex + 1);
    return currentNumber.contains('.');
  }

  String calculateResult(String expression) {
    if (expression.isEmpty) return '';

    try {
      String sanitized = expression.replaceAll(' ', '');
      Parser p = Parser();
      Expression exp = p.parse(sanitized);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      if (eval.isNaN || eval.isInfinite) return 'Error';
      return eval.toString();
    } catch (e) {
      return 'Error';
    }
  }

 void handleButtonPress(String button) {
  String input = inputController.text;

  setState(() {
    if (button == 'AC') {
      inputController.clear();
      resultController.clear();
    } else if (button == 'C') {
      if (input.isNotEmpty) {
        inputController.text = input.substring(0, input.length - 1);
      }
    } else if (button == '=') {
      resultController.text = calculateResult(input);
    } else if (isOperator(button)) {
      if (input.isEmpty) {
        // Allow starting with minus for negative number
        if (button == '-') {
          inputController.text += button;
        }
        return;
      }

      String lastChar = input.characters.last;

      if (isOperator(lastChar)) {
        // Allow sequences like "5*-3" for negative numbers
        if (button == '-' && lastChar != '-') {
          inputController.text += button;
        } else {
          // Replace last operator
          inputController.text = input.substring(0, input.length - 1) + button;
        }
      } else {
        inputController.text += button;
      }
    } else if (button == '.') {
      if (!dotExists(input)) {
        inputController.text += button;
      }
    } else {
      inputController.text += button;
    }
  });
}


  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: kCalculatorPrimaryColor,
        title: const Text('Calculator', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        color: kCalculatorPrimaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              color: const Color.fromARGB(255, 83, 84, 85),
              child: Column(
                children: [
                  TextField(
                    controller: inputController,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      hintText: '0',
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.none,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextField(
                    controller: resultController,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      hintText: '0',
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.none,
                    textAlign: TextAlign.right,
                    readOnly: true,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: orientation == Orientation.portrait ? 250 : 0),
                ],
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              itemCount: buttons.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: orientation == Orientation.portrait ? 1 : 5,
              ),
              itemBuilder: (context, index) {
                final button = buttons[index];
                final isOp = isOperator(button);
                final isNumber = RegExp(r'^\d+$').hasMatch(button) || button == '.' || button == '00';

                return ElevatedButton(
                  onPressed: () => handleButtonPress(button),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kCalculatorPrimaryColor,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                      side: BorderSide(style: BorderStyle.none),
                    ),
                  ),
                  child: Text(
                    button,
                    style: TextStyle(
                      color: isOp ? Colors.white : isNumber ? Colors.black : Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
