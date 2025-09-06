import 'math_operation.dart';

class MathProblem {
  final int factor1;
  final int factor2;
  final MathOperation operation;
  final int correctAnswer;
  final DateTime createdAt;
  
  int? userAnswer;
  bool isAnswered;
  bool isCorrect;

  MathProblem({
    required this.factor1,
    required this.factor2,
    required this.operation,
    this.userAnswer,
    this.isAnswered = false,
    this.isCorrect = false,
  }) : correctAnswer = operation.calculate(factor1.toDouble(), factor2.toDouble()).toInt(),
       createdAt = DateTime.now();

  /// Returns the problem as a formatted string
  String get problemText => '$factor1 ${operation.symbol} $factor2 = ?';

  /// Submit an answer and check if it's correct
  bool submitAnswer(int answer) {
    userAnswer = answer;
    isAnswered = true;
    isCorrect = answer == correctAnswer;
    return isCorrect;
  }

  /// Convert to Map for storage
  Map<String, dynamic> toJson() {
    return {
      'factor1': factor1,
      'factor2': factor2,
      'operation': operation.name,
      'correctAnswer': correctAnswer,
      'userAnswer': userAnswer,
      'isAnswered': isAnswered,
      'isCorrect': isCorrect,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Create from Map
  factory MathProblem.fromJson(Map<String, dynamic> json) {
    final operation = MathOperation.values.firstWhere(
      (op) => op.name == json['operation'],
    );
    
    return MathProblem(
      factor1: json['factor1'],
      factor2: json['factor2'],
      operation: operation,
      userAnswer: json['userAnswer'],
      isAnswered: json['isAnswered'] ?? false,
      isCorrect: json['isCorrect'] ?? false,
    );
  }

  @override
  String toString() {
    return 'MathProblem{$problemText, correct: $correctAnswer, user: $userAnswer, isCorrect: $isCorrect}';
  }
}
