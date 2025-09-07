import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _apiKey = 'AIzaSyBvgIy9RBlhreSzrKZeJ4S85Y0RgwH3H9U';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  /// Improves a professional summary using AI
  static Future<String> improveSummary(String currentSummary) async {
    try {
      final prompt = '''
Improve this professional summary to make it more compelling, professional, and impactful. 
Keep the same core information but enhance the language, structure, and impact.

Current summary: $currentSummary

Requirements:
- Make it more professional and polished
- Improve clarity and readability
- Add impact and confidence
- Keep the same length or slightly longer
- Maintain the same key information
- Use strong action verbs
- Make it more engaging for recruiters

Return only the improved summary without any explanations or additional text.
''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-goog-api-key': _apiKey,
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': prompt,
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final generatedText = data['candidates'][0]['content']['parts'][0]['text'];
        return generatedText.trim();
      } else {
        throw Exception('Failed to improve summary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error improving summary: $e');
    }
  }

  /// Generates a professional summary from scratch based on user's role and experience
  static Future<String> generateSummaryFromScratch({
    required String jobTitle,
    required int yearsOfExperience,
    required List<String> keySkills,
    required String industry,
  }) async {
    try {
      final prompt = '''
Generate a professional summary for a resume based on the following information:

Job Title: $jobTitle
Years of Experience: $yearsOfExperience
Key Skills: ${keySkills.join(', ')}
Industry: $industry

Requirements:
- Write a compelling 3-4 sentence professional summary
- Highlight key achievements and expertise
- Use strong action verbs and professional language
- Make it engaging for recruiters
- Focus on value and impact
- Keep it concise but impactful

Return only the professional summary without any explanations or additional text.
''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-goog-api-key': _apiKey,
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': prompt,
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final generatedText = data['candidates'][0]['content']['parts'][0]['text'];
        return generatedText.trim();
      } else {
        throw Exception('Failed to generate summary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating summary: $e');
    }
  }

  /// Enhances skills description to be more professional
  static Future<String> enhanceSkills(String currentSkills) async {
    try {
      final prompt = '''
Enhance these skills to make them more professional and impactful for a resume.
Transform basic skill names into more impressive and professional descriptions.

Current skills: $currentSkills

Requirements:
- Make skills sound more professional and impressive
- Use industry-standard terminology
- Add context where appropriate
- Keep the same number of skills
- Make them more appealing to recruiters
- Use action-oriented language

Return only the enhanced skills list without any explanations or additional text.
''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-goog-api-key': _apiKey,
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': prompt,
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final generatedText = data['candidates'][0]['content']['parts'][0]['text'];
        return generatedText.trim();
      } else {
        throw Exception('Failed to enhance skills: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error enhancing skills: $e');
    }
  }
}
