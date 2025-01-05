import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(const PomodoroApp());
}

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timer del Pomodor 🍅',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const PomodoroPage(),
    );
  }
}

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  int workTime = 25 * 60; //25 min
  int shortBreak = 5 * 60; //5 min
  int longBreak = 15 * 60; //15 min

  int remainingSeconds = 25 * 60;
  int selectedDuration = 25 * 60;
  Timer? _timer;
  bool isRunning = false;
  bool isWorkMode = true;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const IOSInitializationSettings initializationSettingsDarwin =
        IOSInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  void _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'pomodoro_channel',
      'Pomodoro Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const IOSNotificationDetails darwinPlatformChannelSpecifics =
        IOSNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(0, title, body, platformChannelSpecifics);
  }

  String get timeFormatted {
    final int minutes = remainingSeconds ~/ 60;
    final int seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _toggleTimer() {
    if (isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    setState(() {
      isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          timer.cancel();
          isRunning = false;
          if (isWorkMode) {
            _showNotification('Basta studiare📚😜', 'E\' ora di fare una pausa!✨🤟');
          } else {
            _showNotification('Uff pausa finitafinita⏰🙀', 'Dai torna a studiare!📚🤟');
          }
          _switchModeAndStart();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      remainingSeconds = selectedDuration;
      isRunning = false;
    });
  }

  void _switchModeAndStart() {
    setState(() {
      if (isWorkMode) {
        selectedDuration = shortBreak;
        remainingSeconds = shortBreak;
      } else {
        selectedDuration = workTime;
        remainingSeconds = workTime;
      }
      isWorkMode = !isWorkMode;
    });
    _startTimer();
  }

  void _setCustomTimes(int newWorkTime, int newShortBreak, int newLongBreak) {
    setState(() {
      workTime = newWorkTime;
      shortBreak = newShortBreak;
      longBreak = newLongBreak;
      if (isWorkMode) {
        selectedDuration = workTime;
        remainingSeconds = workTime;
      } else {
        selectedDuration = shortBreak;
        remainingSeconds = shortBreak;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 26, 26, 29),
        title: const Text(
          'Timer del Pomodoro 🍅',
          
          style: TextStyle(
            color: Color.fromARGB(255, 224, 224, 224),
            fontSize: 22,
          ),

        ),
      ),
      body: Container(
        alignment: const Alignment(0.0, -0.3),
        color: const Color.fromARGB(255, 26, 26, 29),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isWorkMode ? 'Studio 🏫📚' : 'Pausetta 🦦✨',
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                _showSettingsDialog(context);
              },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                ),
              child: const Text(
                'Cambia tempi'
                ),
              
            ),
            const SizedBox(height: 60),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: 1 - remainingSeconds / selectedDuration,
                    strokeWidth: 10,
                    color: const Color.fromARGB(255, 233, 30, 99),
                    backgroundColor: const Color.fromARGB(255, 36, 36, 39),
                  ),
                ),
                Text(
                  timeFormatted,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 224, 224, 224),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _toggleTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRunning ? Colors.orange : const Color.fromARGB(255, 233, 30, 99),
                  ),
                  child: Text(
                    isRunning ? 'Pausa' : 'Start',
                    style: const TextStyle(color: Color.fromARGB(255, 224, 224, 224)),
                  ),
                ),
                const SizedBox(width: 40),
                ElevatedButton(
                  onPressed: _resetTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                  ),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final TextEditingController workController =
        TextEditingController(text: (workTime ~/ 60).toString());
    final TextEditingController shortBreakController =
        TextEditingController(text: (shortBreak ~/ 60).toString());
    final TextEditingController longBreakController =
        TextEditingController(text: (longBreak ~/ 60).toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            backgroundColor: const Color.fromARGB(255, 26, 26, 29),
          title: const Text(
            'Cambia tempi',
            style: TextStyle(color: Color.fromARGB(255, 179, 178, 178)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: workController,
                decoration: const InputDecoration(labelText: 'Studio 🏫📚 (min)'),
                keyboardType: TextInputType.number,
                style: const TextStyle(
                    color: Color.fromARGB(255, 179, 178, 178)
                ),
              ),
              TextField(
                controller: shortBreakController,
                decoration: const InputDecoration(labelText: 'Pausetta 🦦✨ (min)'),
                keyboardType: TextInputType.number,
                style: const TextStyle(
                    color: Color.fromARGB(255, 179, 178, 178)
                )
              ),
              TextField(
                controller: longBreakController,
                decoration: const InputDecoration(labelText: 'Pausetta lunga 🦦✨ (min)'),
                keyboardType: TextInputType.number,
                style: const TextStyle(
                    color: Color.fromARGB(255, 179, 178, 178)
                )
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancella '),
            ),
            TextButton(
              onPressed: () {
                final int newWorkTime = int.parse(workController.text) * 60;
                final int newShortBreak = int.parse(shortBreakController.text) * 60;
                final int newLongBreak = int.parse(longBreakController.text) * 60;
                _setCustomTimes(newWorkTime, newShortBreak, newLongBreak);
                Navigator.of(context).pop();
              },
              child: const Text('Salva ✏️'),
            ),
          ],
        );
      },
    );
  }
}


































































