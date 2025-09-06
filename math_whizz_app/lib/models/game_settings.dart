import 'math_operation.dart';

enum DifficultyLevel {
  easy('Easy', 1, 10),
  medium('Medium', 1, 50),
  hard('Hard', 1, 100),
  expert('Expert', 1, 999);

  const DifficultyLevel(this.name, this.minFactor, this.maxFactor);

  final String name;
  final int minFactor;
  final int maxFactor;
}

class GameSettings {
  final MathOperation operation;
  final DifficultyLevel difficulty;
  final int problemsPerSession;
  final bool multipleProblems; // true for multiple per page, false for one at a time
  
  // Custom factor ranges (overrides difficulty if set)
  final int? customMinFactor1;
  final int? customMaxFactor1;
  final int? customMinFactor2;
  final int? customMaxFactor2;

  const GameSettings({
    required this.operation,
    required this.difficulty,
    this.problemsPerSession = 10,
    this.multipleProblems = false,
    this.customMinFactor1,
    this.customMaxFactor1,
    this.customMinFactor2,
    this.customMaxFactor2,
  });

  // Get effective factor ranges (custom overrides difficulty)
  int get minFactor1 => customMinFactor1 ?? difficulty.minFactor;
  int get maxFactor1 => customMaxFactor1 ?? difficulty.maxFactor;
  int get minFactor2 => customMinFactor2 ?? difficulty.minFactor;
  int get maxFactor2 => customMaxFactor2 ?? difficulty.maxFactor;

  GameSettings copyWith({
    MathOperation? operation,
    DifficultyLevel? difficulty,
    int? problemsPerSession,
    bool? multipleProblems,
    int? customMinFactor1,
    int? customMaxFactor1,
    int? customMinFactor2,
    int? customMaxFactor2,
  }) {
    return GameSettings(
      operation: operation ?? this.operation,
      difficulty: difficulty ?? this.difficulty,
      problemsPerSession: problemsPerSession ?? this.problemsPerSession,
      multipleProblems: multipleProblems ?? this.multipleProblems,
      customMinFactor1: customMinFactor1 ?? this.customMinFactor1,
      customMaxFactor1: customMaxFactor1 ?? this.customMaxFactor1,
      customMinFactor2: customMinFactor2 ?? this.customMinFactor2,
      customMaxFactor2: customMaxFactor2 ?? this.customMaxFactor2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'operation': operation.name,
      'difficulty': difficulty.name,
      'problemsPerSession': problemsPerSession,
      'multipleProblems': multipleProblems,
      'customMinFactor1': customMinFactor1,
      'customMaxFactor1': customMaxFactor1,
      'customMinFactor2': customMinFactor2,
      'customMaxFactor2': customMaxFactor2,
    };
  }

  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      operation: MathOperation.values.firstWhere((op) => op.name == json['operation']),
      difficulty: DifficultyLevel.values.firstWhere((diff) => diff.name == json['difficulty']),
      problemsPerSession: json['problemsPerSession'] ?? 10,
      multipleProblems: json['multipleProblems'] ?? false,
      customMinFactor1: json['customMinFactor1'],
      customMaxFactor1: json['customMaxFactor1'],
      customMinFactor2: json['customMinFactor2'],
      customMaxFactor2: json['customMaxFactor2'],
    );
  }
}
