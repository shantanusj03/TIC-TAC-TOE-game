  // player.dart:

  class Player {
    final String id;
    final String displayName;
    int wins;
    int losses;
    int draws;

    Player({
      required this.id,
      required this.displayName,
      this.wins = 0,
      this.losses = 0,
      this.draws = 0,
    });

    Map<String, dynamic> toMap() {
      return {
        'id': id,
        'displayName': displayName,
        'wins': wins,
        'losses': losses,
        'draws': draws,
      };
    }

    factory Player.fromMap(Map<String, dynamic> map) {
      return Player(
        id: map['id'],
        displayName: map['displayName'],
        wins: map['wins'] ?? 0,
        losses: map['losses'] ?? 0,
        draws: map['draws'] ?? 0,
      );
    }
  }
