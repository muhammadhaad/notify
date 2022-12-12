// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:notify/model.dart';
// import 'package:http/http.dart' as http;

// FlutterLocalNotificationsPlugin localNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   AndroidInitializationSettings androidSettings =
//       const AndroidInitializationSettings("@mipmap/ic_launcher");

//   InitializationSettings initializationSettings = InitializationSettings(
//     android: androidSettings,

//   );

//   bool? initialized =
//       await localNotificationsPlugin.initialize(initializationSettings);

//   log("Notification: $initialized");
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Notification Alert',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({
//     super.key,
//   });

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   StreamController<DataModel> _streamController = StreamController();

//   @override
//   void dispose() {
//     super.dispose();
//     _streamController.close();
//   }

//   @override
//   void initState() {
//     super.initState();
//     Timer.periodic(const Duration(seconds: 3), ((timer) {
//       getCryptoPrice();
//     }));
//   }

// Future<void> getCryptoPrice() async {
// var headers = {'X-CoinAPI-Key': '17272955-6008-4446-ADE0-762A686E5D88'};
// var response = await http.get(
//     Uri.parse('https://rest.coinapi.io/v1/exchangerate/BTC/PKR'),
//     headers: headers);

// final dataBody = json.decode(response.body);
// final dataBody = {
//   "time": "2017-08-09T14:31:18.3150000Z",
//   "asset_id_base": "BTC",
//   "asset_id_quote": "USD",
//   "rate": 3260.3514321215056208129867667
// };
// DataModel dataModel = DataModel.fromJson(dataBody);
// _streamController.sink.add(dataModel);
// }

//   showNotification() async {
//     AndroidNotificationDetails androidNotificationDetails =
//         const AndroidNotificationDetails(
//       'Alert-Id',
//       'Weater Alert',
//       channelDescription:
//         'This channel is used for important notifications.',
//       priority: Priority.max,
//       importance: Importance.max,
//     );
//     NotificationDetails notificationDetails =
//         NotificationDetails(android: androidNotificationDetails);
//     await localNotificationsPlugin.show(
//         0, "Weather Aleart", 'hi', notificationDetails);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//           child: StreamBuilder<DataModel>(
//         stream: _streamController.stream,
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             // showNotification();
//             return buildCoinWidget(snapshot.data!);
//           } else if (snapshot.hasError) {
//             return Text(snapshot.error.toString());
//           }
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         },
//       )),
//     );
//   }

//   Widget buildCoinWidget(DataModel dataModel) {
//     return Center(
//       child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//         Text(
//           dataModel.cryptoCurrency,
//           style: const TextStyle(fontSize: 24),
//         ),
//         Text('Rs ${dataModel.rate}'),
//         Text('Time updated: ${dataModel.time}'),
//       ]),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,
      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,
      // you have to enable background fetch capability on xcode project
      // onBackground: onIosBackground,
    ),
  );

  service.startService();
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

// @pragma('vm:entry-point')
// Future<bool> onIosBackground(ServiceInstance service) async {
//   WidgetsFlutterBinding.ensureInitialized();
//   DartPluginRegistrant.ensureInitialized();

//   SharedPreferences preferences = await SharedPreferences.getInstance();
//   await preferences.reload();
//   final log = preferences.getStringList('log') ?? <String>[];
//   log.add(DateTime.now().toIso8601String());
//   await preferences.setStringList('log', log);

//   return true;
// }

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // bring to foreground
  Timer.periodic(const Duration(seconds: 3), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        /// OPTIONAL for use custom notification
        /// the notification id must be equals with AndroidConfiguration when you call configure() method.
        var headers = {'X-CoinAPI-Key': '17272955-6008-4446-ADE0-762A686E5D88'};
        var response = await http.get(
            Uri.parse('https://rest.coinapi.io/v1/exchangerate/BTC/PKR'),
            headers: headers);

        final dataBody = json.decode(response.body);
        flutterLocalNotificationsPlugin.show(
          888,
          'Weather Alert',
          'BTC Rate: ${dataBody['rate']} :: Time: ${dataBody['time']}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );

        // if you don't using custom notification, uncomment this
        // service.setForegroundNotificationInfo(
        //   title: "My App Service",
        //   content: "Updated at ${DateTime.now()}",
        // );
      }
    }

    /// you can see this log in logcat
    print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

    // test using external plugin
    final deviceInfo = DeviceInfoPlugin();
    String? device;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    }
    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device,
      },
    );
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String text = "Stop Service";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Service App'),
        ),
        body: Column(
          children: [
            StreamBuilder<Map<String, dynamic>?>(
              stream: FlutterBackgroundService().on('update'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = snapshot.data!;
                String? device = data["device"];
                DateTime? date = DateTime.tryParse(data["current_date"]);
                return Column(
                  children: [
                    Text(device ?? 'Unknown'),
                    Text(date.toString()),
                  ],
                );
              },
            ),
            ElevatedButton(
              child: const Text("Foreground Mode"),
              onPressed: () {
                FlutterBackgroundService().invoke("setAsForeground");
              },
            ),
            ElevatedButton(
              child: const Text("Background Mode"),
              onPressed: () {
                FlutterBackgroundService().invoke("setAsBackground");
              },
            ),
            ElevatedButton(
              child: Text(text),
              onPressed: () async {
                final service = FlutterBackgroundService();
                var isRunning = await service.isRunning();
                if (isRunning) {
                  service.invoke("stopService");
                } else {
                  service.startService();
                }

                if (!isRunning) {
                  text = 'Stop Service';
                } else {
                  text = 'Start Service';
                }
                setState(() {});
              },
            ),
            const Expanded(
              child: LogView(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.play_arrow),
        ),
      ),
    );
  }
}

class LogView extends StatefulWidget {
  const LogView({Key? key}) : super(key: key);

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late final Timer timer;
  List<String> logs = [];

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      await sp.reload();
      logs = sp.getStringList('log') ?? [];
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs.elementAt(index);
        return Text(log);
      },
    );
  }
}
