import 'package:flutter/material.dart';

class AppDialogsUtils {
  static Future<void> showLoadingDialog({
    required BuildContext context,
    required String loadingMessage,
    bool dismissible = true,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 12),
              Expanded(child: Text(loadingMessage)),
            ],
          ),
        );
      },
    );
  }

  static Future<void> showActionDialog({
    required BuildContext context,
    bool dismissible = true,
    String? title,
    String? content,
    String? posActionTitle,
    VoidCallback? posAction,
    String? negActionTitle,
    VoidCallback? negAction,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) {
        return AlertDialog(
          title: title != null ? Text(title) : null,
          content: content != null ? Text(content) : null,
          actions: [
            if (negActionTitle != null)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  negAction?.call();
                },
                child: Text(negActionTitle),
              ),
            if (posActionTitle != null)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  posAction?.call();
                },
                child: Text(posActionTitle),
              ),
          ],
        );
      },
    );
  }
}
