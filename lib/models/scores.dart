// Map<String,double> clusters; // anxiety,depression,panic,anger,numb,burnout,recovery
// String top;
// String? secondary;

class ClusterScores {
  final Map<String, double>
  scores; // anxiety,depression,panic,anger,numb,burnout,recovery
  final String top;
  final String? secondary;

  ClusterScores({required this.scores, required this.top, this.secondary});
}
