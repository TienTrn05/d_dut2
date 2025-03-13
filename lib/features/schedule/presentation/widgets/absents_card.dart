import 'package:flutter/material.dart';

class AbsentsCard extends StatelessWidget {
  final bool isTeacher;
  final List<String> absentDates;
  const AbsentsCard(
      {super.key, this.isTeacher = true, required this.absentDates});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 310),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Các buổi vắng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                Flexible(
                    child: ListView.builder(
                  shrinkWrap: true,
                  // physics: const BouncingScrollPhysics(),
                  itemCount: absentDates.length,
                  itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Center(
                        child: Text(
                          absentDates[index],
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ))
              ],
            ),
          )),
    );
  }
}
