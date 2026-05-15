
import 'package:supabase_flutter/supabase_flutter.dart';

class ApplicationService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> createApplication(Map<String, dynamic> data) async {
    await supabase.from('applications').insert(data);
  }

  Future<List<Map<String, dynamic>>> getApplications() async {
    final response = await supabase
        .from('applications')
        .select('*') // Fetch all columns safely
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> approveApplication(String id) async {
    if (id.isEmpty) {
      throw Exception('Application ID is missing');
    }

    await supabase
        .from('applications')
        .update({'status': 'Approved'})
        .eq('id', id);

    print('Status updated: Approved');
  }

  Future<void> rejectApplication(String id) async {
    if (id.isEmpty) {
      throw Exception('Application ID is missing');
    }

    await supabase
        .from('applications')
        .update({'status': 'Rejected'})
        .eq('id', id);

    print('Status updated: Rejected');
  }

  Future<void> updateApplication(String id, Map<String, dynamic> data) async {
    if (id.isEmpty) {
      throw Exception('Application ID is missing');
    }

    await supabase.from('applications').update(data).eq('id', id);
  }

  Future<void> deleteApplication(String id) async {
    if (id.isEmpty) {
      throw Exception('Application ID is missing');
    }

    await supabase.from('applications').delete().eq('id', id);
  }
}
