import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResumeFormScreen extends StatefulWidget {
  final String? resumeId;
  const ResumeFormScreen({super.key, this.resumeId});

  @override
  State<ResumeFormScreen> createState() => _ResumeFormScreenState();
}

class _ResumeFormScreenState extends State<ResumeFormScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Controllers for the main form fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _summaryController = TextEditingController();
  final _skillsController = TextEditingController();

  // Data models for dynamic forms
  List<Map<String, String>> _educationDetails = [];
  List<Map<String, String>> _experienceDetails = [];
  List<Map<String, String>> _projectDetails = [];

  Map<String, dynamic> _resumeData = {
    'contact': {},
    'education': [],
    'summary': '',
    'experience': [],
    'skills': [],
    'projects': [],
  };

  final _firestore = FirebaseFirestore.instance;
  final _userId = FirebaseAuth.instance.currentUser!.uid;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.resumeId != null) {
      _fetchResumeData(widget.resumeId!);
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Starting new, blank resume.');
    }
    _nameController.addListener(_updatePreview);
    _emailController.addListener(_updatePreview);
    _phoneController.addListener(_updatePreview);
    _summaryController.addListener(_updatePreview);
    _skillsController.addListener(_updatePreview);
  }

  void _updatePreview() {
    setState(() {
      _resumeData['contact']['name'] = _nameController.text;
      _resumeData['contact']['email'] = _emailController.text;
      _resumeData['contact']['phone'] = _phoneController.text;
      _resumeData['summary'] = _summaryController.text;
      _resumeData['skills'] = _skillsController.text.split(',').map((e) => e.trim()).toList();
    });
  }

  void _fetchResumeData(String resumeId) async {
    final docRef = _firestore.collection('users').doc(_userId).collection('resumes').doc(resumeId);
    try {
      final snapshot = await docRef.get();
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data();
        _resumeData = data!;
        _nameController.text = data['contact']['name'] ?? '';
        _emailController.text = data['contact']['email'] ?? '';
        _phoneController.text = data['contact']['phone'] ?? '';
        _summaryController.text = data['summary'] ?? '';
        _skillsController.text = (data['skills'] as List<dynamic>?)?.join(', ') ?? '';
        _educationDetails = (data['education'] as List<dynamic>?)?.cast<Map<String, String>>() ?? [];
        _experienceDetails = (data['experience'] as List<dynamic>?)?.cast<Map<String, String>>() ?? [];
        _projectDetails = (data['projects'] as List<dynamic>?)?.cast<Map<String, String>>() ?? [];
      } else {
        print('Resume with ID $resumeId not found.');
      }
    } catch (e) {
      print('Error fetching resume: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveResume() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saving resume...')),
    );
    try {
      final docRef = widget.resumeId != null
          ? _firestore.collection('users').doc(_userId).collection('resumes').doc(widget.resumeId)
          : _firestore.collection('users').doc(_userId).collection('resumes').doc();

      _resumeData['last_edited'] = Timestamp.now();
      _resumeData['education'] = _educationDetails;
      _resumeData['experience'] = _experienceDetails;
      _resumeData['projects'] = _projectDetails;
      await docRef.set(_resumeData, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resume saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save resume: $e')),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _summaryController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: () {
        if (_currentPage < 5) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        } else {
          _saveResume();
        }
      },
      child: Text(_currentPage < 5 ? 'Next' : 'Finish & Save'),
    );
  }

  Widget _buildAddButton(VoidCallback onPressed) {
    return IconButton(
      icon: const Icon(Icons.add_circle, color: Colors.blue),
      onPressed: onPressed,
    );
  }

  Widget _buildRemoveButton(VoidCallback onPressed) {
    return IconButton(
      icon: const Icon(Icons.remove_circle, color: Colors.red),
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveResume,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return Row(
              children: [
                Expanded(
                  child: _buildFormSection(),
                ),
                Expanded(
                  child: _buildLivePreview(),
                ),
              ],
            );
          } else {
            return _buildFormSection();
          }
        },
      ),
    );
  }

  Widget _buildFormSection() {
    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              _buildContactForm(),
              _buildSummaryForm(),
              _buildEducationForm(),
              _buildExperienceForm(),
              _buildSkillsForm(),
              _buildProjectsForm(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _currentPage > 0
                    ? () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                }
                    : null,
                child: const Text('Previous'),
              ),
              _buildNextButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLivePreview() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _resumeData['contact']['name'] ?? 'Your Name',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${_resumeData['contact']['email'] ?? ''} | ${_resumeData['contact']['phone'] ?? ''}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            Text(
              'Professional Summary',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_resumeData['summary'] ?? ''),
            const SizedBox(height: 20),
            Text(
              'Skills',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text((_resumeData['skills'] as List<dynamic>?)?.join(', ') ?? ''),
            const SizedBox(height: 20),
            Text(
              'Education',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (var edu in _educationDetails)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    edu['degree'] ?? '',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(edu['university'] ?? ''),
                  Text(edu['year'] ?? ''),
                  const SizedBox(height: 10),
                ],
              ),
            const SizedBox(height: 20),
            Text(
              'Experience',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (var exp in _experienceDetails)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exp['title'] ?? '',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(exp['company'] ?? ''),
                  Text(exp['duration'] ?? ''),
                  const SizedBox(height: 10),
                ],
              ),
            const SizedBox(height: 20),
            Text(
              'Projects',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (var proj in _projectDetails)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    proj['title'] ?? '',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(proj['description'] ?? ''),
                  const SizedBox(height: 10),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Contact Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Professional Summary', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextFormField(
            controller: _summaryController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Write a brief summary of your skills and experience.',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Education', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              _buildAddButton(() {
                setState(() {
                  _educationDetails.add({'degree': '', 'university': '', 'year': ''});
                });
              }),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _educationDetails.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Entry ${index + 1}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            _buildRemoveButton(() {
                              setState(() {
                                _educationDetails.removeAt(index);
                              });
                            }),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          initialValue: _educationDetails[index]['degree'],
                          decoration: const InputDecoration(labelText: 'Degree', border: OutlineInputBorder()),
                          onChanged: (value) => _educationDetails[index]['degree'] = value,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          initialValue: _educationDetails[index]['university'],
                          decoration: const InputDecoration(labelText: 'University', border: OutlineInputBorder()),
                          onChanged: (value) => _educationDetails[index]['university'] = value,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          initialValue: _educationDetails[index]['year'],
                          decoration: const InputDecoration(labelText: 'Graduation Year', border: OutlineInputBorder()),
                          onChanged: (value) => _educationDetails[index]['year'] = value,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Experience', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              _buildAddButton(() {
                setState(() {
                  _experienceDetails.add({'title': '', 'company': '', 'duration': ''});
                });
              }),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _experienceDetails.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Entry ${index + 1}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            _buildRemoveButton(() {
                              setState(() {
                                _experienceDetails.removeAt(index);
                              });
                            }),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          initialValue: _experienceDetails[index]['title'],
                          decoration: const InputDecoration(labelText: 'Job Title', border: OutlineInputBorder()),
                          onChanged: (value) => _experienceDetails[index]['title'] = value,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          initialValue: _experienceDetails[index]['company'],
                          decoration: const InputDecoration(labelText: 'Company', border: OutlineInputBorder()),
                          onChanged: (value) => _experienceDetails[index]['company'] = value,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          initialValue: _experienceDetails[index]['duration'],
                          decoration: const InputDecoration(labelText: 'Duration', border: OutlineInputBorder()),
                          onChanged: (value) => _experienceDetails[index]['duration'] = value,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Skills', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextFormField(
            controller: _skillsController,
            decoration: const InputDecoration(labelText: 'Skills (comma separated)', border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Projects', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              _buildAddButton(() {
                setState(() {
                  _projectDetails.add({'title': '', 'description': ''});
                });
              }),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _projectDetails.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Entry ${index + 1}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            _buildRemoveButton(() {
                              setState(() {
                                _projectDetails.removeAt(index);
                              });
                            }),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          initialValue: _projectDetails[index]['title'],
                          decoration: const InputDecoration(labelText: 'Project Title', border: OutlineInputBorder()),
                          onChanged: (value) => _projectDetails[index]['title'] = value,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          initialValue: _projectDetails[index]['description'],
                          maxLines: 3,
                          decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                          onChanged: (value) => _projectDetails[index]['description'] = value,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
