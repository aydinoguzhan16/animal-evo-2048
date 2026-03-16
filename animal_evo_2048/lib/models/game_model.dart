import 'dart:math';
import 'package:flutter/material.dart';

const Map<int, AnimalTileData> kAnimals = {
  2: AnimalTileData(emoji: '🐜', name: 'Karınca', bgColor: Color(0xFFEEE4DA), textColor: Color(0xFF776E65)),
  4: AnimalTileData(emoji: '🐝', name: 'Arı', bgColor: Color(0xFFFFF176), textColor: Color(0xFF5D4037)),
  8: AnimalTileData(emoji: '🦜', name: 'Sinek Kuşu', bgColor: Color(0xFF80DEEA), textColor: Color(0xFF00695C)),
  16: AnimalTileData(emoji: '🐭', name: 'Fare', bgColor: Color(0xFFCE93D8), textColor: Colors.white),
  32: AnimalTileData(emoji: '🐸', name: 'Kurbağa', bgColor: Color(0xFFA5D6A7), textColor: Color(0xFF1B5E20)),
  64: AnimalTileData(emoji: '🦔', name: 'Kirpi', bgColor: Color(0xFFBCAAA4), textColor: Colors.white),
  128: AnimalTileData(emoji: '🐱', name: 'Kedi', bgColor: Color(0xFFFFCC80), textColor: Color(0xFF4E342E)),
  256: AnimalTileData(emoji: '🐺', name: 'Kurt', bgColor: Color(0xFF90A4AE), textColor: Colors.white),
  512: AnimalTileData(emoji: '🦁', name: 'Aslan', bgColor: Color(0xFFFFB74D), textColor: Colors.white),
  1024: AnimalTileData(emoji: '🐴', name: 'At', bgColor: Color(0xFFA1887F), textColor: Colors.white),
  2048: AnimalTileData(emoji: '🦒', name: 'Zürafa', bgColor: Color(0xFFFFD54F), textColor: Color(0xFF4E342E)),
  4096: AnimalTileData(emoji: '🐘', name: 'Fil', bgColor: Color(0xFF78909C), textColor: Colors.white),
  8192: AnimalTileData(emoji: '🐋', name: 'Mavi Balina', bgColor: Color(0xFF1565C0), textColor: Colors.white),
};

class AnimalTileData {
  final String emoji;
  final String name;
  final Color bgColor;
  final Color textColor;
  const AnimalTileData({required this.emoji, required this.name, required this.bgColor, required this.textColor});
}

class Tile {
  int value;
  bool isNew;
  bool isMerged;
  Tile({this.value = 0, this.isNew = false, this.isMerged = false});
}

class GameModel extends ChangeNotifier {
  static const int size = 4;
  late List<List<Tile>> _board;
  int _score = 0;
  int _bestScore = 0;
  bool _gameOver = false;
  bool _won = false;
  bool _keepPlaying = false;
  final Random _random = Random();

  List<List<Tile>> get board => _board;
  int get score => _score;
  int get bestScore => _bestScore;
  bool get gameOver => _gameOver;
  bool get won => _won;
  bool get showWinDialog => _won && !_keepPlaying;

  GameModel() { newGame(); }

  void newGame() {
    _board = List.generate(size, (_) => List.generate(size, (_) => Tile()));
    _score = 0; _gameOver = false; _won = false; _keepPlaying = false;
    _addRandomTile(); _addRandomTile();
    notifyListeners();
  }

  void continueGame() { _keepPlaying = true; notifyListeners(); }

  void _addRandomTile() {
    final empty = <List<int>>[];
    for (int r = 0; r < size; r++)
      for (int c = 0; c < size; c++)
        if (_board[r][c].value == 0) empty.add([r, c]);
    if (empty.isEmpty) return;
    final pos = empty[_random.nextInt(empty.length)];
    _board[pos[0]][pos[1]] = Tile(value: _random.nextInt(10) < 9 ? 2 : 4, isNew: true);
  }

  bool move(String direction) {
    if (_gameOver || showWinDialog) return false;
    final oldValues = _boardValues();
    for (var row in _board) for (var tile in row) { tile.isNew = false; tile.isMerged = false; }
    switch (direction) {
      case 'left': _moveLeft(); break;
      case 'right': _moveRight(); break;
      case 'up': _moveUp(); break;
      case 'down': _moveDown(); break;
    }
    final changed = _boardValues() != oldValues;
    if (changed) {
      _addRandomTile();
      if (_score > _bestScore) _bestScore = _score;
      _checkGameState();
      notifyListeners();
    }
    return changed;
  }

  List<Tile> _mergeLine(List<Tile> line) {
    final filtered = line.where((t) => t.value != 0).toList();
    final result = <Tile>[];
    int i = 0;
    while (i < filtered.length) {
      if (i + 1 < filtered.length && filtered[i].value == filtered[i + 1].value) {
        final newVal = filtered[i].value * 2;
        result.add(Tile(value: newVal, isMerged: true));
        _score += newVal;
        if (newVal == 8192) _won = true;
        i += 2;
      } else { result.add(filtered[i]); i++; }
    }
    while (result.length < size) result.add(Tile());
    return result;
  }

  void _moveLeft() { for (int r = 0; r < size; r++) _board[r] = _mergeLine(_board[r]); }
  void _moveRight() { for (int r = 0; r < size; r++) _board[r] = _mergeLine(_board[r].reversed.toList()).reversed.toList(); }
  void _moveUp() { for (int c = 0; c < size; c++) { final col = List.generate(size, (r) => _board[r][c]); final m = _mergeLine(col); for (int r = 0; r < size; r++) _board[r][c] = m[r]; } }
  void _moveDown() { for (int c = 0; c < size; c++) { final col = List.generate(size, (r) => _board[r][c]); final m = _mergeLine(col.reversed.toList()).reversed.toList(); for (int r = 0; r < size; r++) _board[r][c] = m[r]; } }

  void _checkGameState() {
    if (_won && !_keepPlaying) return;
    for (int r = 0; r < size; r++)
      for (int c = 0; c < size; c++) {
        if (_board[r][c].value == 0) return;
        if (c + 1 < size && _board[r][c].value == _board[r][c + 1].value) return;
        if (r + 1 < size && _board[r][c].value == _board[r + 1][c].value) return;
      }
    _gameOver = true;
  }

  String _boardValues() => _board.map((row) => row.map((t) => t.value).join(',')).join('|');
}
