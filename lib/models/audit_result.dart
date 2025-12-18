class AuditResult {
  final String title;
  final bool isSafe;
  final String recommendation;

  AuditResult({
    required this.title,
    required this.isSafe,
    required this.recommendation,
  });
}