import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/controllers/task_controller.dart';

/// Wraps a task list item so that, in debug builds only, swiping it
/// left-to-right asks for confirmation and then permanently deletes the
/// task via `delete-task/:id`. Renders [child] unchanged in release
/// builds, so this is never a way for real users to delete data.
class DebugDeleteTaskTile extends StatelessWidget {
  final String taskId;
  final TaskController taskController;
  final Widget child;

  /// Called after a successful delete, on top of the controller already
  /// removing the task from filteredTasksList/assignedTasksList — use this
  /// to also drop it from a screen-local list (e.g. search/filter results)
  /// that isn't backed by those reactive lists.
  final VoidCallback? onDeleted;

  const DebugDeleteTaskTile({
    super.key,
    required this.taskId,
    required this.taskController,
    required this.child,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return child;

    return Dismissible(
      key: ValueKey('debug-delete-task-$taskId'),
      direction: DismissDirection.startToEnd,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Delete task?'),
            content: const Text(
                '[DEBUG] This permanently deletes the task from the '
                'server. This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Delete',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
          barrierDismissible: false,
        );

        if (confirmed != true) return false;

        final deleted = await taskController.deleteTask(taskId);
        if (deleted) onDeleted?.call();
        return deleted;
      },
      child: child,
    );
  }
}
