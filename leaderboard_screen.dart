// leaderboard_screen.dart:

import 'package:flutter/material.dart';
import '../models/player.dart';
import '../score/score_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final ScoreService _scoreService = ScoreService();
  List<Player> _players = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Player> players = await _scoreService.getTopPlayers();
      setState(() {
        _players = players;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading leaderboard: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _players.isEmpty
          ? const Center(child: Text('No player data available'))
          : RefreshIndicator(
        onRefresh: _loadLeaderboard,
        child: ListView.builder(
          itemCount: _players.length,
          itemBuilder: (context, index) {
            final player = _players[index];
            return ListTile(
              leading: CircleAvatar(
                child: Text('${index + 1}'),
              ),
              title: Text(player.displayName),
              subtitle: Text('Wins: ${player.wins}, Losses: ${player.losses}, Draws: ${player.draws}'),
              trailing: Text(
                'W/L: ${player.wins}/${player.losses}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ),
    );
  }
}
