import 'package:flutter/material.dart';
import 'resume_form_screen.dart';

class TemplateSelectionScreen extends StatelessWidget {
  const TemplateSelectionScreen({super.key});

  void _selectTemplate(BuildContext context, String templateKey) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResumeFormScreen(templateKey: templateKey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final templates = [
      {
        'key': 'classic_left',
        'name': 'Classic',
        'description':
            'Professional layout with left sidebar for contact & skills',
      },
      {
        'key': 'single_column',
        'name': 'Single Column',
        'description': 'Clean single-column layout with contact info at top',
      },
      {
        'key': 'academic',
        'name': 'Academic',
        'description': 'Professional academic layout with sidebar sections',
      },
      {
        'key': 'professional',
        'name': 'Professional',
        'description': 'Clean single-column with colored header section',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Resume Style'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFf8f9fa),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                width: 300,
                height: 400,
                child: _buildTemplateCard(context, templates[0]),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                height: 400,
                child: _buildTemplateCard(context, templates[1]),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                height: 400,
                child: _buildTemplateCard(context, templates[2]),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                height: 400,
                child: _buildTemplateCard(context, templates[3]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    Map<String, dynamic> template,
  ) {
    return GestureDetector(
      onTap: () => _selectTemplate(context, template['key'] as String),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Simple visual thumbnail mimicking the style
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: template['key'] == 'classic_left'
                    ? Row(
                        children: [
                          // Left sidebar with a random avatar block
                          Container(
                            width: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF123B63),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 6,
                                  width: 40,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 6,
                                  width: 34,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Right content skeleton
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 12,
                                  width: 90,
                                  color: const Color(0xFFa0aec0),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 6,
                                  color: const Color(0xFFe2e8f0),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 6,
                                  width: 100,
                                  color: const Color(0xFFe2e8f0),
                                ),
                                const Spacer(),
                                Container(
                                  height: 6,
                                  color: const Color(0xFFe2e8f0),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 6,
                                  width: 80,
                                  color: const Color(0xFFe2e8f0),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : template['key'] == 'single_column'
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with name and contact info
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 12,
                                    width: 80,
                                    color: const Color(0xFF2d3748),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: 8,
                                    width: 60,
                                    color: const Color(0xFF4a5568),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    height: 6,
                                    width: 100,
                                    color: const Color(0xFFe2e8f0),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    height: 6,
                                    width: 80,
                                    color: const Color(0xFFe2e8f0),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    height: 6,
                                    width: 90,
                                    color: const Color(0xFFe2e8f0),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Section headers and content
                          Container(
                            height: 8,
                            width: 60,
                            color: const Color(0xFF3182ce),
                          ),
                          const SizedBox(height: 6),
                          Container(height: 6, color: const Color(0xFFe2e8f0)),
                          const SizedBox(height: 4),
                          Container(
                            height: 6,
                            width: 120,
                            color: const Color(0xFFe2e8f0),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 8,
                            width: 50,
                            color: const Color(0xFF3182ce),
                          ),
                          const SizedBox(height: 6),
                          Container(height: 6, color: const Color(0xFFe2e8f0)),
                          const SizedBox(height: 4),
                          Container(
                            height: 6,
                            width: 100,
                            color: const Color(0xFFe2e8f0),
                          ),
                        ],
                      )
                    : template['key'] == 'academic'
                    ? Row(
                        children: [
                          // Left sidebar for academic template
                          Container(
                            width: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFf8f9fa),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFe2e8f0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 8,
                                  width: 40,
                                  color: const Color(0xFF2d3748),
                                  margin: const EdgeInsets.all(4),
                                ),
                                Container(
                                  height: 6,
                                  width: 30,
                                  color: const Color(0xFFe2e8f0),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 8,
                                  width: 35,
                                  color: const Color(0xFF2d3748),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                ),
                                Container(
                                  height: 6,
                                  width: 25,
                                  color: const Color(0xFFe2e8f0),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 8,
                                  width: 30,
                                  color: const Color(0xFF2d3748),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                ),
                                Container(
                                  height: 6,
                                  width: 20,
                                  color: const Color(0xFFe2e8f0),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Right content for academic template
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 12,
                                  width: 90,
                                  color: const Color(0xFF2d3748),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 8,
                                  width: 70,
                                  color: const Color(0xFF4a5568),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  height: 8,
                                  width: 80,
                                  color: const Color(0xFF2d3748),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 6,
                                  color: const Color(0xFFe2e8f0),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 6,
                                  width: 100,
                                  color: const Color(0xFFe2e8f0),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 8,
                                  width: 60,
                                  color: const Color(0xFF2d3748),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 6,
                                  color: const Color(0xFFe2e8f0),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 6,
                                  width: 90,
                                  color: const Color(0xFFe2e8f0),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with colored background
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8DDCB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 12,
                                  width: 80,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 8,
                                  width: 60,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      height: 6,
                                      width: 40,
                                      color: const Color(0xFF2d3748),
                                    ),
                                    Container(
                                      height: 6,
                                      width: 50,
                                      color: const Color(0xFF2d3748),
                                    ),
                                    Container(
                                      height: 6,
                                      width: 35,
                                      color: const Color(0xFF2d3748),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Content sections
                          Container(
                            height: 8,
                            width: 60,
                            color: const Color(0xFF2d3748),
                          ),
                          const SizedBox(height: 6),
                          Container(height: 6, color: const Color(0xFFe2e8f0)),
                          const SizedBox(height: 4),
                          Container(
                            height: 6,
                            width: 100,
                            color: const Color(0xFFe2e8f0),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 8,
                            width: 50,
                            color: const Color(0xFF2d3748),
                          ),
                          const SizedBox(height: 6),
                          Container(height: 6, color: const Color(0xFFe2e8f0)),
                          const SizedBox(height: 4),
                          Container(
                            height: 6,
                            width: 80,
                            color: const Color(0xFFe2e8f0),
                          ),
                        ],
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template['name'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    template['description'] as String,
                    style: const TextStyle(
                      color: Color(0xFF718096),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
