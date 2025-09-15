import 'dart:async';
import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class SkillInputWidget extends StatefulWidget {
  final String initialValue;
  final Function(String) onChanged;
  final Function(List<String>) onSkillsSelected;

  const SkillInputWidget({
    Key? key,
    required this.initialValue,
    required this.onChanged,
    required this.onSkillsSelected,
  }) : super(key: key);

  @override
  State<SkillInputWidget> createState() => _SkillInputWidgetState();
}

class _SkillInputWidgetState extends State<SkillInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _suggestedSkills = [];
  List<String> _selectedSkills = [];
  List<String> _aiRelatedSkills = [];
  bool _showSuggestions = false;
  bool _isLoadingAIRelated = false;
  Timer? _debounceTimer;

  // Comprehensive skills database for autocomplete
  final List<String> _commonSkills = [
    // Programming Languages
    'JavaScript',
    'Python',
    'Java',
    'C++',
    'C#',
    'PHP',
    'Ruby',
    'Go',
    'Rust',
    'Swift',
    'Kotlin',
    'TypeScript',
    'Dart',
    'Scala',
    'R',
    'MATLAB',
    'Perl',
    'Haskell',
    'Clojure',
    'Erlang',

    // Web Development
    'HTML',
    'CSS',
    'React',
    'Angular',
    'Vue.js',
    'Node.js',
    'Express.js',
    'Django',
    'Flask',
    'Laravel',
    'Spring Boot',
    'ASP.NET',
    'jQuery',
    'Bootstrap',
    'Tailwind CSS',
    'SASS',
    'LESS',
    'Webpack',
    'Vite',
    'Next.js',
    'Nuxt.js',
    'Svelte',

    // Mobile Development
    'React Native',
    'Flutter',
    'Ionic',
    'Xamarin',
    'Android Studio',
    'Xcode',
    'SwiftUI',
    'Jetpack Compose',
    'Cordova',
    'PhoneGap',

    // Databases
    'MySQL',
    'PostgreSQL',
    'MongoDB',
    'Redis',
    'SQLite',
    'Oracle',
    'SQL Server',
    'Firebase',
    'DynamoDB',
    'Cassandra',
    'Elasticsearch',
    'Neo4j',
    'CouchDB',
    'MariaDB',

    // Cloud & DevOps
    'AWS',
    'Azure',
    'Google Cloud',
    'Docker',
    'Kubernetes',
    'Jenkins',
    'GitLab CI',
    'GitHub Actions',
    'Terraform',
    'Ansible',
    'Linux',
    'Ubuntu',
    'CentOS',
    'Heroku',
    'DigitalOcean',

    // Tools & Version Control
    'Git',
    'GitHub',
    'GitLab',
    'Bitbucket',
    'Jira',
    'Confluence',
    'Slack',
    'Trello',
    'Figma',
    'Adobe XD',
    'Sketch',
    'Postman',
    'VS Code',
    'IntelliJ IDEA',
    'Sublime Text',
    'Atom',

    // Data Science & AI
    'Machine Learning',
    'Deep Learning',
    'TensorFlow',
    'PyTorch',
    'Pandas',
    'NumPy',
    'Scikit-learn',
    'Jupyter',
    'Tableau',
    'Power BI',
    'Apache Spark',
    'Hadoop',
    'R',
    'MATLAB',
    'Excel',
    'Google Analytics',

    // Design & Creative
    'Photoshop',
    'Illustrator',
    'InDesign',
    'Figma',
    'Sketch',
    'Adobe XD',
    'Canva',
    'UI/UX Design',
    'Graphic Design',
    'Web Design',
    'Logo Design',
    'Branding',
    'Typography',
    'Color Theory',

    // Marketing & Business
    'Digital Marketing',
    'SEO',
    'SEM',
    'Google Ads',
    'Facebook Ads',
    'Content Marketing',
    'Social Media Marketing',
    'Email Marketing',
    'Analytics',
    'Google Analytics',
    'HubSpot',
    'Salesforce',
    'CRM',
    'Lead Generation',

    // Finance & Accounting
    'Financial Analysis',
    'Accounting',
    'QuickBooks',
    'Excel',
    'Financial Modeling',
    'Budgeting',
    'Forecasting',
    'Tax Preparation',
    'Auditing',
    'Risk Management',
    'Investment Analysis',
    'SAP',
    'Oracle Financials',

    // Healthcare & Medical
    'Patient Care',
    'Medical Records',
    'HIPAA',
    'EMR Systems',
    'Clinical Research',
    'Pharmaceutical Sales',
    'Healthcare Administration',
    'Nursing',
    'Medical Coding',
    'Healthcare IT',
    'Telemedicine',
    'Medical Devices',

    // Education & Training
    'Curriculum Development',
    'Instructional Design',
    'Training Delivery',
    'E-Learning',
    'Educational Technology',
    'Classroom Management',
    'Student Assessment',
    'Learning Management Systems',
    'Moodle',
    'Blackboard',
    'Teaching',
    'Mentoring',

    // Sales & Customer Service
    'Sales',
    'Customer Service',
    'Account Management',
    'Lead Generation',
    'Cold Calling',
    'Negotiation',
    'Relationship Building',
    'CRM',
    'Salesforce',
    'HubSpot',
    'Customer Success',
    'Retail Sales',
    'B2B Sales',
    'B2C Sales',

    // Operations & Supply Chain
    'Supply Chain Management',
    'Logistics',
    'Inventory Management',
    'Procurement',
    'Vendor Management',
    'Quality Control',
    'Lean Manufacturing',
    'Six Sigma',
    'Process Improvement',
    'Operations Management',
    'Warehouse Management',

    // Human Resources
    'Recruitment',
    'Talent Acquisition',
    'HRIS',
    'Employee Relations',
    'Performance Management',
    'Training & Development',
    'Compensation & Benefits',
    'Labor Relations',
    'HR Analytics',
    'Workday',
    'BambooHR',

    // Legal & Compliance
    'Legal Research',
    'Contract Management',
    'Compliance',
    'Risk Assessment',
    'Regulatory Affairs',
    'Intellectual Property',
    'Corporate Law',
    'Litigation',
    'Legal Writing',
    'Paralegal',
    'Legal Technology',

    // Construction & Engineering
    'AutoCAD',
    'Revit',
    'Civil Engineering',
    'Mechanical Engineering',
    'Electrical Engineering',
    'Project Management',
    'Construction Management',
    'Building Codes',
    'Safety Management',
    'Quality Assurance',
    'Structural Analysis',

    // Manufacturing & Production
    'Manufacturing',
    'Production Planning',
    'Quality Control',
    'Lean Manufacturing',
    'Six Sigma',
    'Process Improvement',
    'Equipment Maintenance',
    'Safety Management',
    'Inventory Management',
    'Supply Chain',

    // Hospitality & Tourism
    'Customer Service',
    'Event Planning',
    'Hotel Management',
    'Restaurant Management',
    'Tourism',
    'Hospitality',
    'Food Service',
    'Guest Relations',
    'Revenue Management',
    'Travel Planning',

    // Real Estate
    'Real Estate Sales',
    'Property Management',
    'Real Estate Law',
    'Market Analysis',
    'Property Valuation',
    'Real Estate Marketing',
    'Lease Negotiation',
    'Property Development',
    'Real Estate Finance',
    'Commercial Real Estate',

    // Media & Communications
    'Journalism',
    'Content Writing',
    'Copywriting',
    'Public Relations',
    'Media Relations',
    'Social Media',
    'Video Production',
    'Photography',
    'Podcasting',
    'Broadcasting',
    'News Writing',
    'Technical Writing',

    // Transportation & Logistics
    'Logistics',
    'Transportation Management',
    'Fleet Management',
    'Route Planning',
    'Supply Chain',
    'Warehouse Operations',
    'Shipping',
    'Freight Management',
    'Import/Export',
    'Customs Compliance',

    // Agriculture & Food
    'Agricultural Science',
    'Crop Management',
    'Livestock Management',
    'Food Safety',
    'Quality Control',
    'Agricultural Technology',
    'Farm Management',
    'Food Processing',
    'Agricultural Marketing',
    'Sustainable Agriculture',

    // Energy & Utilities
    'Energy Management',
    'Renewable Energy',
    'Solar Energy',
    'Wind Energy',
    'Electrical Systems',
    'Power Generation',
    'Energy Efficiency',
    'Utility Management',
    'Environmental Compliance',
    'Grid Management',

    // Soft Skills (Universal)
    'Leadership',
    'Communication',
    'Problem Solving',
    'Team Management',
    'Project Management',
    'Agile',
    'Scrum',
    'Time Management',
    'Critical Thinking',
    'Creativity',
    'Adaptability',
    'Collaboration',
    'Presentation Skills',
    'Negotiation',
    'Emotional Intelligence',
    'Conflict Resolution',
    'Decision Making',
    'Strategic Thinking',
    'Innovation',
    'Mentoring',
    'Coaching',
    'Public Speaking',
    'Active Listening',
    'Multitasking',
    'Attention to Detail',
    'Work Ethic',
    'Reliability',
    'Flexibility',
    'Cultural Awareness',
    'Networking',

    // Languages
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Chinese',
    'Japanese',
    'Korean',
    'Arabic',
    'Hindi',
    'Russian',
    'Dutch',
    'Swedish',
    'Norwegian',
    'Danish',
    'Finnish',
    'Polish',
    'Czech',
    'Hungarian',
    'Greek',
    'Turkish',
    'Hebrew',
    'Thai',
    'Vietnamese',
    'Indonesian',
    'Malay',
    'Tagalog',
    'Translation',
    'Interpretation',

    // Certifications & Standards
    'PMP',
    'PMP Certification',
    'Six Sigma',
    'Lean Six Sigma',
    'ISO 9001',
    'ISO 27001',
    'ITIL',
    'CISSP',
    'AWS Certified',
    'Google Cloud Certified',
    'Microsoft Certified',
    'Cisco Certified',
    'CompTIA',
    'CPA',
    'CFA',
    'FRM',
    'PHR',
    'SHRM-CP',
    'CPR',
    'First Aid',
    'OSHA',
    'FDA Compliance',
    'HIPAA Compliance',
    'GDPR Compliance',

    // Testing & Quality Assurance
    'Jest',
    'Cypress',
    'Selenium',
    'JUnit',
    'Pytest',
    'Mocha',
    'Chai',
    'Enzyme',
    'Testing Library',
    'Unit Testing',
    'Integration Testing',
    'E2E Testing',
    'Manual Testing',
    'Automated Testing',
    'Performance Testing',
    'Load Testing',
    'Security Testing',
    'API Testing',
    'Mobile Testing',
    'Cross-browser Testing',
  ];

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue;
    _selectedSkills = widget.initialValue
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _updateSuggestions(_controller.text);
    } else {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  void _updateSuggestions(String query) {
    if (query.isEmpty) {
      setState(() {
        _suggestedSkills = [];
        _showSuggestions = false;
      });
      return;
    }

    final filteredSkills = _commonSkills
        .where(
          (skill) =>
              skill.toLowerCase().contains(query.toLowerCase()) &&
              !_selectedSkills.contains(skill),
        )
        .take(8)
        .toList();

    setState(() {
      _suggestedSkills = filteredSkills;
      _showSuggestions = filteredSkills.isNotEmpty;
    });

    // Trigger AI-related skill suggestions with debounce
    _triggerAIRelatedSuggestions(query);
  }

  void _triggerAIRelatedSuggestions(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      _generateAIRelatedSkills(query);
    });
  }

  Future<void> _generateAIRelatedSkills(String userInput) async {
    if (userInput.trim().isEmpty || userInput.trim().length < 3) {
      return;
    }

    setState(() => _isLoadingAIRelated = true);

    try {
      final relatedSkills = await AIService.suggestRelatedSkills(
        userInput: userInput,
      ).timeout(const Duration(seconds: 10), onTimeout: () => <String>[]);

      if (mounted) {
        setState(() {
          _aiRelatedSkills = relatedSkills
              .where((skill) => !_selectedSkills.contains(skill))
              .toList();
          _isLoadingAIRelated = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiRelatedSkills = [];
          _isLoadingAIRelated = false;
        });
      }
    }
  }

  void _addSkill(String skill) {
    if (!_selectedSkills.contains(skill)) {
      setState(() {
        _selectedSkills.add(skill);
        _updateSkillsText();
        _showSuggestions = false;
      });
      _controller.clear();
      _focusNode.unfocus();
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _selectedSkills.remove(skill);
      _updateSkillsText();
    });
  }

  void _updateSkillsText() {
    final skillsText = _selectedSkills.join(', ');
    _controller.text = skillsText;
    widget.onChanged(skillsText);
    widget.onSkillsSelected(_selectedSkills);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected Skills Chips
        if (_selectedSkills.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedSkills
                  .map(
                    (skill) => Chip(
                      label: Text(skill),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => _removeSkill(skill),
                      backgroundColor: Colors.blue.shade50,
                      labelStyle: const TextStyle(fontSize: 12),
                    ),
                  )
                  .toList(),
            ),
          ),

        const SizedBox(height: 8),

        // Text Input Field
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: const InputDecoration(
            labelText: 'Skills',
            border: OutlineInputBorder(),
            hintText: 'Type to search skills or add manually...',
            suffixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            _updateSuggestions(value);
            widget.onChanged(value);
          },
          onFieldSubmitted: (value) {
            if (value.trim().isNotEmpty &&
                !_selectedSkills.contains(value.trim())) {
              _addSkill(value.trim());
            }
          },
        ),

        // AI Related Skills Section
        if (_aiRelatedSkills.isNotEmpty || _isLoadingAIRelated)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Colors.purple.shade600,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI Suggested Related Skills',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                    if (_isLoadingAIRelated) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.purple.shade600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (_aiRelatedSkills.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _aiRelatedSkills.map((skill) {
                      return GestureDetector(
                        onTap: () => _addSkill(skill),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.purple.shade300,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                skill,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.purple.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.add,
                                size: 14,
                                color: Colors.purple.shade800,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),

        // Regular Suggestions Dropdown
        if (_showSuggestions && _suggestedSkills.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _suggestedSkills.length,
              itemBuilder: (context, index) {
                final skill = _suggestedSkills[index];
                return ListTile(
                  dense: true,
                  title: Text(skill),
                  onTap: () => _addSkill(skill),
                  trailing: const Icon(Icons.add, size: 18),
                );
              },
            ),
          ),
      ],
    );
  }
}
