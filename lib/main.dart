import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(QuizApp());
}

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Quiz App',
      theme: ThemeData(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue, accentColor: Colors.blueAccent),
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          headline6: TextStyle(
            color: Colors.black,
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
          button: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Navigate to the quiz selection screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => QuizSelectionScreen()),
                );
              },
              child: Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Selection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Navigate to the quiz screen with a random quiz
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => QuizScreen(quiz: _getRandomQuiz())),
                );
              },
              child: Text('Start Random Quiz'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to the quiz screen with a specific quiz
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          QuizScreen(quiz: _getSpecificQuiz())),
                );
              },
              child: Text('Start Specific Quiz'),
            ),
          ],
        ),
      ),
    );
  }

  // Generate a random quiz
  Quiz _getRandomQuiz() {
    // Replace this with your actual logic to get a random quiz
    // For now, we'll use a hardcoded quiz
    return Quiz(
      title: 'Random Quiz',
      questions: [
        {
          'question': 'What is 2 + 2?',
          'answers': ['4', '3', '5', '6'],
          'correctIndex': 0,
        },
        {
          'question': 'What is the capital of Italy?',
          'answers': ['Paris', 'London', 'Rome', 'Berlin'],
          'correctIndex': 2,
        },
        {
          'question': 'Who wrote "To Kill a Mockingbird"?',
          'answers': [
            'J.K. Rowling',
            'Harper Lee',
            'Stephen King',
            'Ernest Hemingway'
          ],
          'correctIndex': 1,
        },
      ],
    );
  }

  // Get a specific quiz (replace with actual logic)
  Quiz _getSpecificQuiz() {
    // Replace this with your actual logic to get a specific quiz
    // For now, we'll use the same hardcoded quiz as the random one
    return _getRandomQuiz();
  }
}

class QuizScreen extends StatefulWidget {
  final Quiz quiz;

  QuizScreen({required this.quiz});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _score = 0;
  int _timeLeft = 15;
  bool _timerRunning = false;

  late AnimationController _cardAnimationController;
  late Animation<double> _cardAnimation;

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();

    _cardAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _cardAnimationController.forward(); // Start animation immediately
  }

  @override
  void dispose() {
    _timer.cancel();
    _cardAnimationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer.cancel();
          _nextQuestion();
        }
      });
    });
    _timerRunning = true;
  }

  void _answerQuestion(int selectedIndex) {
    if (selectedIndex == widget.quiz.questions[_currentIndex]['correctIndex']) {
      setState(() {
        _score++;
      });
    }
    _nextQuestion();
  }

  void _nextQuestion() {
    setState(() {
      _currentIndex++;
      if (_currentIndex >= widget.quiz.questions.length) {
        _timer.cancel();
        _timerRunning = false;
        _showResultDialog();
      } else {
        _timeLeft = 15;
        _cardAnimationController.forward(from: 0.0);
      }
    });
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Quiz Finished!', style: TextStyle(color: Colors.black)),
          content: Text(
              'Your score is $_score out of ${widget.quiz.questions.length}',
              style: TextStyle(color: Colors.black)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                  _score = 0;
                });
                _startTimer();
                Navigator.of(context).pop();
              },
              child: Text('Restart Quiz', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade200, Colors.blue.shade800],
          ),
        ),
        child: _currentIndex < widget.quiz.questions.length
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _cardAnimationController,
                    builder: (BuildContext context, Widget? child) {
                      return Transform.scale(
                        scale: _cardAnimation.value,
                        child: Card(
                          elevation: 5,
                          margin: EdgeInsets.all(20),
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Text(
                                  widget.quiz.questions[_currentIndex]
                                      ['question'],
                                  style: TextStyle(
                                      fontSize: 22, color: Colors.black),
                                ),
                                SizedBox(height: 20),
                                ...((widget.quiz.questions[_currentIndex]
                                        ['answers'] as List<String>))
                                    .map((answer) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: ElevatedButton(
                                      onPressed: () => _answerQuestion(
                                          (widget.quiz.questions[_currentIndex]
                                                  ['answers'] as List<String>)
                                              .indexOf(answer)),
                                      child: Text(answer),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Time Left: $_timeLeft seconds',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ],
              )
            : Center(
                child: Text(
                  'Quiz Finished!',
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
              ),
      ),
    );
  }
}

class Quiz {
  final String title;
  final List<Map<String, dynamic>> questions;

  Quiz({required this.title, required this.questions});
}
