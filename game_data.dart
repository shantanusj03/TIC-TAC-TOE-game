enum GameResult { win, loss, draw, ongoing }

class GameData {
  final String id;
  final String player1Id;
  final String player2Id;
  final String winnerUserId;
  final DateTime timestamp;
  final GameResult result;

  GameData({
    required this.id,
    required this.player1Id,
    required this.player2Id,
    required this.winnerUserId,
    required this.timestamp,
    required this.result,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'player1Id': player1Id,
      'player2Id': player2Id,
      'winnerUserId': winnerUserId,
      'timestamp': timestamp.toIso8601String(),
      'result': result.toString(),
    };
  }

  factory GameData.fromMap(Map<String, dynamic> map) {
    return GameData(
      id: map['id'],
      player1Id: map['player1Id'],
      player2Id: map['player2Id'],
      winnerUserId: map['winnerUserId'],
      timestamp: DateTime.parse(map['timestamp']),
      result: GameResult.values.firstWhere(
            (e) => e.toString() == map['result'],
        orElse: () => GameResult.ongoing,
      ),
    );
  }
}