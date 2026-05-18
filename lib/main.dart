import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MemoryMatchApp());
}

class MemoryMatchApp extends StatelessWidget {
  const MemoryMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Matching Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade700,
              Colors.deepPurple.shade200,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.extension,
                  size: 90,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Memory Matching Game',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Flip the cards, remember the shapes, and match all pairs to win!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MemoryGamePage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Game'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepPurple,
                    elevation: 6,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MemoryCard {
  final String imagePath;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.imagePath,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class MemoryGamePage extends StatefulWidget {
  const MemoryGamePage({super.key});

  @override
  State<MemoryGamePage> createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> {
  late List<MemoryCard> cards;
  int? firstSelectedIndex;
  int moves = 0;
  int matchedPairs = 0;
  bool isChecking = false;
  Timer? gameTimer;
  int secondsElapsed = 0;
  int? bestMoves;
  int? bestTime;

  final List<MemoryCard> originalCards = [
    MemoryCard(imagePath: 'assets/images/red_circle.png'),
    MemoryCard(imagePath: 'assets/images/blue_square.png'),
    MemoryCard(imagePath: 'assets/images/green_triangle.png'),
    MemoryCard(imagePath: 'assets/images/orange_diamond.png'),
    MemoryCard(imagePath: 'assets/images/purple_star.png'),
    MemoryCard(imagePath: 'assets/images/pink_heart.png'),
  ];

  @override
  void initState() {
    super.initState();
    startNewGame();
  }

  void startTimer() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        secondsElapsed++;
      });
    });
  }

  String formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  void startNewGame() {
    cards = [];

    for (var card in originalCards) {
      cards.add(MemoryCard(imagePath: card.imagePath));
      cards.add(MemoryCard(imagePath: card.imagePath));
    }

    cards.shuffle();

    setState(() {
      firstSelectedIndex = null;
      moves = 0;
      matchedPairs = 0;
      isChecking = false;
      secondsElapsed = 0;
    });

    startTimer();
  }

  void onCardTap(int index) {
    if (isChecking || cards[index].isFlipped || cards[index].isMatched) {
      return;
    }

    setState(() {
      cards[index].isFlipped = true;
    });

    if (firstSelectedIndex == null) {
      firstSelectedIndex = index;
    } else {
      moves++;
      int secondSelectedIndex = index;
      checkMatch(firstSelectedIndex!, secondSelectedIndex);
    }
  }

  void checkMatch(int firstIndex, int secondIndex) {
    isChecking = true;

    if (cards[firstIndex].imagePath == cards[secondIndex].imagePath) {
      setState(() {
        cards[firstIndex].isMatched = true;
        cards[secondIndex].isMatched = true;
        matchedPairs++;
        firstSelectedIndex = null;
        isChecking = false;
      });

      if (matchedPairs == originalCards.length) {
        gameTimer?.cancel();

        if (bestMoves == null || moves < bestMoves!) {
          bestMoves = moves;
        }

        if (bestTime == null || secondsElapsed < bestTime!) {
          bestTime = secondsElapsed;
        }

        showWinDialog();
      }
    } else {
      Timer(const Duration(seconds: 1), () {
        setState(() {
          cards[firstIndex].isFlipped = false;
          cards[secondIndex].isFlipped = false;
          firstSelectedIndex = null;
          isChecking = false;
        });
      });
    }
  }

  void showWinDialog() {
    Future.delayed(const Duration(milliseconds: 300), () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Congratulations!'),
            content: Text(
              'You completed the game in $moves moves.\nTime taken: ${formatTime(secondsElapsed)}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  startNewGame();
                },
                child: const Text('Play Again'),
              ),
            ],
          );
        },
      );
    });
  }

  Widget buildCard(int index) {
    final card = cards[index];

    return GestureDetector(
      onTap: () => onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: card.isFlipped || card.isMatched
              ? Colors.white
              : Colors.deepPurple.shade300,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(3, 5),
            ),
          ],
        ),
        child: Center(
          child: card.isFlipped || card.isMatched
              ? Padding(
            padding: const EdgeInsets.all(12),
            child: Image.asset(
              card.imagePath,
              fit: BoxFit.contain,
            ),
          )
              : const Text(
            '?',
            style: TextStyle(
              fontSize: 48,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalPairs = originalCards.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Matching Game'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade50,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Moves: $moves',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Pairs: $matchedPairs / $totalPairs',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Time: ${formatTime(secondsElapsed)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      bestMoves == null
                          ? 'Best Score: Not recorded yet'
                          : 'Best Score: $bestMoves moves / ${formatTime(bestTime!)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: cards.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  return buildCard(index);
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: startNewGame,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Restart'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}