import 'dart:io';
import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePageStepsStream {
  late final StreamController<String> _stepCountController;
  late final StreamController<String> _pedestrianStatusController;

  Stream<String> get stepCountStream => _stepCountController.stream;
  Stream<String> get pedestrianStatusStream => _pedestrianStatusController.stream;

  StreamSubscription<StepCount>? _stepSub;
  StreamSubscription<PedestrianStatus>? _statusSub;
  bool _permChecked = false;

  String? _lastSteps;
  String? _lastStatus;

  bool _statusForward = false; // only forward when walk mode is activated

  String? get currentSteps => _lastSteps;
  String? get currentStatus => _lastStatus;

  HomePageStepsStream() {
    _stepCountController = StreamController<String>.broadcast();
    _pedestrianStatusController = StreamController<String>.broadcast();
  }

  Future<void> init() async {
    if (_permChecked) return;
    await _checkPermission();
    _permChecked = true;

    _stepSub ??= Pedometer.stepCountStream.listen(
      (e) {
        _lastSteps = e.steps.toString();
        _stepCountController.add(_lastSteps!);
      },
      onError: (_) {
        _lastSteps = 'Step Count not available';
        _stepCountController.add(_lastSteps!);
      },
    );

    _statusSub ??= Pedometer.pedestrianStatusStream.listen(
      (e) {
        _lastStatus = e.status;
        if (_statusForward) {
          _pedestrianStatusController.add(_lastStatus!);
        }
      },
      onError: (_) {
        _lastStatus = 'Pedestrian Status not available';
        if (_statusForward) {
          _pedestrianStatusController.add(_lastStatus!);
        }
      },
    );
  }

  // Starts listeners if they are not started yet
  Future<void> start() async {
    await init();
    _statusForward = true;
    _lastStatus = 'stopped';
    _pedestrianStatusController.add(_lastStatus!);
  }

  // Stops Listeners streams are still available from outside
  Future<void> stop() async {
    _statusForward = false;
    _lastStatus = 'stopped';
    _pedestrianStatusController.add(_lastStatus!);
  }

  Future<void> _checkPermission() async {
    if (Platform.isAndroid) {
      var granted = await Permission.activityRecognition.isGranted;
      if (!granted) {
        final result = await Permission.activityRecognition.request();
        granted = result == PermissionStatus.granted;
      }
      if (!granted) {
        _lastStatus = 'Permission denied';
        _lastSteps = 'Permission denied';
        _pedestrianStatusController.add(_lastStatus!);
        _stepCountController.add(_lastSteps!);
      }
    }
  }

  Future<void> dispose() async {
    await _stepSub?.cancel();
    await _statusSub?.cancel();
    await _stepCountController.close();
    await _pedestrianStatusController.close();
  }
}
