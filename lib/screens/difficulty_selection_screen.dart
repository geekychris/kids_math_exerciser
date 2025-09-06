import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/math_operation.dart';
import '../models/game_settings.dart';
import 'practice_screen.dart';

class DifficultySelectionScreen extends StatefulWidget {
  final MathOperation operation;

  const DifficultySelectionScreen({Key? key, required this.operation}) : super(key: key);

  @override
  State<DifficultySelectionScreen> createState() => _DifficultySelectionScreenState();
}

class _DifficultySelectionScreenState extends State<DifficultySelectionScreen> {
  DifficultyLevel _selectedDifficulty = DifficultyLevel.easy;
  int _problemsPerSession = 10;
  bool _multipleProblems = false;
  bool _useCustomRanges = false;
  
  // Custom range controllers
  final _customMinFactor1Controller = TextEditingController();
  final _customMaxFactor1Controller = TextEditingController();
  final _customMinFactor2Controller = TextEditingController();
  final _customMaxFactor2Controller = TextEditingController();

  @override
  void dispose() {
    _customMinFactor1Controller.dispose();
    _customMaxFactor1Controller.dispose();
    _customMinFactor2Controller.dispose();
    _customMaxFactor2Controller.dispose();
    super.dispose();
  }

  Color get _operationColor {
    switch (widget.operation) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.operation.displayName} Settings'),
        backgroundColor: _operationColor,
        foregroundColor: Colors.white,
        elevation: 0,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _operationColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            widget.operation.symbol,
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: _operationColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Let\'s set up your ${widget.operation.displayName.toLowerCase()} practice!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF374151),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Difficulty Level Section
                _buildSectionCard(
                  title: '📊 Difficulty Level',
                  child: Column(
                    children: DifficultyLevel.values.map((difficulty) {
                      return _buildDifficultyOption(difficulty);
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Custom Ranges Section
                _buildSectionCard(
                  title: '🎯 Custom Number Ranges',
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Use custom ranges'),
                        subtitle: const Text('Override difficulty settings'),
                        value: _useCustomRanges,
                        onChanged: (value) {
                          setState(() {
                            _useCustomRanges = value;
                          });
                        },
                        activeColor: _operationColor,
                      ),
                      
                      if (_useCustomRanges) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildNumberInput(
                                'Factor 1 Min',
                                _customMinFactor1Controller,
                                '1',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildNumberInput(
                                'Factor 1 Max',
                                _customMaxFactor1Controller,
                                '10',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildNumberInput(
                                'Factor 2 Min',
                                _customMinFactor2Controller,
                                '1',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildNumberInput(
                                'Factor 2 Max',
                                _customMaxFactor2Controller,
                                '10',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Session Settings Section
                _buildSectionCard(
                  title: '⚙️ Session Settings',
                  child: Column(
                    children: [
                      // Problems per session
                      ListTile(
                        title: const Text('Problems per session'),
                        subtitle: Text('$_problemsPerSession problems'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: _problemsPerSession > 5
                                  ? () => setState(() => _problemsPerSession -= 5)
                                  : null,
                              icon: const Icon(Icons.remove),
                            ),
                            Text(
                              '$_problemsPerSession',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: _problemsPerSession < 50
                                  ? () => setState(() => _problemsPerSession += 5)
                                  : null,
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),
                      
                      // Multiple problems toggle
                      SwitchListTile(
                        title: const Text('Multiple problems per page'),
                        subtitle: const Text('Show several problems at once'),
                        value: _multipleProblems,
                        onChanged: (value) {
                          setState(() {
                            _multipleProblems = value;
                          });
                        },
                        activeColor: _operationColor,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Start Practice Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startPractice,
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
                      '🚀 Start Practice!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildDifficultyOption(DifficultyLevel difficulty) {
    final isSelected = _selectedDifficulty == difficulty;
    
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? _operationColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? _operationColor : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: ListTile(
        title: Text(
          difficulty.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? _operationColor : Colors.black87,
          ),
        ),
        subtitle: Text(
          'Numbers ${difficulty.minFactor} to ${difficulty.maxFactor}',
          style: TextStyle(
            color: isSelected ? _operationColor : Colors.grey,
          ),
        ),
        leading: Radio<DifficultyLevel>(
          value: difficulty,
          groupValue: _selectedDifficulty,
          onChanged: (value) {
            setState(() {
              _selectedDifficulty = value!;
            });
          },
          activeColor: _operationColor,
        ),
        onTap: () {
          setState(() {
            _selectedDifficulty = difficulty;
          });
        },
      ),
    );
  }

  Widget _buildNumberInput(String label, TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _operationColor, width: 2),
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
    );
  }

  void _startPractice() {
    // Validate custom ranges if they're being used
    if (_useCustomRanges) {
      final minFactor1 = int.tryParse(_customMinFactor1Controller.text);
      final maxFactor1 = int.tryParse(_customMaxFactor1Controller.text);
      final minFactor2 = int.tryParse(_customMinFactor2Controller.text);
      final maxFactor2 = int.tryParse(_customMaxFactor2Controller.text);

      if (minFactor1 == null || maxFactor1 == null || minFactor2 == null || maxFactor2 == null) {
        _showErrorDialog('Please fill in all custom range values.');
        return;
      }

      if (minFactor1 >= maxFactor1 || minFactor2 >= maxFactor2) {
        _showErrorDialog('Minimum values must be less than maximum values.');
        return;
      }

      if (minFactor1 < 0 || minFactor2 < 0) {
        _showErrorDialog('Values cannot be negative.');
        return;
      }
    }

    final settings = GameSettings(
      operation: widget.operation,
      difficulty: _selectedDifficulty,
      problemsPerSession: _problemsPerSession,
      multipleProblems: _multipleProblems,
      customMinFactor1: _useCustomRanges ? int.tryParse(_customMinFactor1Controller.text) : null,
      customMaxFactor1: _useCustomRanges ? int.tryParse(_customMaxFactor1Controller.text) : null,
      customMinFactor2: _useCustomRanges ? int.tryParse(_customMinFactor2Controller.text) : null,
      customMaxFactor2: _useCustomRanges ? int.tryParse(_customMaxFactor2Controller.text) : null,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PracticeScreen(settings: settings),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invalid Settings'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
