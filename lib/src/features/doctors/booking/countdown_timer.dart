import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime expireAt;
  final String doctorId;

  const CountdownTimer({
    super.key,
    required this.expireAt,
    required this.doctorId,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.expireAt.difference(DateTime.now());

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final diff = widget.expireAt.difference(now);

      if (diff.isNegative) {
        timer.cancel();
        setState(() {
          _remaining = Duration.zero;
        });
        final currentUri = GoRouterState.of(context).uri.toString();
        if (currentUri.startsWith('/doctors/check-out/')) {
          final controller = ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).primaryColorLight,
              content: Text(tr('reservationExpired')),
              duration: const Duration(seconds: 5),
            ),
          );

          controller.closed.then((_) {
            if (mounted) {
              final encodeddoctorId = base64.encode(utf8.encode(widget.doctorId.toString()));
              context.push(Uri(path: '/doctors/booking/$encodeddoctorId').toString());
            }
          });
        }
      } else {
        setState(() {
          _remaining = diff;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Text(
        _remaining.inSeconds > 0 ? context.tr('expiresIn', args: ['$minutes:$seconds']) : context.tr('expired'),
        style: TextStyle(
          color: Theme.of(context).primaryColorLight,
        ),
      ),
    );
  }
}
