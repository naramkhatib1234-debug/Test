/// Snapshot of a finished run, handed from the game to the game-over screen.
class GameResult {
  const GameResult({
    required this.score,
    required this.bestScore,
    required this.isNewBest,
    required this.coinsEarned,
  });

  final int score;
  final int bestScore;
  final bool isNewBest;
  final int coinsEarned;
}
