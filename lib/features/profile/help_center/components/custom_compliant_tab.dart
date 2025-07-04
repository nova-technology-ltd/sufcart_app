import 'package:flutter/material.dart';

class CustomCompliantTab extends StatelessWidget {
  final VoidCallback weekClicked;
  final VoidCallback monthClicked;
  final VoidCallback annuallyClicked;
  final bool isWeek;
  final bool isMonth;
  final bool isAnnually;
  const CustomCompliantTab({super.key, required this.weekClicked, required this.monthClicked, required this.annuallyClicked, required this.isWeek, required this.isMonth, required this.isAnnually});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(360)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: weekClicked,
                child: Container(
                  height: 47,
                  decoration: BoxDecoration(
                      color: isWeek ? Colors.white.withOpacity(0.7) : Colors.transparent,
                      borderRadius: BorderRadius.circular(360)
                  ),
                  child: Center(
                    child: Text("Weekly", style: TextStyle(
                        color: isWeek ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 13
                    ),),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5,),
            Expanded(
              child: GestureDetector(
                onTap: monthClicked,
                child: Container(
                  height: 47,
                  decoration: BoxDecoration(
                      color: isMonth ? Colors.white.withOpacity(0.7) : Colors.transparent,
                      borderRadius: BorderRadius.circular(360)
                  ),
                  child: Center(
                    child: Text("Monthly", style: TextStyle(
                        color: isMonth ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 13
                    ),),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5,),
            Expanded(
              child: GestureDetector(
                onTap: annuallyClicked,
                child: Container(
                  height: 47,
                  decoration: BoxDecoration(
                      color: isAnnually ? Colors.white.withOpacity(0.7) : Colors.transparent,
                      borderRadius: BorderRadius.circular(360)
                  ),
                  child: Center(
                    child: Text("Annually", style: TextStyle(
                        color: isAnnually ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 13
                    ),),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
