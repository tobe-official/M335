import 'package:flutter/material.dart';
import 'package:m_335_flutter/global_widgets/custom_navigation_bar.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'home_page_steps_stream.dart';
import 'package:m_335_flutter/controller/tracking_controller.dart';
import 'package:m_335_flutter/controller/route_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _stepsStream = HomePageStepsStream();
  bool _startWalking = true;

  @override
  void initState() {
    super.initState();
    _stepsStream.init();
    TrackingController().attachStepsStream(_stepsStream);
  }

  @override
  void dispose() {
    _stepsStream.dispose();
    super.dispose();
  }

  void _onButtonPressed(bool startWalking) async {
    if (startWalking) {
      await _stepsStream.start();
      final stepsAtStartingPoint = int.tryParse((_stepsStream.currentSteps ?? '0').toString()) ?? 0;

      await TrackingController().startTracking(stepsAtStartingPoint);
      await WakelockPlus.enable();
    } else {
      await _stepsStream.stop();
      final stepsAtEndingPoint = int.tryParse((_stepsStream.currentSteps ?? '0').toString()) ?? 0;
      await TrackingController().stopTracking(stepsAtEndingPoint);
      await RouteController().addRoute(points: TrackingController().routePoints, stopPoints: TrackingController().stopPoints, stepDiff: TrackingController().getLastStepsDifference(),start: TrackingController().getLastTrackingTimes()[0]!, end: TrackingController().getLastTrackingTimes()[1]!);
      await WakelockPlus.disable();
    }

    setState(() {
      _startWalking = !startWalking;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
      backgroundColor: const Color(0XFFD2D2D2),
      bottomNavigationBar: _startWalking ? CustomNavigationBar(initialIndexOfScreen: 2) : null,
    );
  }

  Widget _body() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_startWalking) _welcomeText() else _showSteps(),
          _walkingButton(),
          if (_startWalking) _showSteps(),
        ],
      ),
    );
  }

  Widget _streamBuilder(BuildContext context) {
    return StreamBuilder<String>(
      stream: _stepsStream.pedestrianStatusStream,
      initialData: _stepsStream.currentStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? '?';
        final icon =
            status == 'walking'
                ? Icons.directions_walk
                : status == 'stopped'
                ? Icons.accessibility_new
                : status == 'loading'
                ? Icons.downloading
                : Icons.error;
        return Column(
          children: [
            Icon(icon, size: 100),
            Text(
              status,
              style: TextStyle(
                fontSize: (status == 'walking' || status == 'stopped') ? 30 : 20,
                color: (status == 'walking' || status == 'stopped') ? null : Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _welcomeText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text('Hey there,', style: TextStyle(fontSize: 25)),
        Text('Ready for walking?', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        SizedBox(height: 30),
      ],
    );
  }

  Widget _walkingButton() {
    const Color brandBlue = Color(0xFF123456);
    const Color disabledGrey = Color(0xFF949494);

    final String label = _startWalking ? 'Start\nWalking' : 'Stop\nWalking';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: ElevatedButton(
            onPressed: () => _onButtonPressed(_startWalking),
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: _startWalking ? brandBlue : disabledGrey,
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 200),
              padding: EdgeInsets.zero,
              elevation: 3,
              shadowColor: Colors.black26,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (!_startWalking) _streamBuilder(context),
      ],
    );
  }

  Widget _showSteps() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Steps Taken', style: TextStyle(fontSize: 30)),
        StreamBuilder<String>(
          stream: _stepsStream.stepCountStream,
          initialData: _stepsStream.currentSteps,
          builder: (context, snapshot) => Text(snapshot.data ?? '?', style: const TextStyle(fontSize: 60)),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
