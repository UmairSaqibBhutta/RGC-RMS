import 'package:flutter/material.dart';
import 'package:leadmanagementsystem/constants/constants.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  // Categories for notes
  final List<String> categories = ['Leaves', 'Projects', 'Tasks'];
  String selectedCategory = 'Leaves'; // Default category

  // Store notes based on category
  Map<String, List<String>> notes = {
    'Leaves': [],
    'Projects': [],
    'Tasks': [],
  };

  final TextEditingController noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notes",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade600,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _buildCategoryTabs(),
        ),
      ),
      body: _buildNotesList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteSheet,
        backgroundColor: appColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// Builds the tabs for category selection (Leaves, Projects, Tasks)
  Widget _buildCategoryTabs() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: categories.map((category) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: selectedCategory == category
                    ? Colors.teal.shade600
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selectedCategory == category
                      ? Colors.transparent
                      : Colors.teal.shade600,
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: selectedCategory == category
                      ? Colors.white
                      : Colors.teal.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Builds the list of notes based on selected category
  Widget _buildNotesList() {
    return notes[selectedCategory]!.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notes[selectedCategory]!.length,
            itemBuilder: (context, index) {
              return _buildNoteCard(index);
            },
          );
  }

  /// Builds the empty state message when no notes exist
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.note_alt_rounded,
            size: 100,
            color: Colors.teal.shade200,
          ),
          const SizedBox(height: 16),
          const Text(
            "No Notes Yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tap the + button to create your first note.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Builds a single note card with updated UI
  Widget _buildNoteCard(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 5,
      shadowColor: Colors.teal.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        title: Text(
          notes[selectedCategory]![index],
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: const Text(
          "Tap to view or edit",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red.shade400),
          onPressed: () {
            setState(() {
              notes[selectedCategory]!.removeAt(index);
            });
          },
        ),
        onTap: () {
          _showAddNoteSheet(
              note: notes[selectedCategory]![index], index: index);
        },
      ),
    );
  }

  /// Bottom Sheet for Adding or Editing a Note
  void _showAddNoteSheet({String? note, int? index}) {
    noteController.text = note ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Wrap(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    note != null ? "Edit Note" : "Add Note",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                maxLines: 5,
                minLines: 3,
                decoration: InputDecoration(
                  hintText: "Write your note here...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.teal),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.teal.shade600),
                  ),
                  filled: true,
                  fillColor: Colors.teal.shade50,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (noteController.text.isNotEmpty) {
                    setState(() {
                      if (note != null && index != null) {
                        // Edit existing note
                        notes[selectedCategory]![index] = noteController.text;
                      } else {
                        // Add new note
                        notes[selectedCategory]!.add(noteController.text);
                      }
                    });
                    noteController.clear();
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Center(
                  child: Text(
                    note != null ? "Update Note" : "Add Note",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
