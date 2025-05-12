// game_logic.dart:

import '../models/game_data.dart';

class GameLogic {
  // 0 represents empty, 1 represents X, 2 represents O
  List<List<int>> board = [
    [0, 0, 0],
    [0, 0, 0],
    [0, 0, 0],
  ];

  bool isPlayerXTurn = true; // X starts the game
  int moveCount = 0;
  bool gameOver = false;
  int winner = 0; // 0: no winner yet, 1: X wins, 2: O wins, 3: draw

  // Reset the game
  void resetGame() {
    board = [
      [0, 0, 0],
      [0, 0, 0],
      [0, 0, 0],
    ];
    isPlayerXTurn = true;
    moveCount = 0;
    gameOver = false;
    winner = 0;
  }

  // Make a move
  bool makeMove(int row, int col) {
    if (row < 0 || row > 2 || col < 0 || col > 2 || gameOver) {
      return false;
    }

    if (board[row][col] != 0) {
      return false;
    }

    board[row][col] = isPlayerXTurn ? 1 : 2;
    moveCount++;

    // Check for win
    if (checkWinner()) {
      gameOver = true;
      winner = isPlayerXTurn ? 1 : 2;
      return true;
    }

    // Check for draw
    if (moveCount == 9) {
      gameOver = true;
      winner = 3; // Draw
      return true;
    }

    isPlayerXTurn = !isPlayerXTurn;
    return true;
  }

  // Check for a winner
  bool checkWinner() {
    int currentPlayer = isPlayerXTurn ? 1 : 2;

    // Check rows
    for (int i = 0; i < 3; i++) {
      if (board[i][0] == currentPlayer &&
          board[i][1] == currentPlayer &&
          board[i][2] == currentPlayer) {
        return true;
      }
    }

    // Check columns
    for (int i = 0; i < 3; i++) {
      if (board[0][i] == currentPlayer &&
          board[1][i] == currentPlayer &&
          board[2][i] == currentPlayer) {
        return true;
      }
    }

    // Check diagonals
    if (board[0][0] == currentPlayer &&
        board[1][1] == currentPlayer &&
        board[2][2] == currentPlayer) {
      return true;
    }

    if (board[0][2] == currentPlayer &&
        board[1][1] == currentPlayer &&
        board[2][0] == currentPlayer) {
      return true;
    }

    return false;
  }

  // Get game result for Firebase
  GameResult getGameResult() {
    if (!gameOver) return GameResult.ongoing;
    if (winner == 3) return GameResult.draw;
    return winner == 1 ? GameResult.win : GameResult.loss;
  }
}
