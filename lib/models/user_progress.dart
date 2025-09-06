import 'math_operation.dart';
import 'math_problem.dart';

class SessionStats {
  final DateTime sessionDate;
  final MathOperation operation;
  final int totalProblems;
  final int correctAnswers;
  final int incorrectAnswers;
  final Duration totalTime;
  
  SessionStats({
    required this.sessionDate,
    required this.operation,
    required this.totalProblems,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.totalTime,
  });

  double get successRate => totalProblems > 0 ? (correctAnswers / totalProblems) * 100 : 0;

  Map<String, dynamic> toJson() {
    return {
      'sessionDate': sessionDate.millisecondsSinceEpoch,
      'operation': operation.name,
      'totalProblems': totalProblems,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'totalTimeMs': totalTime.inMilliseconds,
    };
  }

  factory SessionStats.fromJson(Map<String, dynamic> json) {
    return SessionStats(
      sessionDate: DateTime.fromMillisecondsSinceEpoch(json['sessionDate']),
      operation: MathOperation.values.firstWhere((op) => op.name == json['operation']),
      totalProblems: json['totalProblems'],
      correctAnswers: json['correctAnswers'],
      incorrectAnswers: json['incorrectAnswers'],
      totalTime: Duration(milliseconds: json['totalTimeMs']),
    );
  }
}

class OperationStats {
  int totalProblems;
  int correctAnswers;
  int incorrectAnswers;
  int consecutiveCorrect;
  int bestStreak;
  
  OperationStats({
    this.totalProblems = 0,
    this.correctAnswers = 0,
    this.incorrectAnswers = 0,
    this.consecutiveCorrect = 0,
    this.bestStreak = 0,
  });

  double get successRate => totalProblems > 0 ? (correctAnswers / totalProblems) * 100 : 0;

  void addResult(bool isCorrect) {
    totalProblems++;
    if (isCorrect) {
      correctAnswers++;
      consecutiveCorrect++;
      if (consecutiveCorrect > bestStreak) {
        bestStreak = consecutiveCorrect;
      }
    } else {
      incorrectAnswers++;
      consecutiveCorrect = 0;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'totalProblems': totalProblems,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'consecutiveCorrect': consecutiveCorrect,
      'bestStreak': bestStreak,
    };
  }

  factory OperationStats.fromJson(Map<String, dynamic> json) {
    return OperationStats(
      totalProblems: json['totalProblems'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      incorrectAnswers: json['incorrectAnswers'] ?? 0,
      consecutiveCorrect: json['consecutiveCorrect'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
    );
  }
}

class UserProgress {
  final Map<MathOperation, OperationStats> operationStats;
  final List<SessionStats> sessionHistory;
  final DateTime firstPlayed;
  DateTime lastPlayed;

  UserProgress({
    Map<MathOperation, OperationStats>? operationStats,
    List<SessionStats>? sessionHistory,
    DateTime? firstPlayed,
    DateTime? lastPlayed,
  }) : operationStats = operationStats ?? {},
       sessionHistory = sessionHistory ?? [],
       firstPlayed = firstPlayed ?? DateTime.now(),
       lastPlayed = lastPlayed ?? DateTime.now();

  /// Update progress with a completed problem
  void updateProgress(MathProblem problem) {
    final operation = problem.operation;
    if (!operationStats.containsKey(operation)) {
      operationStats[operation] = OperationStats();
    }
    
    operationStats[operation]!.addResult(problem.isCorrect);
    lastPlayed = DateTime.now();
  }

  /// Add a completed session
  void addSession(SessionStats session) {
    sessionHistory.add(session);
    lastPlayed = session.sessionDate;
  }

  /// Get overall statistics across all operations
  OperationStats get overallStats {
    final overall = OperationStats();
    for (final stats in operationStats.values) {
      overall.totalProblems += stats.totalProblems;
      overall.correctAnswers += stats.correctAnswers;
      overall.incorrectAnswers += stats.incorrectAnswers;
      if (stats.bestStreak > overall.bestStreak) {
        overall.bestStreak = stats.bestStreak;
      }
    }
    return overall;
  }

  /// Get stats for a specific operation
  OperationStats getStatsForOperation(MathOperation operation) {
    return operationStats[operation] ?? OperationStats();
  }

  /// Get recent session stats (last N sessions)
  List<SessionStats> getRecentSessions([int limit = 10]) {
    final sorted = List<SessionStats>.from(sessionHistory)
      ..sort((a, b) => b.sessionDate.compareTo(a.sessionDate));
    return sorted.take(limit).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'operationStats': operationStats.map(
        (key, value) => MapEntry(key.name, value.toJson()),
      ),
      'sessionHistory': sessionHistory.map((s) => s.toJson()).toList(),
      'firstPlayed': firstPlayed.millisecondsSinceEpoch,
      'lastPlayed': lastPlayed.millisecondsSinceEpoch,
    };
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    final operationStatsMap = <MathOperation, OperationStats>{};
    if (json['operationStats'] != null) {
      final statsJson = json['operationStats'] as Map<String, dynamic>;
      for (final entry in statsJson.entries) {
        final operation = MathOperation.values.firstWhere(
          (op) => op.name == entry.key,
        );
        operationStatsMap[operation] = OperationStats.fromJson(entry.value);
      }
    }

    final sessionHistoryList = <SessionStats>[];
    if (json['sessionHistory'] != null) {
      final historyJson = json['sessionHistory'] as List<dynamic>;
      for (final sessionJson in historyJson) {
        sessionHistoryList.add(SessionStats.fromJson(sessionJson));
      }
    }

    return UserProgress(
      operationStats: operationStatsMap,
      sessionHistory: sessionHistoryList,
      firstPlayed: json['firstPlayed'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(json['firstPlayed'])
        : DateTime.now(),
      lastPlayed: json['lastPlayed'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['lastPlayed'])
        : DateTime.now(),
    );
  }
}
