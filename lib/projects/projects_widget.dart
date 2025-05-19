import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/project_model.dart';

class ProjectsWidget extends StatelessWidget {
  const ProjectsWidget({
    super.key,
    required this.project,
  });

  final ProjectData project;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: project.userId == loginStorage.getUserId(),
      // alignment: AlignmentDirectional(start, y),
      label: project.userId == loginStorage.getUserId()
          ? const Text("My Project")
          : const SizedBox.shrink(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.title ?? "",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                      ),
                    ),
                  ),
                  Icon(
                    Icons.star,
                    color: project.projectPriority == 'High'
                        ? Colors.red
                        : project.projectPriority == 'Medium'
                            ? Colors.orange
                            : Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Description
              Text(
                project.description ?? "",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              // Created Date and Priority
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.teal[800],
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Created: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(project.projectCreatedDate.toString()))}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // const SizedBox(width: 5),
                      Text(
                        'Priority: ${project.projectPriority}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: project.projectPriority == 'High'
                              ? Colors.red
                              : project.projectPriority == 'Medium'
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
