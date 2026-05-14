import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final supabase = Supabase.instance.client;

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    String type = 'info',
  }) async {
    await supabase.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
    });
  }

  Future<int> getUnreadCount(String userId) async {
    final response = await supabase
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false);

    return response.length;
  }
}