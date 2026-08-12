import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/main.dart';

/// Wraps a project list item so that, in debug builds only, swiping it
/// left-to-right asks for confirmation and then permanently deletes the
/// project via `delete-project/:id`. Renders [child] unchanged in release
/// builds, so this is never a way for real users to delete data.
class DebugDeleteProjectTile extends StatelessWidget {
  final String projectId;
  final Widget child;

  /// Called after a successful delete, on top of the controller already
  /// removing the project from myProjects/assignedProjects/teamProjects —
  /// use this to also drop it from a screen-local list (e.g. search/filter
  /// results) that isn't backed by those reactive lists.
  final VoidCallback? onDeleted;

  const DebugDeleteProjectTile({
    super.key,
    required this.projectId,
    required this.child,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return child;

    return Dismissible(
      key: ValueKey('debug-delete-$projectId'),
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
            title: const Text('Delete project?'),
            content: const Text(
                '[DEBUG] This permanently deletes the project from the '
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

        final deleted = await projectsController.deleteProject(projectId);
        if (deleted) onDeleted?.call();
        return deleted;
      },
      child: child,
    );
  }
}
