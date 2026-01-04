import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.text});
  String text;

// Custom method
  static void printToConsole(String message)
  {
    debugPrint(message);
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Text displayText(String text, Color color, double size)
  {
    return Text(text, style: TextStyle(fontSize: size, color: color));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(color: const Color.fromARGB(255, 192, 173, 9), borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.all(5),
              child: displayText(widget.text, Colors.white, 20)
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (widget.text == "Hello World") {
                    widget.text = "A simple text";
                  } else {
                    widget.text = "Hello World";
                  }
                });
              },
              child: displayText("Click me", const Color.fromARGB(255, 192, 173, 9), 15),
            ),
          ],
        ),
      ),
    );
  }
}