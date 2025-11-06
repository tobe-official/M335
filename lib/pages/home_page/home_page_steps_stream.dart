import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePageStepsStream {
  final _stepCountController = StreamController<String>.broadcast();
  final _pedestrianStatusController = StreamController<String>.broadcast();

  Stream<String> get stepCountStream => _stepCountController.stream;
  Stream<String> get pedestrianStatusStream => _pedestrianStatusController.stream;

  StreamSubscription<StepCount>? _stepSubscription;
  StreamSubscription<PedestrianStatus>? _statusSubscription;

  Future<void> init() async {
    await _checkPermission();

    _statusSubscription = Pedometer.pedestrianStatusStream.listen(
      (event) => _pedestrianStatusController.add(event.status),
      onError: (_) => _pedestrianStatusController.add('Pedestrian Status not available'),
    );

    _stepSubscription = Pedometer.stepCountStream.listen(
      (event) => _stepCountController.add(event.steps.toString()),
      onError: (_) => _stepCountController.add('Step Count not available'),
    );
  }

  Future<void> _checkPermission() async {
    var granted = await Permission.activityRecognition.isGranted;
    if (!granted) {
      final result = await Permission.activityRecognition.request();
      granted = result == PermissionStatus.granted;
    }
    if (!granted) {
      _pedestrianStatusController.add('Permission denied');
      _stepCountController.add('Permission denied');
    }
  }

  void dispose() {
    _stepSubscription?.cancel();
    _statusSubscription?.cancel();
    _stepCountController.close();
    _pedestrianStatusController.close();
  }
}
