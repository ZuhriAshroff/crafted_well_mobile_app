// lib/utils/navigation_state.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NavigationState {
  static bool hasCompletedSurvey = false;

  static void resetState() {
    hasCompletedSurvey = false;
    print('🔄 NavigationState: Reset - Survey completion cleared');
  }

  static void markSurveyComplete() {
    hasCompletedSurvey = true;
    print('✅ NavigationState: Survey marked as complete');
  }

  static void debugState() {
    print('🔍 NavigationState Debug:');
    print('   - Survey Completed: $hasCompletedSurvey');
  }

  static String getStatusMessage() {
    return hasCompletedSurvey ? '✅ Survey Complete' : '❌ Survey Pending';
  }

  // SURVEY MIDDLEWARE FUNCTIONALITY
  // ================================

  // Check if device is online
  static Future<bool> isOnline() async {
    try {
      final connectivity = Connectivity();
      final result = await connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      print('❌ Connectivity check error: $e');
      return false;
    }
  }

  // Check connectivity and show appropriate feedback for survey submission
  static Future<bool> checkConnectivityForSurvey(BuildContext context) async {
    final isConnected = await isOnline();

    if (!isConnected) {
      await _showOfflineDialog(context);
      return false;
    }

    return true;
  }

  // Show connectivity required dialog
  static Future<void> _showOfflineDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.cloud_off, color: Colors.orange),
              SizedBox(width: 8),
              Text('Internet Required'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Survey submission requires an internet connection to:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 12),
              Text(
                '• Save your responses to create personalized products\n'
                '• Generate custom recommendations\n'
                '• Sync with your account',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 16, color: Colors.blue.shade700),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You can browse demo products offline without completing the survey.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Try Again'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show loading dialog during survey submission
  static void showSubmissionDialog(BuildContext context) {
    if (!_isContextValid(context)) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Expanded(
                child: Text('Submitting your survey responses...'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Check connectivity and show appropriate feedback with loading
  static Future<bool> validateSurveySubmission(BuildContext context) async {
    if (!_isContextValid(context)) return false;

    // Show loading
    showSubmissionDialog(context);

    // Check connectivity
    final isConnected = await isOnline();

    // Hide loading - safety check before popping
    if (_isContextValid(context)) {
      Navigator.of(context).pop();
    }

    if (!isConnected) {
      if (_isContextValid(context)) {
        await _showSubmissionFailedDialog(context);
      }
      return false;
    }

    return true;
  }

  // Helper method to check if context is still valid
  static bool _isContextValid(BuildContext context) {
    try {
      return context.mounted;
    } catch (e) {
      return false;
    }
  }

  // Show submission failed dialog
  static Future<void> _showSubmissionFailedDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Submission Failed'),
            ],
          ),
          content: Text(
            'Your survey could not be submitted due to connectivity issues. Please check your internet connection and try again.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Retry'),
            ),
          ],
        );
      },
    );
  }
}
