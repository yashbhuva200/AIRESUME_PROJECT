import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'resume_preview_screen.dart';
import '../services/ai_service.dart';
import '../widgets/skill_input_widget.dart';
import '../widgets/skill_suggestion_widget.dart';

class ResumeFormScreen extends StatefulWidget {
  final String? resumeId;
  const ResumeFormScreen({super.key, this.resumeId});

  @override
  State<ResumeFormScreen> createState() => _ResumeFormScreenState();
}

class _ResumeFormScreenState extends State<ResumeFormScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _summaryController = TextEditingController();
  final _skillsController = TextEditingController();

  // Data models
  List<Map<String, dynamic>> _educationDetails = [];
  List<Map<String, dynamic>> _experienceDetails = [];
  List<TextEditingController> _experienceDescriptionControllers = [];
  List<Map<String, dynamic>> _projectDetails = [];
  List<TextEditingController> _projectDescriptionControllers = [];

  final _firestore = FirebaseFirestore.instance;
  final _userId = FirebaseAuth.instance.currentUser!.uid;
  bool _isLoading = true;
  bool _isSaving = false;

  // Skill suggestion state
  List<String> _suggestedSkills = [];
  List<String> _selectedSkills = [];
  bool _isLoadingSkillSuggestions = false;

  @override
  void initState() {
    super.initState();
    _initializeData();

    // Add listener to summary controller for real-time character count updates
    _summaryController.addListener(() {
      setState(() {}); // Trigger rebuild to update character count
    });
  }

  void _initializeData() {
    if (widget.resumeId != null) {
      _fetchResumeData(widget.resumeId!);
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchResumeData(String resumeId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('resumes')
          .doc(resumeId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;

        // Clear existing data first
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _summaryController.clear();
        _skillsController.clear();

        // Populate contact information
        if (data['contact'] != null) {
          final contact = data['contact'] as Map<String, dynamic>;
          _nameController.text = contact['name']?.toString() ?? '';
          _emailController.text = contact['email']?.toString() ?? '';
          _phoneController.text = contact['phone']?.toString() ?? '';
          _locationController.text = contact['location']?.toString() ?? '';
        }

        // Populate other fields
        _summaryController.text = data['summary']?.toString() ?? '';

        // Handle skills list properly
        if (data['skills'] != null) {
          final skills = data['skills'] as List;
          if (skills.isNotEmpty) {
            final skillsText = skills.map((s) => s.toString()).join(', ');
            _skillsController.text = skillsText;
            _selectedSkills = skills.map((s) => s.toString()).toList();
          }
        }

        // Handle education details
        if (data['education'] != null) {
          final education = data['education'] as List;
          _educationDetails = education.map((item) {
            if (item is Map<String, dynamic>) {
              return Map<String, dynamic>.from(item);
            }
            return <String, dynamic>{};
          }).toList();
        } else {
          _educationDetails = [];
        }

        // Handle experience details
        if (data['experience'] != null) {
          final experience = data['experience'] as List;
          _experienceDetails = experience.map((item) {
            if (item is Map<String, dynamic>) {
              return Map<String, dynamic>.from(item);
            }
            return <String, dynamic>{};
          }).toList();

          // Create controllers for existing experience data
          _experienceDescriptionControllers = _experienceDetails.map((item) {
            final controller = TextEditingController();
            controller.text = item['description']?.toString() ?? '';
            return controller;
          }).toList();
        } else {
          _experienceDetails = [];
          _experienceDescriptionControllers = [];
        }

        // Handle project details
        if (data['projects'] != null) {
          final projects = data['projects'] as List;
          _projectDetails = projects.map((item) {
            if (item is Map<String, dynamic>) {
              return Map<String, dynamic>.from(item);
            }
            return <String, dynamic>{};
          }).toList();

          // Create controllers for existing project data
          _projectDescriptionControllers = _projectDetails.map((item) {
            final controller = TextEditingController();
            controller.text = item['description']?.toString() ?? '';
            return controller;
          }).toList();
        } else {
          _projectDetails = [];
          _projectDescriptionControllers = [];
        }

        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading resume: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveResume() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if summary is too long
    if (_summaryController.text.length > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Professional summary is too long! Please keep it under 500 characters.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // If user is not premium, show premium dialog

    setState(() => _isSaving = true);

    try {
      final resumeData = {
        'contact': {
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'location': _locationController.text,
        },
        'summary': _summaryController.text,
        'skills': _skillsController.text
            .split(',')
            .map((s) => s.trim())
            .toList(),
        'education': _educationDetails,
        'experience': _experienceDetails,
        'projects': _projectDetails,
        'last_edited': FieldValue.serverTimestamp(),
      };

      final docRef = widget.resumeId != null
          ? _firestore
                .collection('users')
                .doc(_userId)
                .collection('resumes')
                .doc(widget.resumeId)
          : _firestore
                .collection('users')
                .doc(_userId)
                .collection('resumes')
                .doc();

      await docRef.set(resumeData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resume saved successfully!')),
      );

      // Navigate to preview screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ResumePreviewScreen(
              resumeId: docRef.id,
              resumeData: resumeData,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _summaryController.dispose();
    _skillsController.dispose();
    _pageController.dispose();
    // Dispose experience description controllers
    for (var controller in _experienceDescriptionControllers) {
      controller.dispose();
    }
    // Dispose project description controllers
    for (var controller in _projectDescriptionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Generates AI summary for a specific job experience
  Future<void> _generateJobSummary(int index) async {
    final jobTitle = _experienceDetails[index]['title']?.toString() ?? '';
    final company = _experienceDetails[index]['company']?.toString() ?? '';
    final duration = _experienceDetails[index]['duration']?.toString() ?? '';

    if (jobTitle.isEmpty || company.isEmpty || duration.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill in Job Title, Company, and Duration first',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final aiSummary = await AIService.generateJobExperienceSummary(
        jobTitle: jobTitle,
        company: company,
        duration: duration,
        jobDescription: _experienceDetails[index]['description']?.toString(),
      );

      setState(() {
        _experienceDetails[index]['description'] = aiSummary;
        _experienceDescriptionControllers[index].text = aiSummary;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI summary generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating summary: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Improves the professional summary using AI
  Future<void> _improveSummaryWithAI() async {
    if (_summaryController.text.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Improving your summary with AI...'),
            ],
          ),
        ),
      );

      // Call AI service to improve summary
      final improvedSummary = await AIService.improveSummary(
        _summaryController.text,
      );

      // Close loading dialog
      Navigator.of(context).pop();

      // Show confirmation dialog with improved summary
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('AI-Improved Summary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Here\'s your improved professional summary:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  improvedSummary,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Keep Original'),
            ),
            ElevatedButton(
              onPressed: () {
                _summaryController.text = improvedSummary;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Summary updated with AI improvements!'),
                    backgroundColor: Color(0xFF48bb78),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF48bb78),
                foregroundColor: Colors.white,
              ),
              child: const Text('Use Improved'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading dialog if it's still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error improving summary: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Your Resume'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveResume,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFf8f9fa),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentPage + 1) / 6,
              minHeight: 4,
              backgroundColor: const Color(0xFF667eea).withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF667eea),
              ),
            ),

            // Form content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildContactPage(),
                  _buildSummaryPage(),
                  _buildEducationPage(),
                  _buildExperiencePage(),
                  _buildSkillsPage(),
                  _buildProjectsPage(),
                ],
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFf8f9fa),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    OutlinedButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF667eea)),
                        foregroundColor: const Color(0xFF667eea),
                      ),
                      child: const Text('BACK'),
                    )
                  else
                    const SizedBox(width: 100),

                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < 5) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _saveResume();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: const Color(0xFF667eea).withOpacity(0.3),
                    ),
                    child: Text(_currentPage < 5 ? 'NEXT' : 'SAVE RESUME'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) => value!.isEmpty ? 'Required field' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) => value!.isEmpty ? 'Required field' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location (City, Country)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Professional Summary',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Write a brief overview of your professional background',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _summaryController,
            maxLines: 4,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: 'Professional Summary',
              border: OutlineInputBorder(),
              hintText:
                  'Write a compelling summary of your professional background...',
              counterText: '', // Hide default counter, we'll show custom one
            ),
          ),
          // Custom character counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_summaryController.text.length}/500 characters',
                style: TextStyle(
                  color: _summaryController.text.length > 450
                      ? Colors.orange
                      : _summaryController.text.length > 500
                      ? Colors.red
                      : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              if (_summaryController.text.length > 500)
                const Text(
                  'Summary too long!',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _summaryController.text.isEmpty
                      ? null
                      : _improveSummaryWithAI,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Improve with AI'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF48bb78),
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: const Color(0xFF48bb78).withOpacity(0.3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEducationPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Education',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: () => setState(() {
                  _educationDetails.add({
                    'degree': '',
                    'institution': '',
                    'year': '',
                    'description': '',
                  });
                }),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: _educationDetails.length,
            itemBuilder: (context, index) {
              return _buildEducationCard(index);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => setState(() {
                    _educationDetails.add({
                      'degree': '',
                      'institution': '',
                      'year': '',
                      'description': '',
                    });
                  }),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Education'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEducationCard(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Education #${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      setState(() => _educationDetails.removeAt(index)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue:
                  _educationDetails[index]['degree']?.toString() ?? '',
              decoration: const InputDecoration(
                labelText: 'Degree',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _educationDetails[index]['degree'] = value,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue:
                  _educationDetails[index]['institution']?.toString() ?? '',
              decoration: const InputDecoration(
                labelText: 'Institution',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) =>
                  _educationDetails[index]['institution'] = value,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _educationDetails[index]['year']?.toString() ?? '',
              decoration: const InputDecoration(
                labelText: 'Year',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _educationDetails[index]['year'] = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperiencePage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Work Experience',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: () => setState(() {
                  _experienceDetails.add({
                    'title': '',
                    'company': '',
                    'duration': '',
                    'description': '',
                  });
                  _experienceDescriptionControllers.add(
                    TextEditingController(),
                  );
                }),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: _experienceDetails.length,
            itemBuilder: (context, index) {
              return _buildExperienceCard(index);
            },
          ),
        ),
      ],
    );
  }

  /// Generates AI summary for a specific project
  Future<void> _generateProjectSummary(int index) async {
    final projectTitle = _projectDetails[index]['title']?.toString() ?? '';
    final projectDescription =
        _projectDetails[index]['description']?.toString() ?? '';
    final technologies =
        _projectDetails[index]['technologies']?.toString() ?? '';
    final duration = _projectDetails[index]['duration']?.toString() ?? '';

    if (projectTitle.isEmpty || technologies.isEmpty || duration.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill in Project Title, Technologies, and Duration first',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final aiSummary = await AIService.generateProjectSummary(
        projectTitle: projectTitle,
        projectDescription: projectDescription,
        technologies: technologies,
        duration: duration,
      );

      setState(() {
        _projectDetails[index]['description'] = aiSummary;
        _projectDescriptionControllers[index].text = aiSummary;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI project summary generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating project summary: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Generates AI skill suggestions based on the professional summary
  Future<void> _generateSkillSuggestions() async {
    final summary = _summaryController.text.trim();

    if (summary.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a professional summary first'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isLoadingSkillSuggestions = true);

    try {
      // Add a timeout to prevent long delays
      final suggestions =
          await AIService.suggestSkillsFromSummary(summary: summary).timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              // Return fallback skills if timeout occurs
              return _getFallbackSkills(summary);
            },
          );

      setState(() {
        _suggestedSkills = suggestions;
        _isLoadingSkillSuggestions = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${suggestions.length} skill suggestions generated!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoadingSkillSuggestions = false);

      // Provide fallback skills even on error
      final fallbackSkills = _getFallbackSkills(summary);
      setState(() {
        _suggestedSkills = fallbackSkills;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Using fallback skill suggestions (${fallbackSkills.length} skills)',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Provides fallback skills when AI fails
  List<String> _getFallbackSkills(String summary) {
    final summaryLower = summary.toLowerCase();
    final fallbackSkills = <String>[];

    // Technical skills based on keywords
    if (summaryLower.contains('developer') ||
        summaryLower.contains('programming') ||
        summaryLower.contains('software')) {
      fallbackSkills.addAll([
        'JavaScript',
        'Python',
        'Git',
        'Problem Solving',
        'Teamwork',
      ]);
    }
    if (summaryLower.contains('web') ||
        summaryLower.contains('frontend') ||
        summaryLower.contains('backend')) {
      fallbackSkills.addAll([
        'HTML',
        'CSS',
        'React',
        'Node.js',
        'Communication',
      ]);
    }
    if (summaryLower.contains('mobile') || summaryLower.contains('app')) {
      fallbackSkills.addAll([
        'React Native',
        'Flutter',
        'iOS',
        'Android',
        'User Experience',
      ]);
    }
    if (summaryLower.contains('data') ||
        summaryLower.contains('analyst') ||
        summaryLower.contains('analytics')) {
      fallbackSkills.addAll([
        'Python',
        'SQL',
        'Excel',
        'Analytics',
        'Critical Thinking',
      ]);
    }
    if (summaryLower.contains('design') ||
        summaryLower.contains('ui') ||
        summaryLower.contains('ux')) {
      fallbackSkills.addAll([
        'Figma',
        'Adobe XD',
        'Photoshop',
        'UI/UX Design',
        'Creativity',
      ]);
    }
    if (summaryLower.contains('manager') ||
        summaryLower.contains('lead') ||
        summaryLower.contains('supervisor')) {
      fallbackSkills.addAll([
        'Leadership',
        'Project Management',
        'Team Management',
        'Communication',
        'Strategic Thinking',
      ]);
    }
    if (summaryLower.contains('marketing') || summaryLower.contains('sales')) {
      fallbackSkills.addAll([
        'Digital Marketing',
        'Communication',
        'Customer Service',
        'Analytics',
        'Negotiation',
      ]);
    }
    if (summaryLower.contains('finance') ||
        summaryLower.contains('accounting')) {
      fallbackSkills.addAll([
        'Financial Analysis',
        'Excel',
        'Accounting',
        'Attention to Detail',
        'Problem Solving',
      ]);
    }
    if (summaryLower.contains('healthcare') ||
        summaryLower.contains('medical')) {
      fallbackSkills.addAll([
        'Patient Care',
        'Medical Records',
        'HIPAA',
        'Communication',
        'Attention to Detail',
      ]);
    }
    if (summaryLower.contains('education') ||
        summaryLower.contains('teaching')) {
      fallbackSkills.addAll([
        'Teaching',
        'Communication',
        'Curriculum Development',
        'Mentoring',
        'Patience',
      ]);
    }

    // Always add common soft skills
    fallbackSkills.addAll([
      'Communication',
      'Problem Solving',
      'Time Management',
      'Teamwork',
      'Adaptability',
    ]);

    // Remove duplicates and return
    return fallbackSkills.toSet().take(15).toList();
  }

  /// Handles skill selection from AI suggestions
  void _onSkillSelected(String skill) {
    setState(() {
      if (_selectedSkills.contains(skill)) {
        _selectedSkills.remove(skill);
      } else {
        _selectedSkills.add(skill);
      }
      _updateSkillsText();
    });
  }

  /// Updates the skills text field with selected skills
  void _updateSkillsText() {
    final skillsText = _selectedSkills.join(', ');
    _skillsController.text = skillsText;
  }

  Widget _buildExperienceCard(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Experience #${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() {
                    _experienceDescriptionControllers[index].dispose();
                    _experienceDescriptionControllers.removeAt(index);
                    _experienceDetails.removeAt(index);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue:
                  _experienceDetails[index]['title']?.toString() ?? '',
              decoration: const InputDecoration(
                labelText: 'Job Title',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _experienceDetails[index]['title'] = value,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue:
                  _experienceDetails[index]['company']?.toString() ?? '',
              decoration: const InputDecoration(
                labelText: 'Company',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) =>
                  _experienceDetails[index]['company'] = value,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue:
                  _experienceDetails[index]['duration']?.toString() ?? '',
              decoration: const InputDecoration(
                labelText: 'Duration (e.g., 2020-2023)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) =>
                  _experienceDetails[index]['duration'] = value,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _experienceDescriptionControllers[index],
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      hintText:
                          'Describe your responsibilities and achievements...',
                    ),
                    onChanged: (value) =>
                        _experienceDetails[index]['description'] = value,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _generateJobSummary(index),
                  icon: const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF667eea),
                  ),
                  tooltip: 'Generate AI Summary',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Skills & Competencies',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: _generateSkillSuggestions,
                icon: const Icon(Icons.auto_awesome, color: Color(0xFF667eea)),
                tooltip: 'Generate AI Skill Suggestions',
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Add skills manually or use AI suggestions based on your summary',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // AI Skill Suggestions
          SkillSuggestionWidget(
            suggestedSkills: _suggestedSkills,
            selectedSkills: _selectedSkills,
            onSkillSelected: _onSkillSelected,
            isLoading: _isLoadingSkillSuggestions,
          ),

          if (_suggestedSkills.isNotEmpty) const SizedBox(height: 16),

          // Skill Input Widget
          SkillInputWidget(
            initialValue: _skillsController.text,
            onChanged: (value) {
              _skillsController.text = value;
              // Update selected skills from the input
              _selectedSkills = value
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();
            },
            onSkillsSelected: (skills) {
              _selectedSkills = skills;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Projects & Achievements',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: () => setState(() {
                  _projectDetails.add({
                    'title': '',
                    'description': '',
                    'technologies': '',
                    'link': '',
                    'duration': '',
                  });
                  _projectDescriptionControllers.add(TextEditingController());
                }),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: _projectDetails.length,
            itemBuilder: (context, index) {
              return _buildProjectCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProjectCard(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Project #${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() {
                    _projectDescriptionControllers[index].dispose();
                    _projectDescriptionControllers.removeAt(index);
                    _projectDetails.removeAt(index);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _projectDetails[index]['title']?.toString() ?? '',
              decoration: const InputDecoration(
                labelText: 'Project Title',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _projectDetails[index]['title'] = value,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _projectDescriptionControllers[index],
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      hintText: 'Describe what the project does...',
                    ),
                    onChanged: (value) =>
                        _projectDetails[index]['description'] = value,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _generateProjectSummary(index),
                  icon: const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF667eea),
                  ),
                  tooltip: 'Generate AI Summary',
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue:
                  _projectDetails[index]['technologies']?.toString() ?? '',
              decoration: const InputDecoration(
                labelText: 'Technologies Used',
                border: OutlineInputBorder(),
                hintText: 'e.g., React, Node.js, MongoDB',
              ),
              onChanged: (value) =>
                  _projectDetails[index]['technologies'] = value,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue:
                        _projectDetails[index]['link']?.toString() ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Project Link (optional)',
                      border: OutlineInputBorder(),
                      hintText: 'GitHub, live demo, etc.',
                    ),
                    onChanged: (value) =>
                        _projectDetails[index]['link'] = value,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue:
                        _projectDetails[index]['duration']?.toString() ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Duration',
                      border: OutlineInputBorder(),
                      hintText: '3 months, 6 months, etc.',
                    ),
                    onChanged: (value) =>
                        _projectDetails[index]['duration'] = value,
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
