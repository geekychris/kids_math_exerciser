import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_settings.dart';
import '../models/math_problem.dart';
import '../models/math_operation.dart';
import '../models/user_progress.dart';
import '../services/math_service.dart';
import '../services/storage_service.dart';
import 'results_screen.dart';

class PracticeScreen extends StatefulWidget {
  final GameSettings settings;

  const PracticeScreen({Key? key, required this.settings}) : super(key: key);

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> with TickerProviderStateMixin {
  List<MathProblem> _problems = [];
  int _currentProblemIndex = 0;
  final List<TextEditingController> _answerControllers = [];
  final List<FocusNode> _focusNodes = [];
  
  UserProgress? _userProgress;
  
  DateTime? _sessionStartTime;
  DateTime? _problemStartTime;
  
  int _consecutiveCorrect = 0;
  int _sessionCorrect = 0;
  int _sessionIncorrect = 0;
  
  String _feedbackMessage = '';
  bool _showingFeedback = false;
  Color _feedbackColor = Colors.green;
  
  late AnimationController _feedbackAnimationController;
  late Animation<double> _feedbackAnimation;
  
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  Color get _operationColor {
    switch (widget.settings.operation) {
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
    _initializeSession();
  }

  void _initializeAnimations() {
    _feedbackAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _feedbackAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _feedbackAnimationController, curve: Curves.bounceOut),
    );

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressAnimationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeSession() async {
    _userProgress = await StorageService.loadProgress() ?? UserProgress();
    _sessionStartTime = DateTime.now();
    
    // Generate problems
    _problems = MathService.generateVariedProblems(widget.settings);
    
    // Initialize controllers and focus nodes
    if (widget.settings.multipleProblems) {
      for (int i = 0; i < _problems.length; i++) {
        _answerControllers.add(TextEditingController());
        _focusNodes.add(FocusNode());
      }
    } else {
      _answerControllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
    
    _problemStartTime = DateTime.now();
    _progressAnimationController.forward();
    
    setState(() {});
    
    // Focus on first input
    if (_focusNodes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[0].requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _feedbackAnimationController.dispose();
    _progressAnimationController.dispose();
    for (final controller in _answerControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_problems.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.settings.operation.displayName} Practice'),
        backgroundColor: _operationColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showQuitDialog,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
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
          child: Column(
            children: [
              // Progress indicator
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.settings.multipleProblems 
                                ? 'Session Progress'
                                : 'Problem ${_currentProblemIndex + 1} of ${_problems.length}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF374151),
                              ),
                            ),
                            Text(
                              '${_sessionCorrect}/${_sessionCorrect + _sessionIncorrect} ✓',
                              style: TextStyle(
                                fontSize: 14,
                                color: _operationColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: widget.settings.multipleProblems
                            ? (_sessionCorrect + _sessionIncorrect) / _problems.length
                            : (_currentProblemIndex + 1) / _problems.length,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(_operationColor),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Feedback message
              if (_showingFeedback)
                AnimatedBuilder(
                  animation: _feedbackAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _feedbackAnimation.value,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _feedbackColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _feedbackColor, width: 2),
                        ),
                        child: Text(
                          _feedbackMessage,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _feedbackColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),

              // Problem area
              Expanded(
                child: widget.settings.multipleProblems
                    ? _buildMultipleProblemsView()
                    : _buildSingleProblemView(),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: widget.settings.multipleProblems
                    ? _buildSubmitAllButton()
                    : _buildSingleProblemButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSingleProblemView() {
    final problem = _problems[_currentProblemIndex];
    
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(32),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Problem text
            Text(
              '${problem.factor1} ${problem.operation.symbol} ${problem.factor2}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Equals sign and input
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '=',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(width: 24),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _answerControllers[0],
                    focusNode: _focusNodes[0],
                    decoration: InputDecoration(
                      hintText: '?',
                      hintStyle: const TextStyle(fontSize: 32, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.numberWithOptions(signed: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9]*')),
                    ],
                    onSubmitted: (_) => _checkSingleAnswer(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleProblemsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          for (int i = 0; i < _problems.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _problems[i].isAnswered
                    ? (_problems[i].isCorrect ? Colors.green.shade50 : Colors.red.shade50)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _problems[i].isAnswered
                      ? (_problems[i].isCorrect ? Colors.green : Colors.red)
                      : Colors.grey.shade300,
                  width: _problems[i].isAnswered ? 2 : 1,
                ),
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
                  // Problem number
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _operationColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _operationColor,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Problem text
                  Expanded(
                    child: Text(
                      '${_problems[i].factor1} ${_problems[i].operation.symbol} ${_problems[i].factor2} =',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  
                  // Answer input
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _answerControllers[i],
                      focusNode: _focusNodes[i],
                      enabled: !_problems[i].isAnswered,
                      decoration: InputDecoration(
                        hintText: '?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: _problems[i].isAnswered
                            ? Colors.grey.shade200
                            : Colors.grey.shade100,
                      ),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(signed: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9]*')),
                      ],
                    ),
                  ),
                  
                  // Result icon
                  if (_problems[i].isAnswered) ...[
                    const SizedBox(width: 12),
                    Icon(
                      _problems[i].isCorrect ? Icons.check_circle : Icons.cancel,
                      color: _problems[i].isCorrect ? Colors.green : Colors.red,
                      size: 24,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSingleProblemButtons() {
    return Row(
      children: [
        if (_currentProblemIndex > 0)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _previousProblem,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
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
        
        if (_currentProblemIndex > 0) const SizedBox(width: 16),
        
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _checkSingleAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: _operationColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: const Text(
              'Submit Answer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitAllButton() {
    final allAnswered = _problems.every((p) => p.isAnswered);
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: allAnswered ? _finishSession : _checkAllAnswers,
        style: ElevatedButton.styleFrom(
          backgroundColor: allAnswered ? Colors.green : _operationColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Text(
          allAnswered ? 'Finish Session' : 'Check All Answers',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _checkSingleAnswer() {
    final answer = MathService.parseAnswer(_answerControllers[0].text);
    if (answer == null) {
      _showFeedback('Please enter a valid number!', Colors.orange);
      return;
    }

    final problem = _problems[_currentProblemIndex];
    final isCorrect = problem.submitAnswer(answer);
    
    if (isCorrect) {
      _consecutiveCorrect++;
      _sessionCorrect++;
    } else {
      _consecutiveCorrect = 0;
      _sessionIncorrect++;
    }

    _userProgress!.updateProgress(problem);
    _savePogress();

    final message = MathService.getEncouragementMessage(isCorrect, _consecutiveCorrect);
    _showFeedback(message, isCorrect ? Colors.green : Colors.red);

    // Auto-advance after showing feedback
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        if (_currentProblemIndex < _problems.length - 1) {
          _nextProblem();
        } else {
          _finishSession();
        }
      }
    });
  }

  void _checkAllAnswers() {
    int newlyAnswered = 0;
    
    for (int i = 0; i < _problems.length; i++) {
      if (!_problems[i].isAnswered) {
        final answer = MathService.parseAnswer(_answerControllers[i].text);
        if (answer != null) {
          final isCorrect = _problems[i].submitAnswer(answer);
          if (isCorrect) {
            _sessionCorrect++;
          } else {
            _sessionIncorrect++;
          }
          _userProgress!.updateProgress(_problems[i]);
          newlyAnswered++;
        }
      }
    }

    if (newlyAnswered > 0) {
      _savePogress();
      final allAnswered = _problems.every((p) => p.isAnswered);
      final message = allAnswered 
          ? 'All done! Great job! 🎉'
          : 'Checked $newlyAnswered answers!';
      _showFeedback(message, Colors.blue);
    }

    setState(() {});
  }

  void _nextProblem() {
    if (_currentProblemIndex < _problems.length - 1) {
      setState(() {
        _currentProblemIndex++;
        _answerControllers[0].clear();
        _problemStartTime = DateTime.now();
      });
      _focusNodes[0].requestFocus();
    }
  }

  void _previousProblem() {
    if (_currentProblemIndex > 0) {
      setState(() {
        _currentProblemIndex--;
        _answerControllers[0].text = _problems[_currentProblemIndex].userAnswer?.toString() ?? '';
        _problemStartTime = DateTime.now();
      });
      _focusNodes[0].requestFocus();
    }
  }

  void _showFeedback(String message, Color color) {
    setState(() {
      _feedbackMessage = message;
      _feedbackColor = color;
      _showingFeedback = true;
    });

    _feedbackAnimationController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _feedbackAnimationController.reverse().then((_) {
            setState(() {
              _showingFeedback = false;
            });
          });
        }
      });
    });
  }

  void _finishSession() {
    final sessionStats = SessionStats(
      sessionDate: DateTime.now(),
      operation: widget.settings.operation,
      totalProblems: _problems.length,
      correctAnswers: _sessionCorrect,
      incorrectAnswers: _sessionIncorrect,
      totalTime: DateTime.now().difference(_sessionStartTime!),
    );

    _userProgress!.addSession(sessionStats);
    _savePogress();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsScreen(
          problems: _problems,
          sessionStats: sessionStats,
          userProgress: _userProgress!,
        ),
      ),
    );
  }

  Future<void> _savePogress() async {
    await StorageService.saveProgress(_userProgress!);
  }

  void _showQuitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit Session?'),
        content: const Text('Your progress will be saved, but you won\'t get a completion summary.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              _savePogress();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('Quit'),
          ),
        ],
      ),
    );
  }
}
