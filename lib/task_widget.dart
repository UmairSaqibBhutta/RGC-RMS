import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leadmanagementsystem/models/tasks_model.dart';
import 'package:leadmanagementsystem/widgets/data_formatter.dart';

class TaskWidget extends StatelessWidget {
  final TaskData task;

  const TaskWidget({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return _buildTaskCard(task);
  }

  Widget _buildTaskCard(TaskData task) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 10),
                if (task.priority != null) _buildPriorityBadge(task.priority!),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 15,
              runSpacing: 8,
              children: [
                if (task.projectName != null)
                  _buildInfoIconWithText(CupertinoIcons.briefcase_fill,
                      task.projectName!, Colors.blue),
                if (task.taskDateTime != null)
                  _buildInfoIconWithText(
                      CupertinoIcons.calendar,
                      DateFormatter.formatDateTime(task.taskDateTime!),
                      Colors.green),
              ],
            ),
            const SizedBox(height: 8),
            if (task.status != null)
              _buildInfoIconWithText(CupertinoIcons.flag_fill, task.status!,
                  _getStatusColor(task.status!)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoIconWithText(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color badgeColor;
    switch (priority) {
      case 'High':
        badgeColor = Colors.red;
        break;
      case 'Medium':
        badgeColor = Colors.orange;
        break;
      case 'Low':
        badgeColor = Colors.green;
        break;
      default:
        badgeColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Progress':
        return Colors.orange;
      case 'Not Started':
        return Colors.grey;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}
