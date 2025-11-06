import 'package:flutter/material.dart';

import 'home_page_steps_stream.dart';

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
  }

  @override
  void dispose() {
    _stepsStream.dispose();
    super.dispose();
  }

  void _onButtonPressed(bool startWalking) {
    setState(() {
      _startWalking = !startWalking;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _body());
  }

  Widget _body() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [_welcomeText(), _stepsOverview(), _streamBuilder()],
      ),
    );
  }

  Widget _streamBuilder() {
    return StreamBuilder<String>(
      stream: _stepsStream.pedestrianStatusStream,
      builder: (context, snapshot) {
        final status = snapshot.data ?? '?';
        final icon =
            status == 'walking'
                ? Icons.directions_walk
                : status == 'stopped'
                ? Icons.accessibility_new
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
      children: [
        const Text('Hey there,', style: TextStyle(fontSize: 25)),
        const Text('Ready for walking?', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _stepsOverview() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => _onButtonPressed(_startWalking),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(_startWalking ? Color(0X00123456) : Color(0x00949494)),
          ),
          child: const Text('Start Walking', style: TextStyle(color: Colors.white)),
        ),
        const Text('Steps Taken', style: TextStyle(fontSize: 30)),
        StreamBuilder<String>(
          stream: _stepsStream.stepCountStream,
          builder: (context, snapshot) => Text(snapshot.data ?? '?', style: const TextStyle(fontSize: 60)),
        ),
        const SizedBox(height: 16.0),
        const Text('Pedestrian Status', style: TextStyle(fontSize: 30)),
      ],
    );
  }
}
