import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _apiKey = 'AIzaSyBvgIy9RBlhreSzrKZeJ4S85Y0RgwH3H9U';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  /// Improves a professional summary using AI
  static Future<String> improveSummary(String currentSummary) async {
    try {
      final prompt =
          '''
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
                {'text': prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final generatedText =
            data['candidates'][0]['content']['parts'][0]['text'];
        return generatedText.trim();
      } else {
        throw Exception('Failed to improve summary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error improving summary: $e');
    }
  }

  /// Produces a compact professional summary (mini version)
  static Future<String> generateConciseSummary(String currentSummary) async {
    try {
      final prompt =
          '''
Rewrite the following professional summary into a compact, recruiter-friendly paragraph:

Text: $currentSummary

Constraints:
- 2-3 sentences only (max ~350 characters)
- Keep the strongest achievements and skills
- Use clear, simple language and strong verbs
- Remove fluff and redundancy
- Return only the compact summary, no quotes or extra text
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
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {'temperature': 0.6, 'maxOutputTokens': 200},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final generatedText =
            data['candidates'][0]['content']['parts'][0]['text'];
        return generatedText.trim();
      } else {
        throw Exception(
          'Failed to generate concise summary: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error generating concise summary: $e');
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
      final prompt =
          '''
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
                {'text': prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final generatedText =
            data['candidates'][0]['content']['parts'][0]['text'];
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
      final prompt =
          '''
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
                {'text': prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final generatedText =
            data['candidates'][0]['content']['parts'][0]['text'];
        return generatedText.trim();
      } else {
        throw Exception('Failed to enhance skills: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error enhancing skills: $e');
    }
  }

  /// Generates a professional job experience summary for resume
  static Future<String> generateJobExperienceSummary({
    required String jobTitle,
    required String company,
    required String duration,
    String? jobDescription,
  }) async {
    try {
      final prompt =
          '''
Generate a concise job experience summary for a resume based on the following information:

Job Title: $jobTitle
Company: $company
Duration: $duration
${jobDescription != null ? 'Job Description: $jobDescription' : ''}

Requirements:
- Write exactly 2 bullet points maximum
- Each bullet point should be 1 line only (15-20 words max)
- Use strong action verbs and focus on key achievements
- Make it professional and impactful
- Focus on quantifiable results and value delivered
- Use simple, clear language
- No unnecessary symbols or formatting

Format: Return only the 2 bullet points separated by a line break, without any bullet symbols, dashes, or other formatting.
Example format:
Led team of 5 developers to deliver mobile app with 10K+ downloads
Implemented agile methodologies reducing project delivery time by 30%

Return only the content without any explanations or additional text.
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
                {'text': prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final generatedText =
            data['candidates'][0]['content']['parts'][0]['text'];
        return generatedText.trim();
      } else {
        throw Exception(
          'Failed to generate job experience summary: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error generating job experience summary: $e');
    }
  }

  /// Generates a professional project summary for resume
  static Future<String> generateProjectSummary({
    required String projectTitle,
    required String projectDescription,
    required String technologies,
    required String duration,
  }) async {
    try {
      final prompt =
          '''
Generate a concise project summary for a resume based on the following information:

Project Title: $projectTitle
Project Description: $projectDescription
Technologies Used: $technologies
Duration: $duration

Requirements:
- Write exactly 2 bullet points maximum
- Each bullet point should be 1 line only (15-20 words max)
- Use strong action verbs and focus on key achievements
- Make it professional and impactful
- Focus on quantifiable results and technical accomplishments
- Use simple, clear language
- No unnecessary symbols or formatting
- Highlight technical skills and project impact

Format: Return only the 2 bullet points separated by a line break, without any bullet symbols, dashes, or other formatting.
Example format:
Developed full-stack web application using React and Node.js serving 5K+ users
Implemented responsive design and RESTful APIs improving performance by 40%

Return only the content without any explanations or additional text.
''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': _apiKey,
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 200,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final generatedText =
            data['candidates'][0]['content']['parts'][0]['text'];
        return generatedText.trim();
      } else {
        throw Exception(
          'Failed to generate project summary: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error generating project summary: $e');
    }
  }

  /// Suggests relevant skills based on user's professional summary
  static Future<List<String>> suggestSkillsFromSummary({
    required String summary,
  }) async {
    try {
      final prompt =
          '''
Based on the following professional summary, suggest 12-18 relevant skills that would be appropriate for this person's resume:

Professional Summary: $summary

Requirements:
- Include technical skills (programming languages, frameworks, tools, software)
- Include soft skills (communication, leadership, problem-solving, etc.)
- Include industry-specific skills relevant to their field
- Include modern and trending technologies
- Make suggestions specific and relevant to their background
- Include both beginner and advanced level skills

Format: Return only a comma-separated list of skills, no explanations or additional text.
Example: JavaScript, React, Node.js, Python, Leadership, Problem Solving, Git, AWS, Communication, Team Management, Project Management, Agile, SQL, Docker

Return only the comma-separated list of skills.
''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': _apiKey,
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.8,
            'topK': 50,
            'topP': 0.9,
            'maxOutputTokens': 400,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if response has the expected structure
        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          final generatedText =
              data['candidates'][0]['content']['parts'][0]['text'];

          // Parse the comma-separated skills and clean them
          final skills = generatedText
              .split(',')
              .map((skill) => skill.trim())
              .where((skill) => skill.isNotEmpty && skill.length > 1)
              .take(18) // Limit to 18 skills
              .toList();

          return skills;
        } else {
          // Fallback to default skills if AI response is malformed
          return _getDefaultSkillsForSummary(summary);
        }
      } else {
        print('AI API Error: ${response.statusCode} - ${response.body}');
        // Fallback to default skills
        return _getDefaultSkillsForSummary(summary);
      }
    } catch (e) {
      print('AI Service Error: $e');
      // Fallback to default skills
      return _getDefaultSkillsForSummary(summary);
    }
  }

  /// Suggests related skills based on user's current skill input
  static Future<List<String>> suggestRelatedSkills({
    required String userInput,
  }) async {
    try {
      final prompt =
          '''
Based on the following skills that a user has entered, suggest 8-12 related skills that would complement their skill set:

User's Current Skills: $userInput

Requirements:
- Suggest skills that are commonly used together with the user's skills
- Include both technical and soft skills
- Focus on skills that are in the same domain or complementary
- Include modern and trending technologies
- Make suggestions specific and relevant
- Include both beginner and advanced level skills

Format: Return only a comma-separated list of skills, no explanations or additional text.
Example: If user has "JavaScript, React", suggest: "Node.js, TypeScript, HTML, CSS, Git, Webpack, Jest, Redux, Next.js, Express.js, MongoDB, AWS"

Return only the comma-separated list of related skills.
''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': _apiKey,
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.9,
            'maxOutputTokens': 300,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if response has the expected structure
        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          final generatedText =
              data['candidates'][0]['content']['parts'][0]['text'];

          // Parse the comma-separated skills and clean them
          final skills = generatedText
              .split(',')
              .map((skill) => skill.trim())
              .where((skill) => skill.isNotEmpty && skill.length > 1)
              .take(12) // Limit to 12 skills
              .toList();

          return skills;
        } else {
          // Fallback to default related skills
          return _getDefaultRelatedSkills(userInput);
        }
      } else {
        print('AI API Error: ${response.statusCode} - ${response.body}');
        // Fallback to default related skills
        return _getDefaultRelatedSkills(userInput);
      }
    } catch (e) {
      print('AI Service Error: $e');
      // Fallback to default related skills
      return _getDefaultRelatedSkills(userInput);
    }
  }

  /// Fallback method to provide default related skills based on user input
  static List<String> _getDefaultRelatedSkills(String userInput) {
    final inputLower = userInput.toLowerCase();
    final relatedSkills = <String>[];

    // Programming Languages
    if (inputLower.contains('javascript')) {
      relatedSkills.addAll([
        'TypeScript',
        'Node.js',
        'React',
        'Vue.js',
        'Angular',
        'Express.js',
        'Webpack',
        'Jest',
      ]);
    }
    if (inputLower.contains('python')) {
      relatedSkills.addAll([
        'Django',
        'Flask',
        'Pandas',
        'NumPy',
        'TensorFlow',
        'Jupyter',
        'SQL',
        'Git',
      ]);
    }
    if (inputLower.contains('java')) {
      relatedSkills.addAll([
        'Spring Boot',
        'Maven',
        'Gradle',
        'JUnit',
        'Hibernate',
        'MySQL',
        'Git',
        'Docker',
      ]);
    }
    if (inputLower.contains('react')) {
      relatedSkills.addAll([
        'JavaScript',
        'TypeScript',
        'Redux',
        'Next.js',
        'Node.js',
        'Webpack',
        'Jest',
        'HTML',
      ]);
    }
    if (inputLower.contains('node.js')) {
      relatedSkills.addAll([
        'JavaScript',
        'Express.js',
        'MongoDB',
        'React',
        'Git',
        'Docker',
        'AWS',
        'REST APIs',
      ]);
    }

    // Web Development
    if (inputLower.contains('html')) {
      relatedSkills.addAll([
        'CSS',
        'JavaScript',
        'Bootstrap',
        'Responsive Design',
        'Git',
        'Web Accessibility',
        'SEO',
      ]);
    }
    if (inputLower.contains('css')) {
      relatedSkills.addAll([
        'HTML',
        'JavaScript',
        'SASS',
        'Bootstrap',
        'Tailwind CSS',
        'Responsive Design',
        'Git',
      ]);
    }

    // Databases
    if (inputLower.contains('sql') || inputLower.contains('mysql')) {
      relatedSkills.addAll([
        'Database Design',
        'PostgreSQL',
        'MongoDB',
        'Redis',
        'Data Analysis',
        'Python',
        'Excel',
      ]);
    }
    if (inputLower.contains('mongodb')) {
      relatedSkills.addAll([
        'Node.js',
        'Express.js',
        'JavaScript',
        'NoSQL',
        'Database Design',
        'Git',
        'REST APIs',
      ]);
    }

    // Cloud & DevOps
    if (inputLower.contains('aws')) {
      relatedSkills.addAll([
        'Docker',
        'Kubernetes',
        'Linux',
        'Terraform',
        'CI/CD',
        'Git',
        'Python',
        'Monitoring',
      ]);
    }
    if (inputLower.contains('docker')) {
      relatedSkills.addAll([
        'Kubernetes',
        'AWS',
        'Linux',
        'Git',
        'CI/CD',
        'DevOps',
        'Microservices',
        'Containerization',
      ]);
    }

    // Design
    if (inputLower.contains('figma')) {
      relatedSkills.addAll([
        'UI/UX Design',
        'Adobe XD',
        'Sketch',
        'Photoshop',
        'Prototyping',
        'Design Systems',
        'User Research',
      ]);
    }
    if (inputLower.contains('photoshop')) {
      relatedSkills.addAll([
        'Illustrator',
        'InDesign',
        'Graphic Design',
        'UI/UX Design',
        'Figma',
        'Branding',
        'Typography',
      ]);
    }

    // Marketing
    if (inputLower.contains('marketing')) {
      relatedSkills.addAll([
        'Digital Marketing',
        'SEO',
        'Google Analytics',
        'Social Media',
        'Content Marketing',
        'Email Marketing',
        'Analytics',
      ]);
    }
    if (inputLower.contains('seo')) {
      relatedSkills.addAll([
        'Digital Marketing',
        'Google Analytics',
        'Content Marketing',
        'SEM',
        'WordPress',
        'HTML',
        'Analytics',
      ]);
    }

    // Management
    if (inputLower.contains('management') ||
        inputLower.contains('leadership')) {
      relatedSkills.addAll([
        'Project Management',
        'Team Management',
        'Communication',
        'Strategic Planning',
        'Agile',
        'Scrum',
        'Decision Making',
      ]);
    }
    if (inputLower.contains('project management')) {
      relatedSkills.addAll([
        'Agile',
        'Scrum',
        'Leadership',
        'Communication',
        'Risk Management',
        'Budgeting',
        'Team Management',
      ]);
    }

    // Always add common complementary skills
    relatedSkills.addAll([
      'Communication',
      'Problem Solving',
      'Git',
      'Time Management',
      'Teamwork',
    ]);

    // Remove duplicates and return
    return relatedSkills.toSet().take(12).toList();
  }

  /// Fallback method to provide default skills based on summary keywords
  static List<String> _getDefaultSkillsForSummary(String summary) {
    final summaryLower = summary.toLowerCase();
    final defaultSkills = <String>[];

    // Technical skills based on keywords
    if (summaryLower.contains('developer') ||
        summaryLower.contains('programming')) {
      defaultSkills.addAll(['JavaScript', 'Python', 'Git', 'Problem Solving']);
    }
    if (summaryLower.contains('web') || summaryLower.contains('frontend')) {
      defaultSkills.addAll(['HTML', 'CSS', 'React', 'Node.js']);
    }
    if (summaryLower.contains('mobile') || summaryLower.contains('app')) {
      defaultSkills.addAll(['React Native', 'Flutter', 'iOS', 'Android']);
    }
    if (summaryLower.contains('data') || summaryLower.contains('analyst')) {
      defaultSkills.addAll(['Python', 'SQL', 'Excel', 'Analytics']);
    }
    if (summaryLower.contains('design') || summaryLower.contains('ui')) {
      defaultSkills.addAll(['Figma', 'Adobe XD', 'Photoshop', 'UI/UX Design']);
    }
    if (summaryLower.contains('manager') || summaryLower.contains('lead')) {
      defaultSkills.addAll([
        'Leadership',
        'Project Management',
        'Team Management',
        'Communication',
      ]);
    }

    // Always add common soft skills
    defaultSkills.addAll([
      'Communication',
      'Problem Solving',
      'Time Management',
      'Teamwork',
    ]);

    // Remove duplicates and return
    return defaultSkills.toSet().take(15).toList();
  }

  /// Generates a comprehensive job summary with key insights
  static Future<Map<String, dynamic>> generateJobSummary({
    required String jobTitle,
    required String company,
    required String jobDescription,
    required String userSkills,
    required String userExperience,
  }) async {
    try {
      final prompt =
          '''
Analyze this job posting and generate a comprehensive job summary with key insights for a candidate.

Job Title: $jobTitle
Company: $company
Job Description: $jobDescription

Candidate's Skills: $userSkills
Candidate's Experience: $userExperience

Please provide a JSON response with the following structure:
{
  "summary": "A 2-3 sentence overview of what this role entails",
  "keyRequirements": ["requirement1", "requirement2", "requirement3", "requirement4", "requirement5"],
  "skillsMatch": {
    "matched": ["skill1", "skill2"],
    "missing": ["skill3", "skill4"],
    "matchPercentage": 75
  },
  "salaryRange": "Estimated salary range based on role and requirements",
  "experienceLevel": "Junior/Mid/Senior level",
  "companyCulture": "Brief insight about company culture based on job description",
  "growthOpportunities": "Potential career growth and learning opportunities",
  "applicationTips": ["tip1", "tip2", "tip3"]
}

Requirements:
- Make the summary professional and insightful
- Extract the most important requirements from the job description
- Analyze skill match between candidate and job requirements
- Provide realistic salary estimates
- Give practical application tips
- Keep all text concise and actionable

Return only the JSON response without any additional text or explanations.
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
                {'text': prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final generatedText =
            data['candidates'][0]['content']['parts'][0]['text'];

        // Parse the JSON response
        final jobSummaryData = jsonDecode(generatedText.trim());
        return jobSummaryData;
      } else {
        throw Exception(
          'Failed to generate job summary: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error generating job summary: $e');
    }
  }
}
