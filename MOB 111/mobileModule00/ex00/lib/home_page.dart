import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.text});
  final String text;

// Custom methods
  static void printToConsole(String message)
  {
    debugPrint(message);
  }

  Text displayText(String text, Color color, double size)
  {
    return Text(text, style: TextStyle(fontSize: size, color: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(color: const Color.fromARGB(255, 192, 173, 9), borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.all(5),
              child: displayText(text, Colors.white, 20)
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => HomePage.printToConsole("Button pressed"),
              child: displayText("Click me", const Color.fromARGB(255, 192, 173, 9), 15),
            ),
          ],
        ),
      ),
    );
  }
}