import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApplicationViewModel extends ChangeNotifier {

  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> applications = [];

  bool isLoading = false;

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

  Future<void> addApplication(
      Map<String, dynamic> data) async {

    try {

      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      debugPrint("STEP 1 START");

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

      final String applicationId =
          app['id'].toString();

      debugPrint(
          "APPLICATION ID: $applicationId");

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

      await fetchStudentApplications();
    
    } catch (e) {

      debugPrint("addApplication ERROR: $e");

      rethrow;
    }
  }

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

  Future<void> deleteApplication(
      String applicationId,
      ) async {

    try {

      await supabase
          .from('application_modules')
          .delete()
          .eq('application_id',
              applicationId);

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