import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:rive/rive.dart';

/// An example showing how to drive two boolean state machine inputs.
class TimerDisplay extends StatefulWidget {
  const TimerDisplay({Key? key}) : super(key: key);

  @override
  _TimerDisplay createState() => _TimerDisplay();
}

class _TimerDisplay extends State<TimerDisplay> {
  bool isMainTaskTimer = true;

  int mainTime = 6000;
  int breakTime = 3000;

  late SMIInput<double> _timeInput;
  Timer? timerTracker;
  bool hasWorkStarted = false;

  void _startTimer() {
    Timer.periodic(const Duration(milliseconds: 5), (timer) {
      timerTracker = timer;
      if (isMainTaskTimer) {
        setState(() => mainTime -= 5);
        _timeInput.value += 5;
        if (mainTime == 0) {
          isMainTaskTimer = false;
          timer.cancel();
        }
      } else {
        setState(() => breakTime -= 5);
        _timeInput.value += 5;
        if (breakTime == 0) {
          isMainTaskTimer = true;
          timer.cancel();
        }
      }
    });
  }

  void _onRiveStateChange(String smName, String toState) {
    if (toState == "Work Start") {
      if (hasWorkStarted == false) {
        hasWorkStarted = true;
      } else {
        // START THE TIMER
        _startTimer();
      }
    } else if (toState == "Work Finish" || toState == "Restart") {
      timerTracker!.cancel();
      mainTime = 6000;
      breakTime = 3000;
      _timeInput.value = 0;
    } else if (toState == "Break Start") {
      _startTimer();
    } else if (toState == "Stop") {
      if (timerTracker != null) {
        timerTracker!.cancel();
      }
    } else if (toState == "Play Dummy") {
      _startTimer();
    }
  }

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
        artboard, "State Machine 3",
        onStateChange: _onRiveStateChange);
    artboard.addController(controller!);
    _timeInput = controller.findInput<double>("time") as SMINumber;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RiveAnimation.asset("assets/pomodoro.riv", onInit: _onRiveInit),
        Positioned.fill(
          top: 50,
          child: Align(
            alignment: Alignment.topCenter,
            child: Text(
              isMainTaskTimer ? 'Work' : 'Break',
              style: const TextStyle(
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
        Positioned.fill(
          bottom: 200,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              "${isMainTaskTimer ? mainTime : breakTime}",
              style: const TextStyle(
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
