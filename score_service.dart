// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/player.dart';
// import '../models/game_data.dart';
//
// class ScoreService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Collection references
//   CollectionReference get _usersCollection => _firestore.collection('users');
//   CollectionReference get _gamesCollection => _firestore.collection('games');
//
//   // Create or update player profile
//   Future<void> createOrUpdatePlayer(Player player) async {
//     try {
//       await _usersCollection.doc(player.id).set(player.toMap());
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   // Get player by ID
//   Future<Player?> getPlayerById(String userId) async {
//     try {
//       DocumentSnapshot doc = await _usersCollection.doc(userId).get();
//       if (doc.exists) {
//         return Player.fromMap(doc.data() as Map<String, dynamic>);
//       }
//       return null;
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   // Update player stats after game
//   Future<void> updatePlayerStats(String playerId, GameResult result) async {
//     try {
//       DocumentReference playerRef = _usersCollection.doc(playerId);
//
//       return _firestore.runTransaction((transaction) async {
//         DocumentSnapshot playerSnapshot = await transaction.get(playerRef);
//
//         if (!playerSnapshot.exists) {
//           throw Exception("Player does not exist!");
//         }
//
//         Player player = Player.fromMap(playerSnapshot.data() as Map<String, dynamic>);
//
//         switch (result) {
//           case GameResult.win:
//             player.wins += 1;
//             break;
//           case GameResult.loss:
//             player.losses += 1;
//             break;
//           case GameResult.draw:
//             player.draws += 1;
//             break;
//           default:
//             break;
//         }
//
//         transaction.update(playerRef, player.toMap());
//       });
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   // Save game result
//   Future<void> saveGameResult(GameData gameData) async {
//     try {
//       await _gamesCollection.doc(gameData.id).set(gameData.toMap());
//
//       // Update player stats
//       if (gameData.result == GameResult.win) {
//         await updatePlayerStats(gameData.winnerUserId, GameResult.win);
//         String loserId = gameData.player1Id == gameData.winnerUserId
//             ? gameData.player2Id
//             : gameData.player1Id;
//         await updatePlayerStats(loserId, GameResult.loss);
//       } else if (gameData.result == GameResult.draw) {
//         await updatePlayerStats(gameData.player1Id, GameResult.draw);
//         await updatePlayerStats(gameData.player2Id, GameResult.draw);
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   // Get top players (leaderboard)
//   Future<List<Player>> getTopPlayers({int limit = 10}) async {
//     try {
//       QuerySnapshot snapshot = await _usersCollection
//           .orderBy('wins', descending: true)
//           .limit(limit)
//           .get();
//
//       return snapshot.docs
//           .map((doc) => Player.fromMap(doc.data() as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   // Get player game history
//   Future<List<GameData>> getPlayerGameHistory(String playerId) async {
//     try {
//       QuerySnapshot snapshot = await _gamesCollection
//           .where('player1Id', isEqualTo: playerId)
//           .orderBy('timestamp', descending: true)
//           .get();
//
//       QuerySnapshot snapshot2 = await _gamesCollection
//           .where('player2Id', isEqualTo: playerId)
//           .orderBy('timestamp', descending: true)
//           .get();
//
//       List<GameData> games = [];
//
//       games.addAll(snapshot.docs
//           .map((doc) => GameData.fromMap(doc.data() as Map<String, dynamic>))
//           .toList());
//
//       games.addAll(snapshot2.docs
//           .map((doc) => GameData.fromMap(doc.data() as Map<String, dynamic>))
//           .toList());
//
//       // Sort by timestamp
//       games.sort((a, b) => b.timestamp.compareTo(a.timestamp));
//
//       return games;
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/player.dart';
import '../models/game_data.dart';

class ScoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _gamesCollection => _firestore.collection('games');

  // Create or update player profile
  Future<void> createOrUpdatePlayer(Player player) async {
    try {
      await _usersCollection.doc(player.id).set(player.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Get player by ID
  Future<Player?> getPlayerById(String userId) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return Player.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Update player stats after game
  Future<void> updatePlayerStats(String playerId, GameResult result) async {
    try {
      DocumentReference playerRef = _usersCollection.doc(playerId);

      return _firestore.runTransaction((transaction) async {
        DocumentSnapshot playerSnapshot = await transaction.get(playerRef);

        if (!playerSnapshot.exists) {
          throw Exception("Player does not exist!");
        }

        Player player = Player.fromMap(playerSnapshot.data() as Map<String, dynamic>);

        switch (result) {
          case GameResult.win:
            player.wins += 1;
            break;
          case GameResult.loss:
            player.losses += 1;
            break;
          case GameResult.draw:
            player.draws += 1;
            break;
          default:
            break;
        }

        transaction.update(playerRef, player.toMap());
      });
    } catch (e) {
      rethrow;
    }
  }

  // Save game result
  Future<void> saveGameResult(GameData gameData) async {
    try {
      await _gamesCollection.doc(gameData.id).set(gameData.toMap());

      // Update player stats
      if (gameData.result == GameResult.win) {
        await updatePlayerStats(gameData.winnerUserId, GameResult.win);
        String loserId = gameData.player1Id == gameData.winnerUserId
            ? gameData.player2Id
            : gameData.player1Id;
        await updatePlayerStats(loserId, GameResult.loss);
      } else if (gameData.result == GameResult.draw) {
        await updatePlayerStats(gameData.player1Id, GameResult.draw);
        await updatePlayerStats(gameData.player2Id, GameResult.draw);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get top players (leaderboard)
  Future<List<Player>> getTopPlayers({int limit = 10}) async {
    try {
      QuerySnapshot snapshot = await _usersCollection
          .orderBy('wins', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Player.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get player game history
  Future<List<GameData>> getPlayerGameHistory(String playerId) async {
    try {
      QuerySnapshot snapshot = await _gamesCollection
          .where('player1Id', isEqualTo: playerId)
          .orderBy('timestamp', descending: true)
          .get();

      QuerySnapshot snapshot2 = await _gamesCollection
          .where('player2Id', isEqualTo: playerId)
          .orderBy('timestamp', descending: true)
          .get();

      List<GameData> games = [];

      games.addAll(snapshot.docs
          .map((doc) => GameData.fromMap(doc.data() as Map<String, dynamic>))
          .toList());

      games.addAll(snapshot2.docs
          .map((doc) => GameData.fromMap(doc.data() as Map<String, dynamic>))
          .toList());

      // Sort by timestamp
      games.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return games;
    } catch (e) {
      rethrow;
    }
  }

  // Get recent games for all players
  Future<List<GameData>> getRecentGames({int limit = 10}) async {
    try {
      QuerySnapshot snapshot = await _gamesCollection
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => GameData.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get player statistics summary
  Future<Map<String, dynamic>> getPlayerStats(String playerId) async {
    try {
      final player = await getPlayerById(playerId);
      if (player == null) {
        return {
          'totalGames': 0,
          'wins': 0,
          'losses': 0,
          'draws': 0,
          'winRate': 0.0,
        };
      }

      final totalGames = player.wins + player.losses + player.draws;
      final winRate = totalGames > 0 ? (player.wins / totalGames * 100) : 0.0;

      return {
        'totalGames': totalGames,
        'wins': player.wins,
        'losses': player.losses,
        'draws': player.draws,
        'winRate': winRate,
      };
    } catch (e) {
      rethrow;
    }
  }
}