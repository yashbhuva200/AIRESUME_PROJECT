import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // TextEditingController is used to control the text being edited in a text field.
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();

  // Firestore instance and user ID
  final _firestore = FirebaseFirestore.instance;
  final _userId = FirebaseAuth.instance.currentUser!.uid;

  bool _isLoading = true; // State to track if data is being loaded

  @override
  void initState() {
    super.initState();
    // Call the function to fetch existing profile data.
    _fetchUserProfile();
  }

  // Function to fetch the user's profile data from Firestore
  void _fetchUserProfile() {
    // The profile data will be stored in a collection named 'profile' within
    // a user's unique document, e.g., 'users/{userId}/profile/info'.
    final docRef = _firestore.collection('users').doc(_userId).collection('profile').doc('info');

    // Use a real-time listener (onSnapshot) to automatically update the form
    // if the data changes elsewhere.
    docRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          // Populate the text controllers with the fetched data
          setState(() {
            _nameController.text = data['name'] ?? '';
            _emailController.text = data['email'] ?? '';
            _phoneController.text = data['phone'] ?? '';
            _linkedinController.text = data['linkedin'] ?? '';
            _githubController.text = data['github'] ?? '';
            _isLoading = false;
          });
        }
      } else {
        // If no profile exists, stop loading state.
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  // Function to save the user's profile data to Firestore
  Future<void> _saveProfile() async {
    // Validate the form
    if (_formKey.currentState!.validate()) {
      // Show a loading indicator (optional but good practice)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saving profile...')),
      );

      // Create a map of the profile data
      final profileData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'linkedin': _linkedinController.text,
        'github': _githubController.text,
      };

      try {
        // Get a reference to the user's profile document.
        final docRef = _firestore.collection('users').doc(_userId).collection('profile').doc('info');

        // Use set() with merge: true to update the document.
        // If the document doesn't exist, it will be created.
        await docRef.set(profileData, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while data is being fetched
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextFormField('Full Name', _nameController, isRequired: true),
              _buildTextFormField('Email Address', _emailController, isRequired: true, keyboardType: TextInputType.emailAddress),
              _buildTextFormField('Phone Number', _phoneController, keyboardType: TextInputType.phone),
              _buildTextFormField('LinkedIn Profile URL', _linkedinController),
              _buildTextFormField('GitHub Profile URL', _githubController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Save Profile', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // A helper method to create a consistent TextFormField.
  Widget _buildTextFormField(String labelText, TextEditingController controller, {bool isRequired = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Please enter your $labelText';
          }
          return null;
        },
      ),
    );
  }
}
