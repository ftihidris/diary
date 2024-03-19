import 'package:flutter/material.dart';

class DiaryCard extends StatelessWidget {
  const DiaryCard({
    required this.diary,
    required this.index,
    required this.isDarkMode,
    required this.gifImagePath,
    required this.selectedDiaries,
    required this.onShowForm,
    required this.onDeleteDiary,
    required this.onToggleDeleteDiary,
  });

  final Map<String, dynamic> diary;
  final int index;
  final bool isDarkMode;
  final String gifImagePath;
  final List<bool> selectedDiaries;
  final void Function(int?) onShowForm;
  final void Function(int) onDeleteDiary;
  final void Function(int) onToggleDeleteDiary;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isDarkMode ? Colors.white12.withOpacity(0.1) : Colors.white.withOpacity(0.89),
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          child: Image.asset(gifImagePath),
          backgroundColor: isDarkMode ? Colors.white12.withOpacity(0.2) : Colors.grey[200],
        ),
        title: Text(
          diary['feeling'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              diary['description'],
              style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(height: 10),
            Text(
              diary['createdAt'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white24 : Colors.black26,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: isDarkMode ? Colors.white24 : Colors.black26),
              onPressed: () => onShowForm(diary['id']),
            ),
            selectedDiaries[index]
                ? IconButton(
                    icon: Icon(Icons.check_box, color: isDarkMode ? Colors.white24 : Colors.black26),
                    onPressed: () => onToggleDeleteDiary(index),
                  )
                : IconButton(
                    icon: Icon(Icons.delete, color: isDarkMode ? Colors.white24 : Colors.black26),
                    onPressed: () => onToggleDeleteDiary(index),
                  ),
          ],
        ),
        onTap: () => onToggleDeleteDiary(index),
      ),
    );
  }
}
