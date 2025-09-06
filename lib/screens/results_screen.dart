import 'package:flutter/material.dart';
import '../models/math_problem.dart';
import '../models/math_operation.dart';
import '../models/game_settings.dart';
import '../models/user_progress.dart';
import '../services/math_service.dart';
import 'main_menu_screen.dart';
import 'difficulty_selection_screen.dart';

class ResultsScreen extends StatefulWidget {
  final List<MathProblem> problems;
  final SessionStats sessionStats;
  final UserProgress userProgress;

  const ResultsScreen({
    Key? key,
    required this.problems,
    required this.sessionStats,
    required this.userProgress,
  }) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> with TickerProviderStateMixin {
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;
  
  late AnimationController _scaleAnimationController;
  late Animation<double> _scaleAnimation;

  Color get _operationColor {
    switch (widget.sessionStats.operation) {
      case MathOperation.addition:
        return const Color(0xFF10B981);
      case MathOperation.subtraction:
        return const Color(0xFFF59E0B);
      case MathOperation.multiplication:
        return const Color(0xFFEF4444);
      case MathOperation.division:
        return const Color(0xFF3B82F6);
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleAnimationController, curve: Curves.bounceOut),
    );

    // Start animations
    _slideAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _scaleAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final correctAnswers = widget.problems.where((p) => p.isCorrect).length;
    final totalProblems = widget.problems.length;
    final successRate = (correctAnswers / totalProblems * 100).round();
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _operationColor,
              _operationColor.withOpacity(0.7),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _getPerformanceEmoji(successRate),
                              style: const TextStyle(fontSize: 50),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getPerformanceTitle(successRate),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getPerformanceSubtitle(successRate),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Main results card
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Performance stats
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  '$correctAnswers',
                                  'Correct',
                                  Icons.check_circle,
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  '${totalProblems - correctAnswers}',
                                  'Incorrect',
                                  Icons.cancel,
                                  Colors.red,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  '$successRate%',
                                  'Success Rate',
                                  Icons.emoji_events,
                                  _operationColor,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Time stats
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildTimeInfo(
                                  'Total Time',
                                  _formatDuration(widget.sessionStats.totalTime),
                                  Icons.schedule,
                                ),
                                _buildTimeInfo(
                                  'Avg per Problem',
                                  _formatDuration(Duration(
                                    milliseconds: widget.sessionStats.totalTime.inMilliseconds ~/ totalProblems,
                                  )),
                                  Icons.timer,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Problem review
                          if (widget.problems.any((p) => !p.isCorrect)) ...[
                            const Text(
                              'Review Incorrect Problems',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...widget.problems
                                .where((p) => !p.isCorrect)
                                .map((problem) => _buildProblemReviewCard(problem)),
                            const SizedBox(height: 24),
                          ],

                          // Encouragement and recommendation
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: _operationColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _operationColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _getEncouragementMessage(successRate),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _operationColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (_getDifficultyRecommendation() != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    _getDifficultyRecommendation()!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _practiceAgain,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Practice Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _operationColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _goHome,
                              icon: const Icon(Icons.home),
                              label: const Text('Home'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildProblemReviewCard(MathProblem problem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${problem.factor1} ${problem.operation.symbol} ${problem.factor2} = ${problem.correctAnswer}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Your answer: ${problem.userAnswer ?? 'No answer'}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
              Text(
                'Correct answer: ${problem.correctAnswer}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String _getPerformanceEmoji(int successRate) {
    if (successRate >= 90) return '🌟';
    if (successRate >= 80) return '🎉';
    if (successRate >= 70) return '👏';
    if (successRate >= 60) return '💪';
    return '🌱';
  }

  String _getPerformanceTitle(int successRate) {
    if (successRate >= 90) return 'Outstanding!';
    if (successRate >= 80) return 'Excellent Work!';
    if (successRate >= 70) return 'Great Job!';
    if (successRate >= 60) return 'Good Progress!';
    return 'Keep Practicing!';
  }

  String _getPerformanceSubtitle(int successRate) {
    if (successRate >= 90) return 'You\'re a math superstar!';
    if (successRate >= 80) return 'You\'ve mastered this level!';
    if (successRate >= 70) return 'You\'re making great progress!';
    if (successRate >= 60) return 'You\'re getting the hang of it!';
    return 'Every mistake is a learning opportunity!';
  }

  String _getEncouragementMessage(int successRate) {
    if (successRate >= 90) {
      return 'Amazing work! You\'ve mastered ${widget.sessionStats.operation.displayName.toLowerCase()}. Ready for a bigger challenge?';
    } else if (successRate >= 80) {
      return 'Excellent! You\'re doing really well with ${widget.sessionStats.operation.displayName.toLowerCase()}.';
    } else if (successRate >= 70) {
      return 'Great job! Keep practicing ${widget.sessionStats.operation.displayName.toLowerCase()} to improve even more.';
    } else if (successRate >= 60) {
      return 'Good progress! A little more practice with ${widget.sessionStats.operation.displayName.toLowerCase()} will help you improve.';
    } else {
      return 'Don\'t worry! ${widget.sessionStats.operation.displayName} can be tricky. Keep practicing and you\'ll get better!';
    }
  }

  String? _getDifficultyRecommendation() {
    final stats = widget.userProgress.getStatsForOperation(widget.sessionStats.operation);
    final recommendation = MathService.getDifficultyRecommendation(
      stats.successRate,
      DifficultyLevel.easy, // We'd need to track current difficulty level
    );
    
    if (recommendation != null) {
      if (stats.successRate >= 90) {
        return 'Consider trying ${recommendation.name.toLowerCase()} difficulty next time!';
      } else if (stats.successRate < 60) {
        return 'Try ${recommendation.name.toLowerCase()} difficulty for better success!';
      }
    }
    
    return null;
  }

  void _practiceAgain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DifficultySelectionScreen(
          operation: widget.sessionStats.operation,
        ),
      ),
    );
  }

  void _goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainMenuScreen()),
      (route) => false,
    );
  }
}
