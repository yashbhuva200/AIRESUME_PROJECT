import 'package:flutter/material.dart';

class SkillSuggestionWidget extends StatelessWidget {
  final List<String> suggestedSkills;
  final List<String> selectedSkills;
  final Function(String) onSkillSelected;
  final bool isLoading;

  const SkillSuggestionWidget({
    Key? key,
    required this.suggestedSkills,
    required this.selectedSkills,
    required this.onSkillSelected,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text(
              'AI is suggesting skills based on your summary...',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    if (suggestedSkills.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.green.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'AI Suggested Skills',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Click on skills to add them to your resume:',
            style: TextStyle(fontSize: 12, color: Colors.green.shade600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestedSkills.map((skill) {
              final isSelected = selectedSkills.contains(skill);
              return GestureDetector(
                onTap: () => onSkillSelected(skill),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green.shade200 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Colors.green.shade400
                          : Colors.green.shade300,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        skill,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.green.shade800
                              : Colors.green.shade700,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.green.shade800,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
