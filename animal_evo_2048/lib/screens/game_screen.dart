import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/game_model.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameModel(),
      child: const _GameView(),
    );
  }
}

class _GameView extends StatefulWidget {
  const _GameView();
  @override
  State<_GameView> createState() => _GameViewState();
}

class _GameViewState extends State<_GameView> {
  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final game = context.read<GameModel>();
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) game.move('left');
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) game.move('right');
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) game.move('up');
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) game.move('down');
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameModel>();
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF8EF),
        body: SafeArea(
          child: GestureDetector(
            onPanEnd: (d) {
              final v = d.velocity.pixelsPerSecond;
              if (v.dx.abs() > v.dy.abs()) {
                context.read<GameModel>().move(v.dx > 0 ? 'right' : 'left');
              } else {
                context.read<GameModel>().move(v.dy > 0 ? 'down' : 'up');
              }
            },
            child: Stack(
              children: [
                Column(children: [
                  _Header(game: game),
                  const SizedBox(height: 8),
                  _EvolutionBar(),
                  const SizedBox(height: 12),
                  const _BoardArea(),
                  const SizedBox(height: 12),
                  _HowToPlay(),
                ]),
                if (game.gameOver) _OverlayDialog(isGameOver: true, score: game.score),
                if (game.showWinDialog) _OverlayDialog(isGameOver: false, score: game.score),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final GameModel game;
  const _Header({required this.game});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('🐾 Animal', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF776E65))),
          Text('EVO 2048', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFF65E3B), letterSpacing: 1)),
        ]),
        const Spacer(),
        _ScoreBox(label: 'SKOR', value: game.score),
        const SizedBox(width: 8),
        _ScoreBox(label: 'EN İYİ', value: game.bestScore),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => context.read<GameModel>().newGame(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFF8F7A66), borderRadius: BorderRadius.circular(10)),
            child: const Column(children: [
              Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
              SizedBox(height: 2),
              Text('YENİ', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _ScoreBox extends StatelessWidget {
  final String label;
  final int value;
  const _ScoreBox({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFBBADA0), borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFFEEE4DA), fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value.toString(), style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

class _EvolutionBar extends StatelessWidget {
  static const _chain = [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192];
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFFBBADA0).withOpacity(0.4), borderRadius: BorderRadius.circular(12)),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        itemCount: _chain.length,
        itemBuilder: (_, i) {
          final data = kAnimals[_chain[i]]!;
          return Row(children: [
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(data.emoji, style: const TextStyle(fontSize: 20)),
              Text(data.name, style: const TextStyle(fontSize: 7, color: Color(0xFF776E65), fontWeight: FontWeight.w600)),
            ]),
            if (i < _chain.length - 1)
              const Padding(padding: EdgeInsets.symmetric(horizontal: 3),
                child: Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFFA09080))),
          ]);
        },
      ),
    );
  }
}

class _BoardArea extends StatelessWidget {
  const _BoardArea();
  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameModel>();
    final boardSize = MediaQuery.of(context).size.width - 32;
    return Container(
      width: boardSize, height: boardSize,
      decoration: BoxDecoration(color: const Color(0xFFBBADA0), borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8),
        itemCount: 16,
        itemBuilder: (_, index) => _TileWidget(tile: game.board[index ~/ 4][index % 4]),
      ),
    );
  }
}

class _TileWidget extends StatefulWidget {
  final Tile tile;
  const _TileWidget({required this.tile});
  @override
  State<_TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<_TileWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }
  @override
  void didUpdateWidget(_TileWidget old) {
    super.didUpdateWidget(old);
    if (widget.tile.isNew || widget.tile.isMerged) _controller.forward(from: 0);
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final val = widget.tile.value;
    final data = kAnimals[val];
    final bgColor = data?.bgColor ?? const Color(0xFFCDC1B4);
    return ScaleTransition(
      scale: (widget.tile.isNew || widget.tile.isMerged) ? _scaleAnim : const AlwaysStoppedAnimation(1.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10),
          boxShadow: val > 0 ? [BoxShadow(color: bgColor.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 3))] : null),
        child: val == 0 ? null : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(data!.emoji, style: TextStyle(fontSize: val >= 1024 ? 22 : 28)),
          const SizedBox(height: 2),
          Text(data.name, style: TextStyle(fontSize: 8, color: data.textColor, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 1),
        ]),
      ),
    );
  }
}

class _HowToPlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text('👆 Karoları kaydır • Aynı hayvanlar birleşir • 🐋 Mavi Balina\'ya ulaş!',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: Color(0xFF9C8E84), fontWeight: FontWeight.w500)),
    );
  }
}

class _OverlayDialog extends StatelessWidget {
  final bool isGameOver;
  final int score;
  const _OverlayDialog({required this.isGameOver, required this.score});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: const Color(0xFFFAF8EF), borderRadius: BorderRadius.circular(20)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(isGameOver ? '😢' : '🎉', style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 8),
            Text(isGameOver ? 'Oyun Bitti!' : 'Kazandın!',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF776E65))),
            const SizedBox(height: 6),
            Text(isGameOver ? 'Daha iyi yapabilirsin!' : '🐋 Mavi Balina\'ya ulaştın!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF9C8E84))),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFFBBADA0), borderRadius: BorderRadius.circular(10)),
              child: Column(children: [
                const Text('SKOR', style: TextStyle(fontSize: 12, color: Color(0xFFEEE4DA), fontWeight: FontWeight.bold)),
                Text(score.toString(), style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w900)),
              ]),
            ),
            const SizedBox(height: 20),
            if (!isGameOver) ...[
              _DialogButton(label: '▶  Devam Et', color: const Color(0xFF4CAF50), onTap: () => context.read<GameModel>().continueGame()),
              const SizedBox(height: 10),
            ],
            _DialogButton(label: '🔄  Yeni Oyun', color: const Color(0xFFF65E3B), onTap: () => context.read<GameModel>().newGame()),
          ]),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _DialogButton({required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
