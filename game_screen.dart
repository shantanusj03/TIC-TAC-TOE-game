// import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';
// import 'dart:math' as math;
// import 'game_logic.dart';
// import '../auth/auth_service.dart';
// import '../score/score_service.dart';
// import '../score/leaderboard_screen.dart';
// import '../models/game_data.dart';
//
// class GameScreen extends StatefulWidget {
//   const GameScreen({Key? key}) : super(key: key);
//
//   @override
//   _GameScreenState createState() => _GameScreenState();
// }
//
// class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
//   final GameLogic _gameLogic = GameLogic();
//   final AuthService _authService = AuthService();
//   final ScoreService _scoreService = ScoreService();
//   final _uuid = const Uuid();
//   bool _isLoading = false;
//   String _message = "Player X's turn";
//
//   // Animation controllers
//   late AnimationController _boardController;
//   late AnimationController _messageController;
//   late AnimationController _buttonController;
//
//   // Animations
//   late Animation<double> _boardScaleAnimation;
//   late Animation<double> _messageScaleAnimation;
//   late Animation<double> _buttonRotationAnimation;
//
//   // List to track new moves for animations
//   final List<List<bool>> _newMoves = List.generate(
//       3, (_) => List.generate(3, (_) => false)
//   );
//
//   @override
//   void initState() {
//     super.initState();
//     _checkUser();
//
//     // Setup animations
//     _boardController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );
//
//     _messageController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//
//     _buttonController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2000),
//     )..repeat(reverse: true);
//
//     _boardScaleAnimation = CurvedAnimation(
//       parent: _boardController,
//       curve: Curves.elasticOut,
//     );
//
//     _messageScaleAnimation = CurvedAnimation(
//       parent: _messageController,
//       curve: Curves.elasticOut,
//     );
//
//     _buttonRotationAnimation = Tween<double>(
//       begin: -0.05,
//       end: 0.05,
//     ).animate(CurvedAnimation(
//       parent: _buttonController,
//       curve: Curves.easeInOut,
//     ));
//
//     // Initial animations
//     _boardController.forward();
//     _messageController.forward();
//   }
//
//   @override
//   void dispose() {
//     _boardController.dispose();
//     _messageController.dispose();
//     _buttonController.dispose();
//     super.dispose();
//   }
//
//   void _checkUser() async {
//     if (_authService.currentUser == null) {
//       if (mounted) {
//         Navigator.pushReplacementNamed(context, '/login');
//       }
//     }
//   }
//
//   void _handleTileTap(int row, int col) {
//     if (_gameLogic.gameOver || _isLoading) return;
//
//     setState(() {
//       bool validMove = _gameLogic.makeMove(row, col);
//       if (validMove) {
//         // Mark this move as new for animation
//         _newMoves[row][col] = true;
//
//         // Reset message animation
//         _messageController.reset();
//         _messageController.forward();
//
//         if (_gameLogic.gameOver) {
//           if (_gameLogic.winner == 1) {
//             _message = 'Player X wins!';
//             _saveGameResult(GameResult.win);
//           } else if (_gameLogic.winner == 2) {
//             _message = 'Player O wins!';
//             _saveGameResult(GameResult.loss);
//           } else {
//             _message = 'It\'s a draw!';
//             _saveGameResult(GameResult.draw);
//           }
//         } else {
//           _message = _gameLogic.isPlayerXTurn ? "Player X's turn" : "Player O's turn";
//         }
//       }
//     });
//
//     // Reset new move status after a delay
//     Future.delayed(const Duration(milliseconds: 800), () {
//       if (mounted) {
//         setState(() {
//           _newMoves[row][col] = false;
//         });
//       }
//     });
//   }
//
//   void _saveGameResult(GameResult result) async {
//     if (_authService.currentUser == null) return;
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       String currentUserId = _authService.currentUser!.uid;
//       String player2Id = "computer";
//
//       String winnerId = result == GameResult.win ? currentUserId :
//       result == GameResult.loss ? player2Id : "";
//
//       GameData gameData = GameData(
//         id: _uuid.v4(),
//         player1Id: currentUserId,
//         player2Id: player2Id,
//         winnerUserId: winnerId,
//         timestamp: DateTime.now(),
//         result: result,
//       );
//
//       await _scoreService.saveGameResult(gameData);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error saving game result: ${e.toString()}'),
//           backgroundColor: Colors.red.shade800,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   bool _isWinningTile(int row, int col) {
//     if (!_gameLogic.gameOver || _gameLogic.winner == 0) return false;
//
//     // Check if this is part of the winning line
//     // This is a simplified approach since we don't have access to actual winning line data
//     // You may need to adjust this based on your GameLogic implementation
//     if (_gameLogic.winner == 1 || _gameLogic.winner == 2) {
//       // Check rows
//       if (_gameLogic.board[row][0] == _gameLogic.board[row][1] &&
//           _gameLogic.board[row][1] == _gameLogic.board[row][2] &&
//           _gameLogic.board[row][0] != 0) {
//         return true;
//       }
//
//       // Check columns
//       if (_gameLogic.board[0][col] == _gameLogic.board[1][col] &&
//           _gameLogic.board[1][col] == _gameLogic.board[2][col] &&
//           _gameLogic.board[0][col] != 0) {
//         return true;
//       }
//
//       // Check diagonals
//       if (row == col &&
//           _gameLogic.board[0][0] == _gameLogic.board[1][1] &&
//           _gameLogic.board[1][1] == _gameLogic.board[2][2] &&
//           _gameLogic.board[0][0] != 0) {
//         return true;
//       }
//
//       if (row + col == 2 &&
//           _gameLogic.board[0][2] == _gameLogic.board[1][1] &&
//           _gameLogic.board[1][1] == _gameLogic.board[2][0] &&
//           _gameLogic.board[0][2] != 0) {
//         return true;
//       }
//     }
//
//     return false;
//   }
//
//   void _resetGame() {
//     setState(() {
//       _gameLogic.resetGame();
//       _message = "Player X's turn";
//
//       // Reset all new move markers
//       for (int i = 0; i < 3; i++) {
//         for (int j = 0; j < 3; j++) {
//           _newMoves[i][j] = false;
//         }
//       }
//
//       // Reset and play animations
//       _boardController.reset();
//       _messageController.reset();
//       _boardController.forward();
//       _messageController.forward();
//     });
//   }
//
//   void _logout() async {
//     await _authService.signOut();
//     if (mounted) {
//       Navigator.pushReplacementNamed(context, '/login');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF1E2A30),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1E2A30),
//         elevation: 0,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.sports_esports,
//               color: Colors.white,
//               size: 30,
//             ),
//             const SizedBox(width: 10),
//             Text(
//               'Tic-Tac-Toe',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 24,
//               ),
//             ),
//           ],
//         ),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.leaderboard, color: Colors.white),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 PageRouteBuilder(
//                   pageBuilder: (context, animation, secondaryAnimation) => const LeaderboardScreen(),
//                   transitionsBuilder: (context, animation, secondaryAnimation, child) {
//                     return FadeTransition(opacity: animation, child: child);
//                   },
//                 ),
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.logout, color: Colors.white),
//             onPressed: _logout,
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               const Color(0xFF1E2A30),
//               const Color(0xFF0D1A20),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Center(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Animated Status Message
//                     ScaleTransition(
//                       scale: _messageScaleAnimation,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//                         decoration: BoxDecoration(
//                           color: _gameLogic.gameOver
//                               ? (_gameLogic.winner != 0 ? Color(0xFF00E676) : Colors.orange)
//                               : Colors.blueGrey.shade800,
//                           borderRadius: BorderRadius.circular(30),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black26,
//                               blurRadius: 10,
//                               offset: Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: Text(
//                           _message,
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 40),
//
//                     // Game Board
//                     _buildGameBoard(),
//
//                     const SizedBox(height: 40),
//
//                     // New Game Button with rotation animation
//                     AnimatedBuilder(
//                       animation: _buttonController,
//                       builder: (context, child) {
//                         return Transform.rotate(
//                           angle: _gameLogic.gameOver ? _buttonRotationAnimation.value : 0,
//                           child: child,
//                         );
//                       },
//                       child: ElevatedButton(
//                         onPressed: _gameLogic.gameOver ? _resetGame : null,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Color(0xFF00E676),
//                           foregroundColor: Colors.black,
//                           padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           elevation: 8,
//                           shadowColor: Color(0xFF00E676).withOpacity(0.5),
//                           minimumSize: Size(300, 50),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(Icons.refresh, size: 28),
//                             const SizedBox(width: 8),
//                             Text(
//                               'New Game',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//
//                     // Loading Indicator
//                     if (_isLoading)
//                       Padding(
//                         padding: const EdgeInsets.all(24.0),
//                         child: CircularProgressIndicator(
//                           color: Color(0xFF00E676),
//                           strokeWidth: 5,
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildGameBoard() {
//     return ScaleTransition(
//       scale: _boardScaleAnimation,
//       child: Container(
//         width: 320,
//         height: 320,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.blueGrey.shade900,
//               Colors.blueGrey.shade800,
//             ],
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black38,
//               blurRadius: 15,
//               offset: Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: List.generate(3, (row) {
//               return Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: List.generate(3, (col) {
//                   return _buildTile(row, col);
//                 }),
//               );
//             }),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTile(int row, int col) {
//     int value = _gameLogic.board[row][col];
//     bool isWinningTile = _isWinningTile(row, col);
//     bool isNewMove = _newMoves[row][col];
//
//     return GestureDetector(
//       onTap: () => _handleTileTap(row, col),
//       child: Container(
//         width: 90,
//         height: 90,
//         decoration: BoxDecoration(
//           color: isWinningTile ? Color(0xFF00E676).withOpacity(0.3) : Colors.blueGrey.shade700.withOpacity(0.5),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isWinningTile ? Color(0xFF00E676) : Colors.blueGrey.shade600,
//             width: 2,
//           ),
//         ),
//         child: Center(
//           child: value == 0
//               ? SizedBox() // Empty tile
//               : isNewMove
//               ? _buildAnimatedSymbol(value)
//               : _buildSymbol(value),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAnimatedSymbol(int value) {
//     return TweenAnimationBuilder(
//       tween: Tween<double>(begin: 0.0, end: 1.0),
//       duration: Duration(milliseconds: 400),
//       curve: Curves.elasticOut,
//       builder: (context, double size, child) {
//         return Transform.scale(
//           scale: size,
//           child: _buildSymbol(value),
//         );
//       },
//     );
//   }
//
//   Widget _buildSymbol(int value) {
//     return Text(
//       value == 1 ? 'X' : 'O',
//       style: TextStyle(
//         fontSize: 60,
//         fontWeight: FontWeight.bold,
//         color: value == 1 ? Colors.blue.shade300 : Colors.red.shade300,
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:math' as math;
import 'game_logic.dart';
import '../auth/auth_service.dart';
import '../score/score_service.dart';
import '../score/leaderboard_screen.dart';
import '../models/game_data.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final GameLogic _gameLogic = GameLogic();
  final AuthService _authService = AuthService();
  final ScoreService _scoreService = ScoreService();
  final _uuid = const Uuid();
  bool _isLoading = false;
  String _message = "Player X's turn";

  // Animation controllers
  late AnimationController _boardController;
  late AnimationController _messageController;
  late AnimationController _buttonController;

  // Animations
  late Animation<double> _boardScaleAnimation;
  late Animation<double> _messageScaleAnimation;
  late Animation<double> _buttonRotationAnimation;

  // List to track new moves for animations
  final List<List<bool>> _newMoves = List.generate(
      3, (_) => List.generate(3, (_) => false)
  );

  @override
  void initState() {
    super.initState();
    _checkUser();

    // Setup animations
    _boardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _messageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _boardScaleAnimation = CurvedAnimation(
      parent: _boardController,
      curve: Curves.elasticOut,
    );

    _messageScaleAnimation = CurvedAnimation(
      parent: _messageController,
      curve: Curves.elasticOut,
    );

    _buttonRotationAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));

    // Initial animations
    _boardController.forward();
    _messageController.forward();
  }

  @override
  void dispose() {
    _boardController.dispose();
    _messageController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _checkUser() async {
    if (_authService.currentUser == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  void _handleTileTap(int row, int col) {
    if (_gameLogic.gameOver || _isLoading) return;

    setState(() {
      bool validMove = _gameLogic.makeMove(row, col);
      if (validMove) {
        // Mark this move as new for animation
        _newMoves[row][col] = true;

        // Reset message animation
        _messageController.reset();
        _messageController.forward();

        if (_gameLogic.gameOver) {
          if (_gameLogic.winner == 1) {
            _message = 'Player X wins!';
            _saveGameResult(GameResult.win);
          } else if (_gameLogic.winner == 2) {
            _message = 'Player O wins!';
            _saveGameResult(GameResult.loss);
          } else {
            _message = 'It\'s a draw!';
            _saveGameResult(GameResult.draw);
          }
        } else {
          _message = _gameLogic.isPlayerXTurn ? "Player X's turn" : "Player O's turn";
        }
      }
    });

    // Reset new move status after a delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _newMoves[row][col] = false;
        });
      }
    });
  }

  void _saveGameResult(GameResult result) async {
    if (_authService.currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String currentUserId = _authService.currentUser!.uid;
      String player2Id = "computer";

      String winnerId = result == GameResult.win ? currentUserId :
      result == GameResult.loss ? player2Id : "";

      GameData gameData = GameData(
        id: _uuid.v4(),
        player1Id: currentUserId,
        player2Id: player2Id,
        winnerUserId: winnerId,
        timestamp: DateTime.now(),
        result: result,
      );

      await _scoreService.saveGameResult(gameData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving game result: ${e.toString()}'),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isWinningTile(int row, int col) {
    if (!_gameLogic.gameOver || _gameLogic.winner == 0) return false;

    // Check if this is part of the winning line
    // This is a simplified approach since we don't have access to actual winning line data
    // You may need to adjust this based on your GameLogic implementation
    if (_gameLogic.winner == 1 || _gameLogic.winner == 2) {
      // Check rows
      if (_gameLogic.board[row][0] == _gameLogic.board[row][1] &&
          _gameLogic.board[row][1] == _gameLogic.board[row][2] &&
          _gameLogic.board[row][0] != 0) {
        return true;
      }

      // Check columns
      if (_gameLogic.board[0][col] == _gameLogic.board[1][col] &&
          _gameLogic.board[1][col] == _gameLogic.board[2][col] &&
          _gameLogic.board[0][col] != 0) {
        return true;
      }

      // Check diagonals
      if (row == col &&
          _gameLogic.board[0][0] == _gameLogic.board[1][1] &&
          _gameLogic.board[1][1] == _gameLogic.board[2][2] &&
          _gameLogic.board[0][0] != 0) {
        return true;
      }

      if (row + col == 2 &&
          _gameLogic.board[0][2] == _gameLogic.board[1][1] &&
          _gameLogic.board[1][1] == _gameLogic.board[2][0] &&
          _gameLogic.board[0][2] != 0) {
        return true;
      }
    }

    return false;
  }

  void _resetGame() {
    setState(() {
      _gameLogic.resetGame();
      _message = "Player X's turn";

      // Reset all new move markers
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          _newMoves[i][j] = false;
        }
      }

      // Reset and play animations
      _boardController.reset();
      _messageController.reset();
      _boardController.forward();
      _messageController.forward();
    });
  }

  void _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2A30),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2A30),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_esports,
              color: Colors.white,
              size: 30,
            ),
            const SizedBox(width: 10),
            Text(
              'Tic-Tac-Toe',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const LeaderboardScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1E2A30),
              const Color(0xFF0D1A20),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Status Message
                    ScaleTransition(
                      scale: _messageScaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        decoration: BoxDecoration(
                          color: _gameLogic.gameOver
                              ? (_gameLogic.winner != 0 ? Color(0xFF00E676) : Colors.orange)
                              : Colors.blueGrey.shade800,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          _message,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Game Board
                    _buildGameBoard(),

                    const SizedBox(height: 40),

                    // Game control buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // New Game Button with rotation animation
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _buttonController,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _gameLogic.gameOver ? _buttonRotationAnimation.value : 0,
                                child: child,
                              );
                            },
                            child: ElevatedButton(
                              onPressed: _gameLogic.gameOver ? _resetGame : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF00E676),
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 8,
                                shadowColor: Color(0xFF00E676).withOpacity(0.5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.refresh, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    'New Game',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Logout Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _logout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 8,
                              shadowColor: Colors.redAccent.withOpacity(0.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Loading Indicator
                    if (_isLoading)
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(
                          color: Color(0xFF00E676),
                          strokeWidth: 5,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameBoard() {
    return ScaleTransition(
      scale: _boardScaleAnimation,
      child: Container(
        width: 320,
        height: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blueGrey.shade900,
              Colors.blueGrey.shade800,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (row) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (col) {
                  return _buildTile(row, col);
                }),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(int row, int col) {
    int value = _gameLogic.board[row][col];
    bool isWinningTile = _isWinningTile(row, col);
    bool isNewMove = _newMoves[row][col];

    return GestureDetector(
      onTap: () => _handleTileTap(row, col),
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: isWinningTile ? Color(0xFF00E676).withOpacity(0.3) : Colors.blueGrey.shade700.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isWinningTile ? Color(0xFF00E676) : Colors.blueGrey.shade600,
            width: 2,
          ),
        ),
        child: Center(
          child: value == 0
              ? SizedBox() // Empty tile
              : isNewMove
              ? _buildAnimatedSymbol(value)
              : _buildSymbol(value),
        ),
      ),
    );
  }

  Widget _buildAnimatedSymbol(int value) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      builder: (context, double size, child) {
        return Transform.scale(
          scale: size,
          child: _buildSymbol(value),
        );
      },
    );
  }

  Widget _buildSymbol(int value) {
    return Text(
      value == 1 ? 'X' : 'O',
      style: TextStyle(
        fontSize: 60,
        fontWeight: FontWeight.bold,
        color: value == 1 ? Colors.blue.shade300 : Colors.red.shade300,
      ),
    );
  }
}
