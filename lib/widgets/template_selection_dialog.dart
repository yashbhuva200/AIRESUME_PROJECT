import 'package:flutter/material.dart';

class TemplateSelectionDialog extends StatelessWidget {
  final String resumeName;
  final Map<String, dynamic> resumeData;

  const TemplateSelectionDialog({
    super.key,
    required this.resumeName,
    required this.resumeData,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Select Template for "$resumeName"',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2d3748),
        ),
      ),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose how you want to view this resume:',
              style: TextStyle(color: Color(0xFF718096), fontSize: 14),
            ),
            const SizedBox(height: 20),
            _buildTemplateOption(
              context,
              'classic_left',
              'Classic',
              'Professional layout with left sidebar for contact & skills',
              Icons.description,
            ),
            const SizedBox(height: 12),
            _buildTemplateOption(
              context,
              'single_column',
              'Single Column',
              'Clean single-column layout with contact info at top',
              Icons.view_column,
            ),
            const SizedBox(height: 12),
            _buildTemplateOption(
              context,
              'academic',
              'Academic',
              'Professional academic layout with sidebar sections',
              Icons.school,
            ),
            const SizedBox(height: 12),
            _buildTemplateOption(
              context,
              'professional',
              'Professional',
              'Clean single-column with colored header section',
              Icons.work,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF718096)),
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateOption(
    BuildContext context,
    String templateKey,
    String templateName,
    String templateDescription,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop(templateKey);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF667eea), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF667eea), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    templateName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2d3748),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    templateDescription,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF667eea),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
