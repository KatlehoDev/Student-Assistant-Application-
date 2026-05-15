import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApplicationViewModel extends ChangeNotifier {

  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> applications = [];

  bool isLoading = false;

  // =====================================================
  // ADMIN: FETCH ALL APPLICATIONS + MODULES
  // =====================================================
  Future<void> fetchApplications() async {

    try {

      isLoading = true;
      notifyListeners();

      final response = await supabase
          .from('applications')
          .select('*, application_modules(*)')
          .order('created_at', ascending: false);

      debugPrint(
          "FULL ADMIN RESPONSE: ${response.toString()}");

      applications =
          List<Map<String, dynamic>>.from(response);

    } catch (e) {

      debugPrint("fetchApplications ERROR: $e");

      applications = [];

    } finally {

      isLoading = false;
      notifyListeners();
    }
  }

  // =====================================================
  // STUDENT: FETCH ONLY OWN APPLICATIONS
  // =====================================================
  Future<void> fetchStudentApplications() async {

    try {

      isLoading = true;
      notifyListeners();

      final user = supabase.auth.currentUser;

      if (user == null) {
        applications = [];
        return;
      }

      final response = await supabase
          .from('applications')
          .select('*, application_modules(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      debugPrint(
          "STUDENT APPLICATIONS: ${response.toString()}");

      applications =
          List<Map<String, dynamic>>.from(response);

    } catch (e) {

      debugPrint(
          "fetchStudentApplications ERROR: $e");

      applications = [];

    } finally {

      isLoading = false;
      notifyListeners();
    }
  }

  // =====================================================
  // SUBMIT APPLICATION + MODULES
  // =====================================================
  Future<void> addApplication(
      Map<String, dynamic> data) async {
//added code
/*
Future<Map<String, dynamic>> addApplication(
    Map<String, dynamic> data) async
*/

    try {

      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      debugPrint("STEP 1 START");

      // =================================================
      // INSERT APPLICATION
      // =================================================
      final app = await supabase
          .from('applications')
          .insert({
            'user_id': user.id,
            'student_name': data['student_name'],
            'student_number':
                data['student_number'],
            'year_of_study':
                data['year_of_study'],
            'status': 'Pending',
          })
          .select()
          .single();

      debugPrint(
          "APPLICATION RESPONSE: $app");

      // =================================================
      // GET APPLICATION ID
      // =================================================
      final String applicationId =
          app['id'].toString();

      debugPrint(
          "APPLICATION ID: $applicationId");

      // =================================================
      // INSERT MODULE 1
      // =================================================
      if (data['module_one_name'] != null &&
          data['module_one_name']
              .toString()
              .trim()
              .isNotEmpty) {

        final module1 = await supabase
            .from('application_modules')
            .insert({
              'application_id':
                  applicationId,
              'module_name':
                  data['module_one_name'],
              'status': 'Pending',
            })
            .select();

        debugPrint(
            "MODULE 1 SUCCESS: $module1");
      }

      // =================================================
      // INSERT MODULE 2
      // =================================================
      if (data['module_two_name'] != null &&
          data['module_two_name']
              .toString()
              .trim()
              .isNotEmpty) {

        final module2 = await supabase
            .from('application_modules')
            .insert({
              'application_id':
                  applicationId,
              'module_name':
                  data['module_two_name'],
              'status': 'Pending',
            })
            .select();

        debugPrint(
            "MODULE 2 SUCCESS: $module2");
      }

      debugPrint("ALL INSERTS SUCCESS");

      // refresh student data
      await fetchStudentApplications();
    
    /*added code
    await fetchStudentApplications();

return {
  'id': app['id'],
  'student_name': data['student_name'],
  'student_number': data['student_number'],
  'year_of_study': data['year_of_study'],
  'status': 'Pending',
  'application_modules': [
    {
      'module_name': data['module_one_name'],
      'status': 'Pending',
    },
    if (data['module_two_name'] != null &&
        data['module_two_name'].toString().trim().isNotEmpty)
      {
        'module_name': data['module_two_name'],
        'status': 'Pending',
      },
  ],
};
end added code*/
    } catch (e) {

      debugPrint("addApplication ERROR: $e");

      rethrow;
    }
  }

  // =====================================================
  // ADMIN: APPROVE / REJECT MODULE
  // =====================================================
  Future<void> updateModule(
      String moduleId,
      String status,
      ) async {

    try {

      await supabase
          .from('application_modules')
          .update({
            'status': status,
          })
          .eq('id', moduleId);

      debugPrint(
          "MODULE UPDATED: $moduleId");

      await fetchApplications();

    } catch (e) {

      debugPrint(
          "updateModule ERROR: $e");
    }
  }

  // =====================================================
  // ADMIN: DELETE MODULE
  // =====================================================
  Future<void> deleteModule(
      String moduleId,
      ) async {

    try {

      await supabase
          .from('application_modules')
          .delete()
          .eq('id', moduleId);

      debugPrint(
          "MODULE DELETED: $moduleId");

      await fetchApplications();

    } catch (e) {

      debugPrint(
          "deleteModule ERROR: $e");
    }
  }

  // =====================================================
  // DELETE FULL APPLICATION
  // =====================================================
  Future<void> deleteApplication(
      String applicationId,
      ) async {

    try {

      // delete modules first
      await supabase
          .from('application_modules')
          .delete()
          .eq('application_id',
              applicationId);

      // delete application
      await supabase
          .from('applications')
          .delete()
          .eq('id', applicationId);

      debugPrint(
          "APPLICATION DELETED");

      await fetchApplications();

    } catch (e) {

      debugPrint(
          "deleteApplication ERROR: $e");
    }
  }
}