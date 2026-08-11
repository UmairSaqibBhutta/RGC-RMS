import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/widgets/custom_button.dart';
import 'package:leadmanagementsystem/widgets/custom_snackbar.dart';
import 'package:leadmanagementsystem/widgets/custom_text_field.dart';

/// Reusable "add a follow up" card: a text note with an optional photo,
/// used on both the project details and visit report details screens.
class FollowUpForm extends StatefulWidget {
  final Future<bool> Function(String text, File? image) onSubmit;
  final bool isLoading;

  const FollowUpForm({
    super.key,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  State<FollowUpForm> createState() => _FollowUpFormState();
}

class _FollowUpFormState extends State<FollowUpForm> {
  final TextEditingController _textController = TextEditingController();
  File? _image;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _submit() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      CustomSnackbar.warning('Please enter a follow up note');
      return;
    }

    final success = await widget.onSubmit(text, _image);
    if (!mounted) return;
    if (success) {
      _textController.clear();
      setState(() => _image = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Follow Up', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _textController,
              hint: 'Write a follow up note...',
              maxLines: 3,
              allSidesPadding: 0,
            ),
            const SizedBox(height: 8),
            if (_image != null) ...[
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _image!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: InkWell(
                      onTap: () => setState(() => _image = null),
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                TextButton.icon(
                  onPressed: widget.isLoading ? null : _pickImage,
                  icon: Icon(_image == null
                      ? Icons.image_outlined
                      : Icons.image_outlined),
                  label: Text(_image == null ? 'Add Photo' : 'Change Photo'),
                ),
                const Spacer(),
                SizedBox(
                  width: 120,
                  child: CustomButton(
                    title: 'Submit',
                    fullWidth: false,
                    height: 40,
                    onTap: widget.isLoading ? null : _submit,
                    child: widget.isLoading
                        ? const AppLoader(
                            size: 18,
                            strokeWidth: 2,
                            color: Colors.white,
                            trackColor: Colors.white24,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
