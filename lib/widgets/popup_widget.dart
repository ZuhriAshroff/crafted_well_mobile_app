// lib/widgets/status_popup.dart
import 'package:flutter/material.dart';

class StatusPopup extends StatelessWidget {
  final String message;
  final bool isSuccess;
  final VoidCallback? onClose;

  const StatusPopup({
    Key? key,
    required this.message,
    this.isSuccess = true,
    this.onClose,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    required String message,
    bool isSuccess = true,
    VoidCallback? onClose,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: StatusPopup(
          message: message,
          isSuccess: isSuccess,
          onClose: onClose,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSuccess
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),

          // Message
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 24),

          // Close Button
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onClose?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isSuccess ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
