import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'application_form_screen.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> applications = [];
  bool isLoading = true;

  late final StreamSubscription<List<Map<String, dynamic>>> _subscription;

  @override
  void initState() {
    super.initState();
    fetchApplications();
    _setupRealtime();
  }

  Future<void> fetchApplications() async {
    setState(() => isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('profiles')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        applications = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("Fetch Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _setupRealtime() {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    _subscription = supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .listen((data) {
          print(" Realtime update received!");
          setState(() {
            applications = List<Map<String, dynamic>>.from(data);
          });
        });
  }

  @override
  void dispose() {
    _subscription.cancel(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Home'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchApplications),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : applications.isEmpty
              ? const Center(
                  child: Text(
                    'No applications yet.\nTap + to create one.',
                    textAlign: TextAlign.center,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchApplications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: applications.length,
                    itemBuilder: (context, index) {
                      final app = applications[index];
                      final status = app['status']?.toString() ?? 'Pending';

                      Color statusColor = Colors.orange;
                      if (status == 'Approved') statusColor = Colors.green;
                      if (status == 'Rejected') statusColor = Colors.red;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            app['full_name'] ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(app['student_number'] ?? ''),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ApplicationFormScreen()),
          );
          fetchApplications(); // Refresh after coming back
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}