import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//why previous one stateless widget and this one is stateful widget
//because we need to store the state of the profile
//and we need to update the state of the profile
//and we need to save the profile to the database
//and we need to fetch the profile from the database
//and we need to update the profile in the database
//and we need to delete the profile from the database
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  //what is FormState?
  final _formKey = GlobalKey<FormState>();
  //what is TextEditingController?
  //it is used to store the text of the input field
  //and it is used to update the text of the input field
  //and it is used to save the text of the input field
  //and it is used to fetch the text of the input field
  //and it is used to update the text of the input field
  //and it is used to delete the text of the input field
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();
  //_firestore is used to store and fetch the data in the database
  final _firestore = FirebaseFirestore.instance;
  //_userId is used to store the id of the user
  final _userId = FirebaseAuth.instance.currentUser!.uid;
  //_isLoading is used to store the state of the loading
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // Fetch existing profile data OR use defaults from FirebaseAuth
  void _fetchUserProfile() {
    final user = FirebaseAuth.instance.currentUser;

    // Prefill with FirebaseAuth values
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
    }
    //_docRef is used to store the reference of the profile in the database
    final docRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('profile')
        .doc('info');
    //_docRef.snapshots().listen is used to listen to the changes in the profile in the database
    docRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          setState(() {
            _nameController.text = data['name'] ?? user?.displayName ?? '';
            _emailController.text = data['email'] ?? user?.email ?? '';
            _phoneController.text = data['phone'] ?? '';
            _linkedinController.text = data['linkedin'] ?? '';
            _githubController.text = data['github'] ?? '';
            _isLoading = false;
          });
        }
      } else {
        //_isLoading is set to false when the profile is not found in the database
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  // Save profile to Firestore
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saving profile...')));
      //_profileData is used to store the data of the profile
      final profileData = {
        'name': _nameController.text,
        'email': _emailController.text, // stays same as login
        'phone': _phoneController.text,
        'linkedin': _linkedinController.text,
        'github': _githubController.text,
      };

      try {
        final docRef = _firestore
            .collection('users')
            .doc(_userId)
            .collection('profile')
            .doc('info');

        await docRef.set(profileData, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save profile: $e')));
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextFormField(
                'Full Name',
                _nameController,
                isRequired: true,
              ),
              _buildTextFormField(
                'Email Address',
                _emailController,
                isRequired: true,
                readOnly: true,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextFormField(
                'Phone Number',
                _phoneController,
                keyboardType: TextInputType.phone,
              ),
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
                child: const Text(
                  'Save Profile',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable TextFormField builder
  Widget _buildTextFormField(
    String labelText,
    TextEditingController controller, {
    bool isRequired = false,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
