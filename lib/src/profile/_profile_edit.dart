import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class EditProfilePage extends StatefulWidget {
  final String documentId;
  final String name;
  final String email;
  final String profilePicUrl;

  const EditProfilePage({
    super.key,
    required this.documentId,
    required this.name,
    required this.email,
    required this.profilePicUrl,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _profilePicUrlController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _profilePicUrlController =
        TextEditingController(text: widget.profilePicUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _profilePicUrlController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.documentId)
          .update({
        'name': _nameController.text,
        'email': _emailController.text,
        'profilePicUrl': _profilePicUrlController.text,
      });

      Navigator.pop(context, true); // Pass true to indicate success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _profilePicUrlController,
                  decoration:
                      const InputDecoration(labelText: 'Profile Picture URL'),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                ),
                onPressed: _saveProfile,
                child: const Text('SAVE', style: TextStyle(fontSize: 18.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
