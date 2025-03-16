import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';

class RecentActivityItem extends StatelessWidget {
  final String type;
  final String title;
  final DateTime time;

  const RecentActivityItem({
    Key? key,
    required this.type,
    required this.title,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildActivityIcon(),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        _getFormattedTime(),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildActivityIcon() {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case 'attendance':
        iconData = Icons.access_time;
        iconColor = AppTheme.primaryColor;
        break;
      case 'leave':
        iconData = Icons.event_note;
        iconColor = AppTheme.accentColor;
        break;
      case 'employee':
        iconData = Icons.person;
        iconColor = AppTheme.secondaryColor;
        break;
      case 'department':
        iconData = Icons.business;
        iconColor = AppTheme.infoColor;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = AppTheme.textSecondaryColor;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  String _getFormattedTime() {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return DateFormat('MMM d, yyyy').format(time);
    }
  }
}
