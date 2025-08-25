import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResumePreviewScreen extends StatelessWidget {
  final String resumeId;
  final Map<String, dynamic> resumeData;

  const ResumePreviewScreen({
    super.key,
    required this.resumeId,
    required this.resumeData,
  });

  @override
  Widget build(BuildContext context) {
    final contact = resumeData['contact'] as Map<String, dynamic>? ?? {};
    final summary = resumeData['summary'] as String? ?? '';
    final skills = resumeData['skills'] as List? ?? [];
    final experience = resumeData['experience'] as List? ?? [];
    final education = resumeData['education'] as List? ?? [];
    final projects = resumeData['projects'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Preview'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // TODO: Implement PDF download
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF download coming soon!')),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header with name and recommended badge
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFFf8f9fa),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        contact['name']?.toString().toUpperCase() ??
                            'YOUR NAME',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2d3748),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF667eea).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'PROFESSIONAL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF667eea),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Two Column Layout
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column - Photo and Contact
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(color: Color(0xFFf8f9fa)),
                      child: Column(
                        children: [
                          // Profile Photo Placeholder
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFF667eea).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF667eea).withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xFF667eea),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Contact Information
                          _buildContactSection(contact),
                          const SizedBox(height: 20),

                          // Skills Section
                          if (skills.isNotEmpty) ...[
                            _buildSectionTitle('SKILLS'),
                            const SizedBox(height: 12),
                            _buildSkillsGrid(skills),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Right Column - Main Content
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Summary Section
                          if (summary.isNotEmpty) ...[
                            _buildSectionTitle('SUMMARY'),
                            const SizedBox(height: 12),
                            Text(
                              summary,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4a5568),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Experience Section
                          if (experience.isNotEmpty) ...[
                            _buildSectionTitle('EXPERIENCE'),
                            const SizedBox(height: 12),
                            ...experience.map(
                              (exp) => _buildExperienceItem(exp),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Education Section
                          if (education.isNotEmpty) ...[
                            _buildSectionTitle('EDUCATION'),
                            const SizedBox(height: 12),
                            ...education.map((edu) => _buildEducationItem(edu)),
                            const SizedBox(height: 24),
                          ],

                          // Projects Section
                          if (projects.isNotEmpty) ...[
                            _buildSectionTitle('PROJECTS'),
                            const SizedBox(height: 12),
                            ...projects.map(
                              (project) => _buildProjectItem(project),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2d3748),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 2,
          width: 40,
          decoration: const BoxDecoration(
            color: Color(0xFF667eea),
            borderRadius: BorderRadius.all(Radius.circular(1)),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(Map<String, dynamic> contact) {
    final contactItems = [
      if (contact['location'] != null)
        {'icon': Icons.location_on, 'text': contact['location']},
      if (contact['phone'] != null)
        {'icon': Icons.phone, 'text': contact['phone']},
      if (contact['email'] != null)
        {'icon': Icons.email, 'text': contact['email']},
    ];

    return Column(
      children: contactItems.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(
                item['icon'] as IconData,
                size: 16,
                color: const Color(0xFF667eea),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item['text'].toString(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4a5568),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSkillsGrid(List skills) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills.map((skill) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF667eea).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF667eea).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            skill.toString(),
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF667eea),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExperienceItem(Map<String, dynamic> exp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exp['title']?.toString().toUpperCase() ?? 'JOB TITLE',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2d3748),
                  ),
                ),
              ),
              Text(
                exp['duration']?.toString() ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF718096),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (exp['company'] != null) ...[
            const SizedBox(height: 4),
            Text(
              exp['company'].toString(),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF667eea),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (exp['description'] != null) ...[
            const SizedBox(height: 8),
            Text(
              exp['description'].toString(),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4a5568),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEducationItem(Map<String, dynamic> edu) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  edu['degree']?.toString().toUpperCase() ?? 'DEGREE',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2d3748),
                  ),
                ),
              ),
              Text(
                edu['year']?.toString() ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF718096),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (edu['institution'] != null) ...[
            const SizedBox(height: 4),
            Text(
              edu['institution'].toString(),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF667eea),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProjectItem(Map<String, dynamic> project) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  project['name']?.toString().toUpperCase() ?? 'PROJECT NAME',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2d3748),
                  ),
                ),
              ),
              if (project['year'] != null)
                Text(
                  project['year'].toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF718096),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          if (project['technologies'] != null) ...[
            const SizedBox(height: 4),
            Text(
              project['technologies'].toString(),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF667eea),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (project['description'] != null) ...[
            const SizedBox(height: 8),
            Text(
              project['description'].toString(),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4a5568),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
