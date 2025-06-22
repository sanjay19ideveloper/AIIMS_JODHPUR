import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'dart:io';

void main() {

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delhi Alarm Clock',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AlarmHomePage(),
    );
  }
}


Future<void> requestExactAlarmPermission() async {
  if (Platform.isAndroid) {
    const platform = MethodChannel('exact_alarm_permission');
    try {
      final bool isGranted = await platform.invokeMethod('checkExactAlarmPermission');
      if (!isGranted) {
        const intent = AndroidIntent(
          action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
        );
        await intent.launch();
      }
    } on PlatformException catch (e) {
      print("Error checking/requesting exact alarm permission: $e");
    }
  }
}

class AlarmHomePage extends StatefulWidget {
  const AlarmHomePage({super.key});

  @override
  State<AlarmHomePage> createState() => _AlarmHomePageState();
}

class _AlarmHomePageState extends State<AlarmHomePage> {
  List<Alarm> alarms = [];
  DateTime _currentTime = DateTime.now();
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
    _loadAlarms();
    
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();
    final delhi = tz.getLocation('Asia/Kolkata');
    tz.setLocalLocation(delhi);

    // Create notification channel with default sound
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'delhi_alarm_channel_id',
      'Delhi Alarm Channel',
      description: 'Channel for Delhi alarm notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlarmRingScreen(
              alarmId: response.payload ?? '',
              audioPlayer: _audioPlayer,
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final String? alarmsJson = prefs.getString('alarms');
    if (alarmsJson != null) {
      final List<dynamic> decoded = jsonDecode(alarmsJson);
      setState(() {
        alarms = decoded.map((item) => Alarm.fromJson(item)).toList();
      });
      for (var alarm in alarms) {
        if (alarm.isEnabled) {
          _scheduleAlarm(alarm);
        }
      }
    }
  }

  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final String alarmsJson = jsonEncode(alarms.map((a) => a.toJson()).toList());
    await prefs.setString('alarms', alarmsJson);
  }

  Future<void> _scheduleAlarm(Alarm alarm) async {
     await requestExactAlarmPermission();
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      alarm.time.hour,
      alarm.time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'delhi_alarm_channel_id',
      'Delhi Alarm Channel',
      channelDescription: 'Channel for Delhi alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    int notificationId = alarm.notificationId;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      'Alarm',
      'Time to wake up!',
      scheduledDate,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: alarm.id,
    );
  }

  void _addAlarm() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      final newAlarm = Alarm(
        time: selectedTime,
        isEnabled: true,
      );

      setState(() {
        alarms.add(newAlarm);
      });

      await _scheduleAlarm(newAlarm);
      await _saveAlarms();
    }
  }

  Future<void> _toggleAlarm(int index, bool value) async {
    setState(() {
      alarms[index].isEnabled = value;
    });

    if (value) {
      await _scheduleAlarm(alarms[index]);
    } else {
      await flutterLocalNotificationsPlugin.cancel(alarms[index].notificationId);
    }
    await _saveAlarms();
  }

  Future<void> _deleteAlarm(int index) async {
    await flutterLocalNotificationsPlugin.cancel(alarms[index].notificationId);
    setState(() {
      alarms.removeAt(index);
    });
    await _saveAlarms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delhi Alarm Clock'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  DateFormat('HH:mm:ss').format(_currentTime),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                Text(
                  DateFormat('EEE, MMM d').format(_currentTime),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'IST (Asia/Kolkata)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                return AlarmTile(
                  alarm: alarms[index],
                  onToggle: (bool value) => _toggleAlarm(index, value),
                  onDelete: () => _deleteAlarm(index),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlarm,
        child: const Icon(Icons.add_alarm),
      ),
    );
  }
}

class Alarm {
  TimeOfDay time;
  bool isEnabled;
  String id;

  Alarm({
    required this.time,
    required this.isEnabled,
    String? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  int get notificationId => id.hashCode & 0x7FFFFFFF; // 32-bit positive integer

  Map<String, dynamic> toJson() => {
        'hour': time.hour,
        'minute': time.minute,
        'isEnabled': isEnabled,
        'id': id,
      };

  factory Alarm.fromJson(Map<String, dynamic> json) => Alarm(
        time: TimeOfDay(hour: json['hour'], minute: json['minute']),
        isEnabled: json['isEnabled'],
        id: json['id'],
      );
}

class AlarmTile extends StatelessWidget {
  final Alarm alarm;
  final Function(bool) onToggle;
  final VoidCallback onDelete;

  const AlarmTile({
    required this.alarm,
    required this.onToggle,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.alarm),
      title: Text(
        '${alarm.time.hour.toString().padLeft(2, '0')}:${alarm.time.minute.toString().padLeft(2, '0')}',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: alarm.isEnabled,
            onChanged: onToggle,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class AlarmRingScreen extends StatefulWidget {
  final String alarmId;
  final AudioPlayer audioPlayer;

  const AlarmRingScreen({
    required this.alarmId,
    required this.audioPlayer,
    Key? key,
  }) : super(key: key);

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  @override
  void initState() {
    super.initState();
    _playAlarm();
  }

  Future<void> _playAlarm() async {
    try {
      await widget.audioPlayer.play(AssetSource('assets/alarm_sound.mp3'));
    } catch (e) {
      debugPrint('Error playing alarm sound from assets: $e');
      try {
        // Fallback to default system sound
        await widget.audioPlayer.play(DeviceFileSource('/system/media/audio/alarms/Alarm_Beep_03.ogg'));
      } catch (e) {
        debugPrint('Error playing fallback alarm sound: $e');
      }
    }
    await widget.audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void _stopAlarm() {
    widget.audioPlayer.stop();
    Navigator.of(context).pop();
  }

  void _snoozeAlarm() async {
    widget.audioPlayer.stop();
    
    final now = tz.TZDateTime.now(tz.local);
    final snoozeTime = now.add(const Duration(minutes: 5));
    
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'delhi_alarm_channel_id',
      'Delhi Alarm Channel',
      channelDescription: 'Channel for Delhi alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    int snoozeId = '${widget.alarmId}_snooze'.hashCode & 0x7FFFFFFF;

    await FlutterLocalNotificationsPlugin().zonedSchedule(
      snoozeId,
      'Snoozed Alarm',
      'Time to wake up!',
      snoozeTime,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    widget.audioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.alarm_on,
                size: 100,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              const Text(
                'Wake Up!',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _snoozeAlarm,
                    child: const Text('Snooze (5 min)'),
                  ),
                  ElevatedButton(
                    onPressed: _stopAlarm,
                    child: const Text('Dismiss'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}