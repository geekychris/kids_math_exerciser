enum MathOperation {
  addition('+', 'Addition'),
  subtraction('-', 'Subtraction'),
  multiplication('×', 'Multiplication'),
  division('÷', 'Division');

  const MathOperation(this.symbol, this.displayName);

  final String symbol;
  final String displayName;

  /// Calculates the result of the operation
  double calculate(double factor1, double factor2) {
    switch (this) {
      case MathOperation.addition:
        return factor1 + factor2;
      case MathOperation.subtraction:
        return factor1 - factor2;
      case MathOperation.multiplication:
        return factor1 * factor2;
      case MathOperation.division:
        return factor1 / factor2;
    }
  }

  /// Validates if the operation makes sense with given factors
  bool isValidOperation(int factor1, int factor2) {
    switch (this) {
      case MathOperation.division:
        return factor2 != 0 && factor1 % factor2 == 0; // Only allow whole number results
      case MathOperation.subtraction:
        return factor1 >= factor2; // Only allow positive results
      default:
        return true;
    }
  }
}
