import 'dart:math';
import '../models/math_problem.dart';
import '../models/math_operation.dart';
import '../models/game_settings.dart';

class MathService {
  static final Random _random = Random();

  /// Generate a single math problem based on settings
  static MathProblem generateProblem(GameSettings settings) {
    int factor1, factor2;
    int attempts = 0;
    const maxAttempts = 50; // Prevent infinite loops

    do {
      factor1 = _random.nextInt(settings.maxFactor1 - settings.minFactor1 + 1) + settings.minFactor1;
      factor2 = _random.nextInt(settings.maxFactor2 - settings.minFactor2 + 1) + settings.minFactor2;
      
      attempts++;
      if (attempts > maxAttempts) {
        // Fallback to simple numbers if we can't find a valid combination
        factor1 = settings.minFactor1;
        factor2 = settings.minFactor2;
        break;
      }
    } while (!settings.operation.isValidOperation(factor1, factor2));

    // For division, make sure we have a clean division
    if (settings.operation == MathOperation.division) {
      // Generate a result first, then create the dividend
      final result = _random.nextInt(settings.maxFactor1 - settings.minFactor1 + 1) + settings.minFactor1;
      final divisor = _random.nextInt(settings.maxFactor2 - settings.minFactor2 + 1) + settings.minFactor2;
      if (divisor == 0) {
        factor2 = 1;
      } else {
        factor2 = divisor;
      }
      factor1 = result * factor2; // This ensures clean division
    }

    return MathProblem(
      factor1: factor1,
      factor2: factor2,
      operation: settings.operation,
    );
  }

  /// Generate multiple problems for a session
  static List<MathProblem> generateProblems(GameSettings settings) {
    final problems = <MathProblem>[];
    
    for (int i = 0; i < settings.problemsPerSession; i++) {
      problems.add(generateProblem(settings));
    }
    
    return problems;
  }

  /// Generate a batch of problems ensuring variety in factors
  static List<MathProblem> generateVariedProblems(GameSettings settings) {
    final problems = <MathProblem>[];
    final usedCombinations = <String>{};
    
    int attempts = 0;
      final maxAttempts = settings.problemsPerSession * 10;
    
    while (problems.length < settings.problemsPerSession && attempts < maxAttempts) {
      final problem = generateProblem(settings);
      final combination = '${problem.factor1}_${problem.factor2}';
      
      // Try to avoid duplicate combinations for variety
      if (!usedCombinations.contains(combination)) {
        problems.add(problem);
        usedCombinations.add(combination);
      } else if (attempts > settings.problemsPerSession * 2) {
        // If we've tried enough times, allow duplicates
        problems.add(problem);
      }
      
      attempts++;
    }
    
    // Fill remaining problems if we couldn't generate enough unique ones
    while (problems.length < settings.problemsPerSession) {
      problems.add(generateProblem(settings));
    }
    
    return problems;
  }

  /// Validate user input for answers
  static bool isValidAnswer(String input) {
    if (input.trim().isEmpty) return false;
    
    // Allow negative numbers for subtraction results
    final cleanInput = input.trim();
    if (cleanInput.startsWith('-')) {
      return int.tryParse(cleanInput.substring(1)) != null;
    }
    
    return int.tryParse(cleanInput) != null;
  }

  /// Parse user input to integer
  static int? parseAnswer(String input) {
    if (!isValidAnswer(input)) return null;
    return int.tryParse(input.trim());
  }

  /// Get appropriate encouragement message based on performance
  static String getEncouragementMessage(bool isCorrect, int consecutiveCorrect) {
    if (isCorrect) {
      if (consecutiveCorrect >= 10) {
        return "🌟 Amazing! You're on fire! 🌟";
      } else if (consecutiveCorrect >= 5) {
        return "🎉 Great job! Keep it up! 🎉";
      } else if (consecutiveCorrect >= 3) {
        return "👏 Excellent work! 👏";
      } else {
        return "✨ Well done! ✨";
      }
    } else {
      final encouragements = [
        "🤔 Not quite! Try again!",
        "💪 Keep trying! You've got this!",
        "🌱 Every mistake helps you learn!",
        "🎯 Almost there! Give it another shot!",
        "⭐ Don't give up! Practice makes perfect!",
      ];
      return encouragements[_random.nextInt(encouragements.length)];
    }
  }

  /// Get difficulty recommendation based on user performance
  static DifficultyLevel? getDifficultyRecommendation(double successRate, DifficultyLevel currentDifficulty) {
    if (successRate >= 90 && currentDifficulty != DifficultyLevel.expert) {
      // Suggest moving up
      final currentIndex = DifficultyLevel.values.indexOf(currentDifficulty);
      return DifficultyLevel.values[currentIndex + 1];
    } else if (successRate < 60 && currentDifficulty != DifficultyLevel.easy) {
      // Suggest moving down
      final currentIndex = DifficultyLevel.values.indexOf(currentDifficulty);
      return DifficultyLevel.values[currentIndex - 1];
    }
    
    return null; // No recommendation
  }
}
