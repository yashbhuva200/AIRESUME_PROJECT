import 'package:flutter/material.dart';
import 'dart:io' show Platform, File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart' as pwlib;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ResumePreviewScreen extends StatefulWidget {
  final String resumeId;
  final Map<String, dynamic> resumeData;
  final String? selectedTemplate;

  const ResumePreviewScreen({
    super.key,
    required this.resumeId,
    required this.resumeData,
    this.selectedTemplate,
  });

  @override
  State<ResumePreviewScreen> createState() => _ResumePreviewScreenState();
}

class _ResumePreviewScreenState extends State<ResumePreviewScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    setState(() => _isLoading = false);
  }

  Widget _buildResumeContent({
    required Map<String, dynamic> contact,
    required String summary,
    required List skills,
    required List experience,
    required List education,
    required List projects,
    required String template,
  }) {
    switch (template) {
      case 'single_column':
        return _buildSingleColumnTemplate(
          contact: contact,
          summary: summary,
          skills: skills,
          experience: experience,
          education: education,
          projects: projects,
        );
      case 'academic':
        return _buildAcademicTemplate(
          contact: contact,
          summary: summary,
          skills: skills,
          experience: experience,
          education: education,
          projects: projects,
        );
      case 'professional':
        return _buildProfessionalTemplate(
          contact: contact,
          summary: summary,
          skills: skills,
          experience: experience,
          education: education,
          projects: projects,
        );
      case 'classic_left':
      default:
        return _buildClassicLeftTemplate(
          contact: contact,
          summary: summary,
          skills: skills,
          experience: experience,
          education: education,
          projects: projects,
        );
    }
  }

  Widget _buildClassicLeftTemplate({
    required Map<String, dynamic> contact,
    required String summary,
    required List skills,
    required List experience,
    required List education,
    required List projects,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Row(
        children: [
          // Left sidebar - Full height
          Container(
            width: 160,
            height: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFF123B63)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name at top of sidebar
                  Center(
                    child: Text(
                      contact['name']?.toString().toUpperCase() ?? 'YOUR NAME',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Profile picture placeholder
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        color: Colors.white.withOpacity(0.1),
                      ),
                      child: const Center(
                        child: Text(
                          'X',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Contact Information
                  _buildSidebarTitle('Contact'),
                  const SizedBox(height: 12),
                  _buildContactSection(contact, dark: true),
                  const SizedBox(height: 20),

                  // Skills Section
                  if (skills.isNotEmpty) ...[
                    _buildSidebarTitle('Skills'),
                    const SizedBox(height: 12),
                    _buildSkillsList(skills.take(12).toList()),
                  ],
                  const Spacer(),
                ],
              ),
            ),
          ),

          // Right content area - Full height with scroll
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with name and professional badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          contact['name']?.toString().toUpperCase() ??
                              'YOUR NAME',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
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
                          color: const Color(0xFF4F46E5).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF4F46E5),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'PROFESSIONAL',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4F46E5),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Summary Section
                  if (summary.isNotEmpty) ...[
                    _buildSectionTitle('SUMMARY'),
                    const SizedBox(height: 12),
                    Text(
                      summary,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4B5563),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Experience Section
                  if (experience.isNotEmpty) ...[
                    _buildSectionTitle('WORK HISTORY'),
                    const SizedBox(height: 12),
                    ...experience.map((exp) => _buildExperienceItem(exp)),
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
                    ...projects.map((project) => _buildProjectItem(project)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contact = widget.resumeData['contact'] as Map<String, dynamic>? ?? {};
    final summary = widget.resumeData['summary'] as String? ?? '';
    final skills = widget.resumeData['skills'] as List? ?? [];
    final experience = widget.resumeData['experience'] as List? ?? [];
    final education = widget.resumeData['education'] as List? ?? [];
    final projects = widget.resumeData['projects'] as List? ?? [];
    final template =
        widget.selectedTemplate ??
        widget.resumeData['template'] as String? ??
        'classic_left';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Preview'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _isLoading ? null : _downloadPdf,
            tooltip: 'Download PDF',
          ),
        ],
      ),
      backgroundColor: const Color(0xFFf8f9fa),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: AspectRatio(
            aspectRatio: 210 / 400,
            child: Container(
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
              child: _buildResumeContent(
                contact: contact,
                summary: summary,
                skills: skills,
                experience: experience,
                education: education,
                projects: projects,
                template: template,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods for building sections
  Widget _buildSidebarTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF1F2937),
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildContactSection(
    Map<String, dynamic> contact, {
    bool dark = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (contact['location'] != null)
          _buildContactItem(contact['location'].toString(), dark),
        if (contact['phone'] != null)
          _buildContactItem(contact['phone'].toString(), dark),
        if (contact['email'] != null)
          _buildContactItem(contact['email'].toString(), dark),
        if (contact['linkedin'] != null)
          _buildContactItem(contact['linkedin'].toString(), dark, isLink: true),
        if (contact['github'] != null)
          _buildContactItem(contact['github'].toString(), dark, isLink: true),
      ],
    );
  }

  Widget _buildContactItem(String text, bool dark, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dark ? Colors.white : const Color(0xFF4B5563),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: dark ? Colors.white : const Color(0xFF4B5563),
                fontSize: 12,
                fontWeight: isLink ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsList(List skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: skills.map((skill) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  skill.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  exp['title']?.toString().toLowerCase() ?? 'job title',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              if (exp['duration'] != null)
                Text(
                  exp['duration'].toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
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
                fontSize: 12,
                color: Color(0xFF4F46E5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (exp['description'] != null) ...[
            const SizedBox(height: 8),
            _buildDescriptionWithBullets(exp['description'].toString()),
          ],
        ],
      ),
    );
  }

  Widget _buildDescriptionWithBullets(String description) {
    // Split description by common bullet point indicators
    final lines = description
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final cleanLine = line.replaceAll(RegExp(r'^[-•*]\s*'), '').trim();
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 6, right: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF4B5563),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  cleanLine,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSingleColumnTemplate({
    required Map<String, dynamic> contact,
    required String summary,
    required List skills,
    required List experience,
    required List education,
    required List projects,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name, title, and contact info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Name and title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact['name']?.toString().toUpperCase() ??
                            'YOUR NAME',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contact['title']?.toString() ?? 'PROFESSIONAL',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4B5563),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Right side - Contact information
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (contact['email'] != null)
                      _buildSingleColumnContactItem(
                        Icons.email_outlined,
                        contact['email'].toString(),
                      ),
                    if (contact['phone'] != null)
                      _buildSingleColumnContactItem(
                        Icons.phone_outlined,
                        contact['phone'].toString(),
                      ),
                    if (contact['location'] != null)
                      _buildSingleColumnContactItem(
                        Icons.location_on_outlined,
                        contact['location'].toString(),
                      ),
                    if (contact['linkedin'] != null)
                      _buildSingleColumnContactItem(
                        Icons.link,
                        contact['linkedin'].toString(),
                        isLink: true,
                      ),
                    if (contact['github'] != null)
                      _buildSingleColumnContactItem(
                        Icons.code,
                        contact['github'].toString(),
                        isLink: true,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Summary Section
            if (summary.isNotEmpty) ...[
              _buildSingleColumnSectionTitle('Summary'),
              const SizedBox(height: 12),
              Text(
                summary,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4B5563),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Work Experience Section
            if (experience.isNotEmpty) ...[
              _buildSingleColumnSectionTitle('Work Experience'),
              const SizedBox(height: 12),
              ...experience.map((exp) => _buildSingleColumnExperienceItem(exp)),
              const SizedBox(height: 24),
            ],

            // Education Section
            if (education.isNotEmpty) ...[
              _buildSingleColumnSectionTitle('Education'),
              const SizedBox(height: 12),
              ...education.map((edu) => _buildSingleColumnEducationItem(edu)),
              const SizedBox(height: 24),
            ],

            // Skills Section
            if (skills.isNotEmpty) ...[
              _buildSingleColumnSectionTitle('Skills'),
              const SizedBox(height: 12),
              _buildSingleColumnSkillsList(skills),
              const SizedBox(height: 24),
            ],

            // Projects Section
            if (projects.isNotEmpty) ...[
              _buildSingleColumnSectionTitle('Projects'),
              const SizedBox(height: 12),
              ...projects.map(
                (project) => _buildSingleColumnProjectItem(project),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSingleColumnContactItem(
    IconData icon,
    String text, {
    bool isLink = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF4B5563)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isLink ? const Color(0xFF3182ce) : const Color(0xFF4B5563),
              fontWeight: isLink ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleColumnSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF3182ce),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSingleColumnExperienceItem(Map<String, dynamic> exp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${exp['title'] ?? ''} - ${exp['company'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              Text(
                exp['duration'] ?? '',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          if (exp['location'] != null) ...[
            const SizedBox(height: 2),
            Text(
              exp['location'].toString(),
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
          if (exp['description'] != null &&
              exp['description'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildSingleColumnDescriptionWithBullets(
              exp['description'].toString(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSingleColumnEducationItem(Map<String, dynamic> edu) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${edu['degree'] ?? ''} - ${edu['school'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              Text(
                edu['year'] ?? '',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          if (edu['location'] != null) ...[
            const SizedBox(height: 2),
            Text(
              edu['location'].toString(),
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSingleColumnSkillsList(List skills) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: skills.map((skill) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(
            skill.toString(),
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSingleColumnProjectItem(Map<String, dynamic> project) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project['title'] ?? '',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          if (project['description'] != null &&
              project['description'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildSingleColumnDescriptionWithBullets(
              project['description'].toString(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSingleColumnDescriptionWithBullets(String description) {
    final lines = description
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final cleanLine = line.replaceAll(RegExp(r'^[-•*]\s*'), '').trim();
        return Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 6, right: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF4B5563),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  cleanLine,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAcademicTemplate({
    required Map<String, dynamic> contact,
    required String summary,
    required List skills,
    required List experience,
    required List education,
    required List projects,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name, title, and contact info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Name and title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact['name']?.toString().toUpperCase() ??
                            'YOUR NAME',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contact['title']?.toString().toUpperCase() ??
                            'PROFESSIONAL',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4B5563),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Right side - Contact information
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (contact['phone'] != null)
                      _buildAcademicContactItem(
                        Icons.phone_outlined,
                        contact['phone'].toString(),
                      ),
                    if (contact['email'] != null)
                      _buildAcademicContactItem(
                        Icons.email_outlined,
                        contact['email'].toString(),
                      ),
                    if (contact['location'] != null)
                      _buildAcademicContactItem(
                        Icons.location_on_outlined,
                        contact['location'].toString(),
                      ),
                    if (contact['linkedin'] != null)
                      _buildAcademicContactItem(
                        Icons.link,
                        contact['linkedin'].toString(),
                        isLink: true,
                      ),
                    if (contact['github'] != null)
                      _buildAcademicContactItem(
                        Icons.code,
                        contact['github'].toString(),
                        isLink: true,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Main content with two columns
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column - Education, Skills, Awards
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Education Section
                      if (education.isNotEmpty) ...[
                        _buildAcademicSectionTitle('EDUCATION'),
                        const SizedBox(height: 12),
                        ...education.map(
                          (edu) => _buildAcademicEducationItem(edu),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Skills Section
                      if (skills.isNotEmpty) ...[
                        _buildAcademicSectionTitle('SKILLS'),
                        const SizedBox(height: 12),
                        _buildAcademicSkillsList(skills),
                        const SizedBox(height: 24),
                      ],

                      // Projects Section
                      if (projects.isNotEmpty) ...[
                        _buildAcademicSectionTitle('PROJECTS'),
                        const SizedBox(height: 12),
                        ...projects.map(
                          (project) => _buildAcademicProjectItem(project),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                // Right column - Career Objective, Experience
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Career Objective Section (using summary)
                      if (summary.isNotEmpty) ...[
                        _buildAcademicSectionTitle('CAREER OBJECTIVE'),
                        const SizedBox(height: 12),
                        Text(
                          summary,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4B5563),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Experience Section
                      if (experience.isNotEmpty) ...[
                        _buildAcademicSectionTitle('EXPERIENCE'),
                        const SizedBox(height: 12),
                        ...experience.map(
                          (exp) => _buildAcademicExperienceItem(exp),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicContactItem(
    IconData icon,
    String text, {
    bool isLink = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF4B5563)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isLink ? const Color(0xFF3182ce) : const Color(0xFF4B5563),
              fontWeight: isLink ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildAcademicEducationItem(Map<String, dynamic> edu) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${edu['degree'] ?? ''} | ${edu['year'] ?? ''}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            edu['school'] ?? '',
            style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563)),
          ),
          if (edu['location'] != null) ...[
            const SizedBox(height: 2),
            Text(
              edu['location'].toString(),
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAcademicSkillsList(List skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: skills.map((skill) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 6, right: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF1F2937),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  skill.toString(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAcademicProjectItem(Map<String, dynamic> project) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project['title'] ?? '',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            project['duration'] ?? '',
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
          if (project['description'] != null &&
              project['description'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildAcademicDescriptionWithBullets(
              project['description'].toString(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAcademicExperienceItem(Map<String, dynamic> exp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exp['title'] ?? '',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${exp['duration'] ?? ''}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
          if (exp['description'] != null &&
              exp['description'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildAcademicDescriptionWithBullets(exp['description'].toString()),
          ],
        ],
      ),
    );
  }

  Widget _buildAcademicDescriptionWithBullets(String description) {
    final lines = description
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final cleanLine = line.replaceAll(RegExp(r'^[-•*]\s*'), '').trim();
        return Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 6, right: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF4B5563),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  cleanLine,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProfessionalTemplate({
    required Map<String, dynamic> contact,
    required String summary,
    required List skills,
    required List experience,
    required List education,
    required List projects,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with beige background
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFFE8DDCB)),
              child: Column(
                children: [
                  // Name
                  Text(
                    contact['name']?.toString().toUpperCase() ?? 'YOUR NAME',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  // Job Title
                  Text(
                    contact['title']?.toString().toUpperCase() ?? 'JOB TITLE',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Contact Information Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (contact['phone'] != null)
                        Text(
                          contact['phone'].toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF1F2937),
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else
                        const SizedBox(),
                      if (contact['email'] != null)
                        Text(
                          contact['email'].toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF1F2937),
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else
                        const SizedBox(),
                      if (contact['location'] != null)
                        Text(
                          contact['location'].toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF1F2937),
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else
                        const SizedBox(),
                    ],
                  ),
                  if (contact['linkedin'] != null) ...[
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'LinkedIn',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF0077B5),
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                  if (contact['github'] != null) ...[
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'GitHub',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF333333),
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary/Objective Section
                  if (summary.isNotEmpty) ...[
                    _buildProfessionalSectionTitle('Summary/Objective'),
                    const SizedBox(height: 8),
                    Text(
                      summary,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF4B5563),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Skills Section
                  if (skills.isNotEmpty) ...[
                    _buildProfessionalSectionTitle('Skills'),
                    const SizedBox(height: 8),
                    _buildProfessionalSkillsList(skills),
                    const SizedBox(height: 16),
                  ],

                  // Work Experience Section
                  if (experience.isNotEmpty) ...[
                    _buildProfessionalSectionTitle('Work Experience'),
                    const SizedBox(height: 8),
                    ...experience.map(
                      (exp) => _buildProfessionalExperienceItem(exp),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Education Section
                  if (education.isNotEmpty) ...[
                    _buildProfessionalSectionTitle('Education'),
                    const SizedBox(height: 8),
                    ...education.map(
                      (edu) => _buildProfessionalEducationItem(edu),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Projects Section
                  if (projects.isNotEmpty) ...[
                    _buildProfessionalSectionTitle('Projects'),
                    const SizedBox(height: 8),
                    ...projects.map(
                      (project) => _buildProfessionalProjectItem(project),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          height: 1,
          width: double.infinity,
          color: const Color(0xFF4B5563),
        ),
      ],
    );
  }

  Widget _buildProfessionalSkillsList(List skills) {
    return Wrap(
      spacing: 6,
      runSpacing: 3,
      children: skills.map((skill) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(
            skill.toString(),
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProfessionalExperienceItem(Map<String, dynamic> exp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exp['title'] ?? '',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            '${exp['company'] ?? ''} | ${exp['location'] ?? ''} | ${exp['duration'] ?? ''}',
            style: const TextStyle(fontSize: 10, color: Color(0xFF4B5563)),
          ),
          if (exp['description'] != null &&
              exp['description'].toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            _buildProfessionalDescriptionWithBullets(
              exp['description'].toString(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfessionalEducationItem(Map<String, dynamic> edu) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            edu['school'] ?? '',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            '${edu['degree'] ?? ''}, ${edu['year'] ?? ''}',
            style: const TextStyle(fontSize: 10, color: Color(0xFF4B5563)),
          ),
          if (edu['location'] != null) ...[
            const SizedBox(height: 1),
            Text(
              edu['location'].toString(),
              style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfessionalProjectItem(Map<String, dynamic> project) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project['title'] ?? '',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            project['duration'] ?? '',
            style: const TextStyle(fontSize: 10, color: Color(0xFF4B5563)),
          ),
          if (project['description'] != null &&
              project['description'].toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            _buildProfessionalDescriptionWithBullets(
              project['description'].toString(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfessionalDescriptionWithBullets(String description) {
    final lines = description
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final cleanLine = line.replaceAll(RegExp(r'^[-•*]\s*'), '').trim();
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 3,
                height: 3,
                margin: const EdgeInsets.only(top: 4, right: 6),
                decoration: const BoxDecoration(
                  color: Color(0xFF4B5563),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  cleanLine,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF4B5563),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEducationItem(Map<String, dynamic> edu) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  edu['degree']?.toString().toUpperCase() ?? 'DEGREE',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                if (edu['institution'] != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    edu['institution'].toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (edu['year'] != null)
            Text(
              edu['year'].toString(),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  project['title']?.toString().toUpperCase() ?? 'PROJECT',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              if (project['year'] != null || project['duration'] != null)
                Text(
                  project['year']?.toString() ??
                      project['duration']?.toString() ??
                      '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
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
                fontSize: 12,
                color: Color(0xFF4F46E5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (project['description'] != null) ...[
            const SizedBox(height: 8),
            _buildDescriptionWithBullets(project['description'].toString()),
          ],
        ],
      ),
    );
  }

  // PDF Generation methods
  Future<void> _downloadPdf() async {
    try {
      final contact =
          widget.resumeData['contact'] as Map<String, dynamic>? ?? {};
      final summary = widget.resumeData['summary'] as String? ?? '';
      final skills = widget.resumeData['skills'] as List? ?? [];
      final experience = widget.resumeData['experience'] as List? ?? [];
      final education = widget.resumeData['education'] as List? ?? [];
      final projects = widget.resumeData['projects'] as List? ?? [];
      final template =
          widget.selectedTemplate ??
          widget.resumeData['template'] ??
          'classic_left';
      final doc = pw.Document();

      switch (template) {
        case 'single_column':
          await _generateSingleColumnPdf(
            doc,
            contact,
            summary,
            skills,
            experience,
            education,
            projects,
          );
          break;
        case 'academic':
          await _generateAcademicPdf(
            doc,
            contact,
            summary,
            skills,
            experience,
            education,
            projects,
          );
          break;
        case 'professional':
          await _generateProfessionalPdf(
            doc,
            contact,
            summary,
            skills,
            experience,
            education,
            projects,
          );
          break;
        case 'classic_left':
        default:
          await _generateClassicPdf(
            doc,
            contact,
            summary,
            skills,
            experience,
            education,
            projects,
          );
          break;
      }

      // First open PDF in viewer, then provide sharing options
      if (kIsWeb) {
        // For web, open PDF in new tab
        await Printing.layoutPdf(
          onLayout: (pwlib.PdfPageFormat format) async => doc.save(),
        );
      } else {
        // For mobile/desktop, first open PDF in viewer
        await Printing.layoutPdf(
          onLayout: (pwlib.PdfPageFormat format) async => doc.save(),
        );

        // Then show sharing options after a short delay
        await Future.delayed(const Duration(milliseconds: 1000));

        if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
          await Printing.sharePdf(
            bytes: await doc.save(),
            filename: 'resume.pdf',
          );
        } else {
          // Windows/Linux
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/resume.pdf');
          await file.writeAsBytes(await doc.save());
          await Share.shareXFiles([XFile(file.path)]);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resume downloaded successfully!'),
            backgroundColor: Color(0xFF48bb78),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateClassicPdf(
    pw.Document doc,
    Map<String, dynamic> contact,
    String summary,
    List skills,
    List experience,
    List education,
    List projects,
  ) async {
    final accent = pwlib.PdfColor.fromInt(0xFF4F46E5);
    final darkBlue = pwlib.PdfColor.fromInt(0xFF123B63);

    doc.addPage(
      pw.MultiPage(
        pageFormat: pwlib.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return [
            pw.Container(
              height: pwlib.PdfPageFormat.a4.height,
              child: pw.Row(
                children: [
                  // Left sidebar
                  pw.Container(
                    width: 160,
                    decoration: pw.BoxDecoration(color: darkBlue),
                    padding: const pw.EdgeInsets.all(20),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Name at top
                        pw.Center(
                          child: pw.Text(
                            (contact['name'] ?? 'YOUR NAME')
                                .toString()
                                .toUpperCase(),
                            style: pw.TextStyle(
                              color: pwlib.PdfColors.white,
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.SizedBox(height: 20),

                        // Profile picture placeholder
                        pw.Center(
                          child: pw.Container(
                            width: 80,
                            height: 80,
                            decoration: pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                              border: pw.Border.all(
                                color: pwlib.PdfColors.white,
                                width: 2,
                              ),
                              color: pwlib.PdfColor.fromInt(0x1AFFFFFF),
                            ),
                            child: pw.Center(
                              child: pw.Container(
                                width: 50,
                                height: 50,
                                decoration: pw.BoxDecoration(
                                  color: pwlib.PdfColors.white,
                                  shape: pw.BoxShape.circle,
                                ),
                                child: pw.Center(
                                  child: pw.Text(
                                    'X',
                                    style: pw.TextStyle(
                                      fontSize: 24,
                                      color: pwlib.PdfColor.fromInt(0xFF123B63),
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 20),

                        // Contact Section
                        _buildPdfSectionTitle('Contact', white: true),
                        pw.SizedBox(height: 12),
                        if (contact['location'] != null)
                          _buildPdfContactItem(
                            '📍',
                            contact['location'].toString(),
                          ),
                        if (contact['phone'] != null)
                          _buildPdfContactItem(
                            '📞',
                            contact['phone'].toString(),
                          ),
                        if (contact['email'] != null)
                          _buildPdfContactItem(
                            '✉️',
                            contact['email'].toString(),
                          ),
                        if (contact['linkedin'] != null)
                          _buildPdfContactItem(
                            '🔗',
                            contact['linkedin'].toString(),
                          ),
                        if (contact['github'] != null)
                          _buildPdfContactItem(
                            '💻',
                            contact['github'].toString(),
                          ),
                        pw.SizedBox(height: 20),

                        // Skills Section
                        if (skills.isNotEmpty) ...[
                          _buildPdfSectionTitle('Skills', white: true),
                          pw.SizedBox(height: 12),
                          _buildPdfSkillsList(skills.take(10).toList()),
                        ],
                      ],
                    ),
                  ),

                  // Right content
                  pw.Expanded(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.all(20),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Header
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Expanded(
                                child: pw.Text(
                                  (contact['name'] ?? 'YOUR NAME')
                                      .toString()
                                      .toUpperCase(),
                                  style: pw.TextStyle(
                                    fontSize: 20,
                                    fontWeight: pw.FontWeight.bold,
                                    color: pwlib.PdfColor.fromInt(0xFF1F2937),
                                  ),
                                ),
                              ),
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: pw.BoxDecoration(
                                  color: pwlib.PdfColor.fromInt(0x1A4F46E5),
                                  borderRadius: pw.BorderRadius.circular(15),
                                  border: pw.Border.all(
                                    color: accent,
                                    width: 1,
                                  ),
                                ),
                                child: pw.Text(
                                  'PROFESSIONAL',
                                  style: pw.TextStyle(
                                    color: accent,
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 16),

                          // Summary
                          if (summary.isNotEmpty) ...[
                            _buildPdfSectionTitle('SUMMARY'),
                            pw.SizedBox(height: 8),
                            pw.Text(
                              summary,
                              style: pw.TextStyle(
                                fontSize: 11,
                                color: pwlib.PdfColor.fromInt(0xFF4B5563),
                                height: 1.4,
                              ),
                            ),
                            pw.SizedBox(height: 16),
                          ],

                          // Experience
                          if (experience.isNotEmpty) ...[
                            _buildPdfSectionTitle('WORK HISTORY'),
                            pw.SizedBox(height: 8),
                            ...experience
                                .take(3)
                                .map((exp) => _buildPdfExperienceItem(exp)),
                            pw.SizedBox(height: 16),
                          ],

                          // Education
                          if (education.isNotEmpty) ...[
                            _buildPdfSectionTitle('EDUCATION'),
                            pw.SizedBox(height: 8),
                            ...education.map(
                              (edu) => _buildPdfEducationItem(edu),
                            ),
                            pw.SizedBox(height: 16),
                          ],

                          // Projects
                          if (projects.isNotEmpty) ...[
                            _buildPdfSectionTitle('PROJECTS'),
                            pw.SizedBox(height: 8),
                            ...projects
                                .take(2)
                                .map(
                                  (project) => _buildPdfProjectItem(project),
                                ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );
  }

  Future<void> _generateSingleColumnPdf(
    pw.Document doc,
    Map<String, dynamic> contact,
    String summary,
    List skills,
    List experience,
    List education,
    List projects,
  ) async {
    doc.addPage(
      pw.MultiPage(
        pageFormat: pwlib.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return [
            // Header with name, title, and contact info
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Left side - Name and title
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        (contact['name'] ?? 'YOUR NAME')
                            .toString()
                            .toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: pwlib.PdfColor.fromInt(0xFF1F2937),
                          letterSpacing: 1.2,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        (contact['title'] ?? 'PROFESSIONAL').toString(),
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: pwlib.PdfColor.fromInt(0xFF4B5563),
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Right side - Contact information
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    if (contact['email'] != null)
                      _buildPdfSingleColumnContactItem(
                        '✉️',
                        contact['email'].toString(),
                      ),
                    if (contact['phone'] != null)
                      _buildPdfSingleColumnContactItem(
                        '📞',
                        contact['phone'].toString(),
                      ),
                    if (contact['location'] != null)
                      _buildPdfSingleColumnContactItem(
                        '📍',
                        contact['location'].toString(),
                      ),
                    if (contact['linkedin'] != null)
                      _buildPdfSingleColumnContactItem(
                        '🔗',
                        contact['linkedin'].toString(),
                        isLink: true,
                      ),
                    if (contact['github'] != null)
                      _buildPdfSingleColumnContactItem(
                        '💻',
                        contact['github'].toString(),
                        isLink: true,
                      ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 24),

            // Summary Section
            if (summary.isNotEmpty) ...[
              _buildPdfSingleColumnSectionTitle('Summary'),
              pw.SizedBox(height: 12),
              pw.Text(
                summary,
                style: pw.TextStyle(
                  fontSize: 12,
                  color: pwlib.PdfColor.fromInt(0xFF4B5563),
                  height: 1.5,
                ),
              ),
              pw.SizedBox(height: 24),
            ],

            // Work Experience Section
            if (experience.isNotEmpty) ...[
              _buildPdfSingleColumnSectionTitle('Work Experience'),
              pw.SizedBox(height: 12),
              ...experience.map(
                (exp) => _buildPdfSingleColumnExperienceItem(exp),
              ),
              pw.SizedBox(height: 24),
            ],

            // Education Section
            if (education.isNotEmpty) ...[
              _buildPdfSingleColumnSectionTitle('Education'),
              pw.SizedBox(height: 12),
              ...education.map(
                (edu) => _buildPdfSingleColumnEducationItem(edu),
              ),
              pw.SizedBox(height: 24),
            ],

            // Skills Section
            if (skills.isNotEmpty) ...[
              _buildPdfSingleColumnSectionTitle('Skills'),
              pw.SizedBox(height: 12),
              _buildPdfSingleColumnSkillsList(skills),
              pw.SizedBox(height: 24),
            ],

            // Projects Section
            if (projects.isNotEmpty) ...[
              _buildPdfSingleColumnSectionTitle('Projects'),
              pw.SizedBox(height: 12),
              ...projects.map(
                (project) => _buildPdfSingleColumnProjectItem(project),
              ),
            ],
          ];
        },
      ),
    );
  }

  Future<void> _generateAcademicPdf(
    pw.Document doc,
    Map<String, dynamic> contact,
    String summary,
    List skills,
    List experience,
    List education,
    List projects,
  ) async {
    doc.addPage(
      pw.MultiPage(
        pageFormat: pwlib.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return [
            // Header with name, title, and contact info
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Left side - Name and title
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        (contact['name'] ?? 'YOUR NAME')
                            .toString()
                            .toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: pwlib.PdfColor.fromInt(0xFF1F2937),
                          letterSpacing: 1.2,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        (contact['title'] ?? 'PROFESSIONAL')
                            .toString()
                            .toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: pwlib.PdfColor.fromInt(0xFF4B5563),
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Right side - Contact information
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    if (contact['phone'] != null)
                      _buildPdfAcademicContactItem(
                        '📞',
                        contact['phone'].toString(),
                      ),
                    if (contact['email'] != null)
                      _buildPdfAcademicContactItem(
                        '✉️',
                        contact['email'].toString(),
                      ),
                    if (contact['location'] != null)
                      _buildPdfAcademicContactItem(
                        '📍',
                        contact['location'].toString(),
                      ),
                    if (contact['linkedin'] != null)
                      _buildPdfAcademicContactItem(
                        '🔗',
                        contact['linkedin'].toString(),
                        isLink: true,
                      ),
                    if (contact['github'] != null)
                      _buildPdfAcademicContactItem(
                        '💻',
                        contact['github'].toString(),
                        isLink: true,
                      ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 24),

            // Main content with two columns
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Left column - Education, Skills, Awards
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Education Section
                      if (education.isNotEmpty) ...[
                        _buildPdfAcademicSectionTitle('EDUCATION'),
                        pw.SizedBox(height: 12),
                        ...education.map(
                          (edu) => _buildPdfAcademicEducationItem(edu),
                        ),
                        pw.SizedBox(height: 24),
                      ],

                      // Skills Section
                      if (skills.isNotEmpty) ...[
                        _buildPdfAcademicSectionTitle('SKILLS'),
                        pw.SizedBox(height: 12),
                        _buildPdfAcademicSkillsList(skills),
                        pw.SizedBox(height: 24),
                      ],

                      // Projects Section
                      if (projects.isNotEmpty) ...[
                        _buildPdfAcademicSectionTitle('PROJECTS'),
                        pw.SizedBox(height: 12),
                        ...projects.map(
                          (project) => _buildPdfAcademicProjectItem(project),
                        ),
                      ],
                    ],
                  ),
                ),

                pw.SizedBox(width: 24),

                // Right column - Career Objective, Experience
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Career Objective Section (using summary)
                      if (summary.isNotEmpty) ...[
                        _buildPdfAcademicSectionTitle('CAREER OBJECTIVE'),
                        pw.SizedBox(height: 12),
                        pw.Text(
                          summary,
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: pwlib.PdfColor.fromInt(0xFF4B5563),
                            height: 1.5,
                          ),
                        ),
                        pw.SizedBox(height: 24),
                      ],

                      // Experience Section
                      if (experience.isNotEmpty) ...[
                        _buildPdfAcademicSectionTitle('EXPERIENCE'),
                        pw.SizedBox(height: 12),
                        ...experience.map(
                          (exp) => _buildPdfAcademicExperienceItem(exp),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );
  }

  Future<void> _generateProfessionalPdf(
    pw.Document doc,
    Map<String, dynamic> contact,
    String summary,
    List skills,
    List experience,
    List education,
    List projects,
  ) async {
    doc.addPage(
      pw.MultiPage(
        pageFormat: pwlib.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return [
            // Header with beige background
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: pwlib.PdfColor.fromInt(0xFFE8DDCB),
              ),
              child: pw.Column(
                children: [
                  // Name
                  pw.Text(
                    (contact['name'] ?? 'YOUR NAME').toString().toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: pwlib.PdfColors.white,
                      letterSpacing: 1.2,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 4),
                  // Job Title
                  pw.Text(
                    (contact['title'] ?? 'JOB TITLE').toString().toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: pwlib.PdfColors.white,
                      letterSpacing: 1.0,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 8),
                  // Contact Information Bar
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      if (contact['phone'] != null)
                        pw.Text(
                          contact['phone'].toString(),
                          style: pw.TextStyle(
                            fontSize: 11,
                            color: pwlib.PdfColor.fromInt(0xFF1F2937),
                            fontWeight: pw.FontWeight.bold,
                          ),
                        )
                      else
                        pw.SizedBox(),
                      if (contact['email'] != null)
                        pw.Text(
                          contact['email'].toString(),
                          style: pw.TextStyle(
                            fontSize: 11,
                            color: pwlib.PdfColor.fromInt(0xFF1F2937),
                            fontWeight: pw.FontWeight.bold,
                          ),
                        )
                      else
                        pw.SizedBox(),
                      if (contact['location'] != null)
                        pw.Text(
                          contact['location'].toString(),
                          style: pw.TextStyle(
                            fontSize: 11,
                            color: pwlib.PdfColor.fromInt(0xFF1F2937),
                            fontWeight: pw.FontWeight.bold,
                          ),
                        )
                      else
                        pw.SizedBox(),
                    ],
                  ),
                  if (contact['linkedin'] != null) ...[
                    pw.SizedBox(height: 4),
                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        'LinkedIn',
                        style: pw.TextStyle(
                          fontSize: 11,
                          color: pwlib.PdfColor.fromInt(0xFF0077B5),
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  if (contact['github'] != null) ...[
                    pw.SizedBox(height: 4),
                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        'GitHub',
                        style: pw.TextStyle(
                          fontSize: 11,
                          color: pwlib.PdfColor.fromInt(0xFF333333),
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Main content
            pw.Padding(
              padding: const pw.EdgeInsets.all(16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Summary/Objective Section
                  if (summary.isNotEmpty) ...[
                    _buildPdfProfessionalSectionTitle('Summary/Objective'),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      summary,
                      style: pw.TextStyle(
                        fontSize: 11,
                        color: pwlib.PdfColor.fromInt(0xFF4B5563),
                        height: 1.4,
                      ),
                    ),
                    pw.SizedBox(height: 16),
                  ],

                  // Skills Section
                  if (skills.isNotEmpty) ...[
                    _buildPdfProfessionalSectionTitle('Skills'),
                    pw.SizedBox(height: 8),
                    _buildPdfProfessionalSkillsList(skills),
                    pw.SizedBox(height: 16),
                  ],

                  // Work Experience Section
                  if (experience.isNotEmpty) ...[
                    _buildPdfProfessionalSectionTitle('Work Experience'),
                    pw.SizedBox(height: 8),
                    ...experience.map(
                      (exp) => _buildPdfProfessionalExperienceItem(exp),
                    ),
                    pw.SizedBox(height: 16),
                  ],

                  // Education Section
                  if (education.isNotEmpty) ...[
                    _buildPdfProfessionalSectionTitle('Education'),
                    pw.SizedBox(height: 8),
                    ...education.map(
                      (edu) => _buildPdfProfessionalEducationItem(edu),
                    ),
                    pw.SizedBox(height: 16),
                  ],

                  // Projects Section
                  if (projects.isNotEmpty) ...[
                    _buildPdfProfessionalSectionTitle('Projects'),
                    pw.SizedBox(height: 8),
                    ...projects.map(
                      (project) => _buildPdfProfessionalProjectItem(project),
                    ),
                  ],
                ],
              ),
            ),
          ];
        },
      ),
    );
  }

  // PDF helper methods
  pw.Widget _buildPdfSectionTitle(String title, {bool white = false}) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        color: white
            ? pwlib.PdfColors.white
            : pwlib.PdfColor.fromInt(0xFF1F2937),
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  pw.Widget _buildPdfContactItem(String icon, String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        children: [
          pw.Container(
            width: 12,
            height: 12,
            decoration: pw.BoxDecoration(
              color: pwlib.PdfColors.white,
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Text(
              text,
              style: pw.TextStyle(color: pwlib.PdfColors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfSkillsList(List skills) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: skills.map((skill) {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Row(
            children: [
              pw.Container(
                width: 6,
                height: 6,
                decoration: pw.BoxDecoration(
                  color: pwlib.PdfColors.white,
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Text(
                  skill.toString(),
                  style: pw.TextStyle(
                    color: pwlib.PdfColors.white,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _buildPdfExperienceItem(Map<String, dynamic> exp) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  (exp['title'] ?? 'job title').toString().toLowerCase(),
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: pwlib.PdfColor.fromInt(0xFF1F2937),
                  ),
                ),
              ),
              if (exp['duration'] != null)
                pw.Text(
                  exp['duration'].toString(),
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: pwlib.PdfColor.fromInt(0xFF6B7280),
                  ),
                ),
            ],
          ),
          if (exp['company'] != null) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              exp['company'].toString(),
              style: pw.TextStyle(
                fontSize: 10,
                color: pwlib.PdfColor.fromInt(0xFF4F46E5),
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
          if (exp['description'] != null) ...[
            pw.SizedBox(height: 6),
            _buildPdfDescriptionWithBullets(exp['description'].toString()),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildPdfEducationItem(Map<String, dynamic> edu) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  (edu['degree'] ?? 'DEGREE').toString().toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: pwlib.PdfColor.fromInt(0xFF1F2937),
                  ),
                ),
                if (edu['institution'] != null) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    edu['institution'].toString(),
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: pwlib.PdfColor.fromInt(0xFF4F46E5),
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (edu['year'] != null)
            pw.Text(
              edu['year'].toString(),
              style: pw.TextStyle(
                fontSize: 10,
                color: pwlib.PdfColor.fromInt(0xFF6B7280),
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfProjectItem(Map<String, dynamic> project) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  (project['title'] ?? 'PROJECT').toString().toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: pwlib.PdfColor.fromInt(0xFF1F2937),
                  ),
                ),
              ),
              if (project['year'] != null || project['duration'] != null)
                pw.Text(
                  project['year']?.toString() ??
                      project['duration']?.toString() ??
                      '',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: pwlib.PdfColor.fromInt(0xFF6B7280),
                  ),
                ),
            ],
          ),
          if (project['technologies'] != null) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              project['technologies'].toString(),
              style: pw.TextStyle(
                fontSize: 10,
                color: pwlib.PdfColor.fromInt(0xFF4F46E5),
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
          if (project['description'] != null) ...[
            pw.SizedBox(height: 6),
            _buildPdfDescriptionWithBullets(project['description'].toString()),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildPdfDescriptionWithBullets(String description) {
    final lines = description
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: lines.map((line) {
        final cleanLine = line.replaceAll(RegExp(r'^[-•*]\s*'), '').trim();
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 6,
                height: 6,
                margin: const pw.EdgeInsets.only(top: 6, right: 8),
                decoration: pw.BoxDecoration(
                  color: pwlib.PdfColor.fromInt(0xFF4B5563),
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  cleanLine,
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: pwlib.PdfColor.fromInt(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Single Column PDF helper methods
  pw.Widget _buildPdfSingleColumnContactItem(
    String icon,
    String text, {
    bool isLink = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(icon, style: pw.TextStyle(fontSize: 12)),
          pw.SizedBox(width: 6),
          pw.Text(
            text,
            style: pw.TextStyle(
              fontSize: 12,
              color: isLink
                  ? pwlib.PdfColor.fromInt(0xFF3182ce)
                  : pwlib.PdfColor.fromInt(0xFF4B5563),
              fontWeight: isLink ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfSingleColumnSectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 16,
        fontWeight: pw.FontWeight.bold,
        color: pwlib.PdfColor.fromInt(0xFF3182ce),
        letterSpacing: 0.5,
      ),
    );
  }

  pw.Widget _buildPdfSingleColumnExperienceItem(Map<String, dynamic> exp) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  '${exp['title'] ?? ''} - ${exp['company'] ?? ''}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: pwlib.PdfColor.fromInt(0xFF1F2937),
                  ),
                ),
              ),
              pw.Text(
                exp['duration'] ?? '',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: pwlib.PdfColor.fromInt(0xFF6B7280),
                ),
              ),
            ],
          ),
          if (exp['location'] != null) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              exp['location'].toString(),
              style: pw.TextStyle(
                fontSize: 12,
                color: pwlib.PdfColor.fromInt(0xFF6B7280),
              ),
            ),
          ],
          if (exp['description'] != null &&
              exp['description'].toString().isNotEmpty) ...[
            pw.SizedBox(height: 8),
            _buildPdfSingleColumnDescriptionWithBullets(
              exp['description'].toString(),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildPdfSingleColumnEducationItem(Map<String, dynamic> edu) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  '${edu['degree'] ?? ''} - ${edu['school'] ?? ''}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: pwlib.PdfColor.fromInt(0xFF1F2937),
                  ),
                ),
              ),
              pw.Text(
                edu['year'] ?? '',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: pwlib.PdfColor.fromInt(0xFF6B7280),
                ),
              ),
            ],
          ),
          if (edu['location'] != null) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              edu['location'].toString(),
              style: pw.TextStyle(
                fontSize: 12,
                color: pwlib.PdfColor.fromInt(0xFF6B7280),
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildPdfSingleColumnSkillsList(List skills) {
    return pw.Wrap(
      spacing: 8,
      runSpacing: 4,
      children: skills.map((skill) {
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(
            color: pwlib.PdfColor.fromInt(0xFFF3F4F6),
            borderRadius: pw.BorderRadius.circular(12),
            border: pw.Border.all(color: pwlib.PdfColor.fromInt(0xFFE5E7EB)),
          ),
          child: pw.Text(
            skill.toString(),
            style: pw.TextStyle(
              fontSize: 11,
              color: pwlib.PdfColor.fromInt(0xFF374151),
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _buildPdfSingleColumnProjectItem(Map<String, dynamic> project) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            project['title'] ?? '',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: pwlib.PdfColor.fromInt(0xFF1F2937),
            ),
          ),
          if (project['description'] != null &&
              project['description'].toString().isNotEmpty) ...[
            pw.SizedBox(height: 8),
            _buildPdfSingleColumnDescriptionWithBullets(
              project['description'].toString(),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildPdfSingleColumnDescriptionWithBullets(String description) {
    final lines = description
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: lines.map((line) {
        final cleanLine = line.replaceAll(RegExp(r'^[-•*]\s*'), '').trim();
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 3),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 4,
                height: 4,
                margin: const pw.EdgeInsets.only(top: 6, right: 8),
                decoration: pw.BoxDecoration(
                  color: pwlib.PdfColor.fromInt(0xFF4B5563),
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  cleanLine,
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: pwlib.PdfColor.fromInt(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Academic PDF helper methods
  pw.Widget _buildPdfAcademicContactItem(
    String icon,
    String text, {
    bool isLink = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(icon, style: pw.TextStyle(fontSize: 12)),
          pw.SizedBox(width: 6),
          pw.Text(
            text,
            style: pw.TextStyle(
              fontSize: 12,
              color: isLink
                  ? pwlib.PdfColor.fromInt(0xFF3182ce)
                  : pwlib.PdfColor.fromInt(0xFF4B5563),
              fontWeight: isLink ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfAcademicSectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
        color: pwlib.PdfColor.fromInt(0xFF1F2937),
        letterSpacing: 0.5,
      ),
    );
  }

  pw.Widget _buildPdfAcademicEducationItem(Map<String, dynamic> edu) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '${edu['degree'] ?? ''} | ${edu['year'] ?? ''}',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: pwlib.PdfColor.fromInt(0xFF1F2937),
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            edu['school'] ?? '',
            style: pw.TextStyle(
              fontSize: 11,
              color: pwlib.PdfColor.fromInt(0xFF4B5563),
            ),
          ),
          if (edu['location'] != null) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              edu['location'].toString(),
              style: pw.TextStyle(
                fontSize: 11,
                color: pwlib.PdfColor.fromInt(0xFF6B7280),
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildPdfAcademicSkillsList(List skills) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: skills.map((skill) {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 4,
                height: 4,
                margin: const pw.EdgeInsets.only(top: 6, right: 8),
                decoration: pw.BoxDecoration(
                  color: pwlib.PdfColor.fromInt(0xFF1F2937),
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  skill.toString(),
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: pwlib.PdfColor.fromInt(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _buildPdfAcademicProjectItem(Map<String, dynamic> project) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            project['title'] ?? '',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: pwlib.PdfColor.fromInt(0xFF1F2937),
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            project['duration'] ?? '',
            style: pw.TextStyle(
              fontSize: 11,
              color: pwlib.PdfColor.fromInt(0xFF6B7280),
            ),
          ),
          if (project['description'] != null &&
              project['description'].toString().isNotEmpty) ...[
            pw.SizedBox(height: 8),
            _buildPdfAcademicDescriptionWithBullets(
              project['description'].toString(),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildPdfAcademicExperienceItem(Map<String, dynamic> exp) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            exp['title'] ?? '',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: pwlib.PdfColor.fromInt(0xFF1F2937),
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            exp['duration'] ?? '',
            style: pw.TextStyle(
              fontSize: 11,
              color: pwlib.PdfColor.fromInt(0xFF6B7280),
            ),
          ),
          if (exp['description'] != null &&
              exp['description'].toString().isNotEmpty) ...[
            pw.SizedBox(height: 8),
            _buildPdfAcademicDescriptionWithBullets(
              exp['description'].toString(),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildPdfAcademicDescriptionWithBullets(String description) {
    final lines = description
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: lines.map((line) {
        final cleanLine = line.replaceAll(RegExp(r'^[-•*]\s*'), '').trim();
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 3),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 4,
                height: 4,
                margin: const pw.EdgeInsets.only(top: 6, right: 8),
                decoration: pw.BoxDecoration(
                  color: pwlib.PdfColor.fromInt(0xFF4B5563),
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  cleanLine,
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: pwlib.PdfColor.fromInt(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Professional PDF helper methods
  pw.Widget _buildPdfProfessionalSectionTitle(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: pwlib.PdfColor.fromInt(0xFF1F2937),
            letterSpacing: 0.5,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Container(
          height: 1,
          width: double.infinity,
          color: pwlib.PdfColor.fromInt(0xFF4B5563),
        ),
      ],
    );
  }

  pw.Widget _buildPdfProfessionalSkillsList(List skills) {
    return pw.Wrap(
      spacing: 6,
      runSpacing: 3,
      children: skills.map((skill) {
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: pw.BoxDecoration(
            color: pwlib.PdfColor.fromInt(0xFFF3F4F6),
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: pwlib.PdfColor.fromInt(0xFFE5E7EB)),
          ),
          child: pw.Text(
            skill.toString(),
            style: pw.TextStyle(
              fontSize: 10,
              color: pwlib.PdfColor.fromInt(0xFF374151),
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _buildPdfProfessionalExperienceItem(Map<String, dynamic> exp) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            exp['title'] ?? '',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: pwlib.PdfColor.fromInt(0xFF1F2937),
            ),
          ),
          pw.SizedBox(height: 1),
          pw.Text(
            '${exp['company'] ?? ''} | ${exp['location'] ?? ''} | ${exp['duration'] ?? ''}',
            style: pw.TextStyle(
              fontSize: 10,
              color: pwlib.PdfColor.fromInt(0xFF4B5563),
            ),
          ),
          if (exp['description'] != null &&
              exp['description'].toString().isNotEmpty) ...[
            pw.SizedBox(height: 4),
            _buildPdfProfessionalDescriptionWithBullets(
              exp['description'].toString(),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildPdfProfessionalEducationItem(Map<String, dynamic> edu) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            edu['school'] ?? '',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: pwlib.PdfColor.fromInt(0xFF1F2937),
            ),
          ),
          pw.SizedBox(height: 1),
          pw.Text(
            '${edu['degree'] ?? ''}, ${edu['year'] ?? ''}',
            style: pw.TextStyle(
              fontSize: 10,
              color: pwlib.PdfColor.fromInt(0xFF4B5563),
            ),
          ),
          if (edu['location'] != null) ...[
            pw.SizedBox(height: 1),
            pw.Text(
              edu['location'].toString(),
              style: pw.TextStyle(
                fontSize: 10,
                color: pwlib.PdfColor.fromInt(0xFF6B7280),
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildPdfProfessionalProjectItem(Map<String, dynamic> project) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            project['title'] ?? '',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: pwlib.PdfColor.fromInt(0xFF1F2937),
            ),
          ),
          pw.SizedBox(height: 1),
          pw.Text(
            project['duration'] ?? '',
            style: pw.TextStyle(
              fontSize: 10,
              color: pwlib.PdfColor.fromInt(0xFF4B5563),
            ),
          ),
          if (project['description'] != null &&
              project['description'].toString().isNotEmpty) ...[
            pw.SizedBox(height: 4),
            _buildPdfProfessionalDescriptionWithBullets(
              project['description'].toString(),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildPdfProfessionalDescriptionWithBullets(String description) {
    final lines = description
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: lines.map((line) {
        final cleanLine = line.replaceAll(RegExp(r'^[-•*]\s*'), '').trim();
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 2),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 3,
                height: 3,
                margin: const pw.EdgeInsets.only(top: 4, right: 6),
                decoration: pw.BoxDecoration(
                  color: pwlib.PdfColor.fromInt(0xFF4B5563),
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  cleanLine,
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: pwlib.PdfColor.fromInt(0xFF4B5563),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
