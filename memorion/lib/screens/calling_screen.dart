import 'package:flutter/material.dart';
import 'package:memorion/const/colors.dart';

class CallingScreen extends StatefulWidget {
  const CallingScreen({super.key});

  @override
  State<CallingScreen> createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.white, AppColors.main], begin: Alignment.topCenter, end: Alignment.bottomCenter)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 160,),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color.fromARGB(125, 255, 255, 255)
              ),
              child: Column(
                children: [
                  //logo
                  Text("따듯한전화", style: TextStyle(color: AppColors.main, fontSize: 40, fontWeight: FontWeight.bold),)
                ],
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(80, 255, 255, 255),
                      borderRadius: BorderRadius.circular(100)
                    ),
                    child: Container(
                      padding: EdgeInsets.all(20), decoration: BoxDecoration(
                        color: Colors.green, 
                        borderRadius: BorderRadius.circular(100)
                      ), 
                      child: Icon(Icons.call_rounded, 
                      color: AppColors.white, size: 32,)
                    ),
                  ),
                  
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(80, 255, 255, 255),
                      borderRadius: BorderRadius.circular(100)
                    ),
                    child: Container(
                      padding: EdgeInsets.all(20), decoration: BoxDecoration(
                        color: Colors.redAccent, 
                        borderRadius: BorderRadius.circular(100)
                      ), 
                      child: Icon(Icons.call_end_rounded, 
                      color: AppColors.white, size: 32,)
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}