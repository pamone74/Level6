import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color kCalculatorPrimaryColor = Color(0xFF5f87af);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State class for [HomePage] that manages the calculator UI and button logic.
class _HomePageState extends State<HomePage> {
  final List<String> buttons = [
    '7','8','9','C','AC',
    '4','5','6','+','-',
    '1','2','3','*','/',
    '0','.','00','=',
  ];

bool isOperator(String buttonKey){
  if(buttonKey == '+' || buttonKey == '-' || buttonKey == '*' || buttonKey == '/' || buttonKey == '=' ){
    return true;
  }
  return false;
}

bool isNumber(String buttonKey){
  if(buttonKey == '0' || buttonKey == '1' || buttonKey == '2' || buttonKey == '3' || buttonKey == '4' || buttonKey == '5' || buttonKey == '6' || buttonKey == '7' || buttonKey == '8' || buttonKey == '9' || buttonKey == '.' || buttonKey == '00'){
    return true;
  }
  return false;
}

bool isClear(String buttonKey){
  if(buttonKey == 'C' || buttonKey == 'AC'){
    return true;
  }
  return false;
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
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: orientation == Orientation.portrait ? 1 : 5,
              ),
              itemBuilder: (BuildContext context, int index) {
                return ElevatedButton(
                  onPressed: () {
                    print( 'Button pressed: ${buttons[index]}' );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kCalculatorPrimaryColor,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                      side: BorderSide(
                        // color: kCalculatorPrimaryColor,
                        // width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                  ),
                  child: Text(buttons[index], style: TextStyle(color: isOperator(buttons[index]) ? Colors.white : isNumber(buttons[index]) ? Colors.black : Colors.red),)
                );
              },
              itemCount: buttons.length,
            ),
          ],
        ),
      ),
    );
  }
}
