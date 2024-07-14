import 'package:flutter/material.dart';

class Info {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      showSnackbarMessage(BuildContext context,
          {required String message,
          String? label,
          String actionLabel = "Close",
          void Function()? onCloseTapped,
          Duration duration = const Duration(seconds: 3)}) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 2,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label != null)
                    Text(
                      label,
                    ),
                  Text(
                    message,
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(),
              onPressed: () {
                if (onCloseTapped != null) {
                  onCloseTapped();
                } else {
                  ScaffoldMessenger.of(context).clearSnackBars();
                }
              },
              child: Text(
                actionLabel,
              ),
            )
          ],
        ),
        duration: duration,
      ),
    );
  }
}
