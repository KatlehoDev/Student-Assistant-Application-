import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final supabase = Supabase.instance.client;

  List applications = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchApplications();
  }

  Future<void> fetchApplications() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabase
          .from('applications')
          .select('*, application_modules(*)');

      debugPrint("FULL RESPONSE: $response");

      applications = List<Map<String, dynamic>>.from(response).where((app) {
        final modules = app['application_modules'] ?? [];

        return modules.any(
          (module) => module['status'] != 'Rejected',
        );
      }).toList();
    } catch (e) {
      debugPrint("FETCH ERROR: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateModuleStatus(
    String moduleId,
    String status,
  ) async {
    try {
      await supabase
          .from('application_modules')
          .update({'status': status})
          .eq('id', moduleId);

      final moduleData = await supabase
          .from('application_modules')
          .select('''
            module_name,
            applications!inner(user_id, student_name)
          ''')
          .eq('id', moduleId)
          .single();

      final studentId = moduleData['applications']['user_id'];
      final moduleName = moduleData['module_name'] ?? 'Unknown Module';

      await supabase.from('notifications').insert({
        'user_id': studentId,
        'title': status == 'Approved' 
            ? ' Module Approved' 
            : ' Module Rejected',
        'message': 'Your module "$moduleName" has been $status.',
        'type': status == 'Approved' ? 'success' : 'error',
      });

      fetchApplications();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Module $status successfully!'),
            backgroundColor: status == 'Approved' ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("UPDATE ERROR: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update module'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> deleteModule(String moduleId) async {
    try {
      await supabase
          .from('application_modules')
          .delete()
          .eq('id', moduleId);

      fetchApplications();
    } catch (e) {
      debugPrint("DELETE ERROR: $e");
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await supabase.auth.signOut();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      } catch (e) {
        debugPrint("Logout Error: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logout failed'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;

      case 'Rejected':
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,

      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),

      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.blueGrey,
              ),
            )
          : applications.isEmpty
              ? Center(
                  child: Text(
                    "No applications found",
                    style: TextStyle(
                      color: Colors.blueGrey.shade700,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: Colors.blueGrey,
                  onRefresh: fetchApplications,

                  child: ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: applications.length,

                    itemBuilder: (context, index) {
                      final app = applications[index];

                      final modules =
                          app['application_modules'] ?? [];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueGrey.withOpacity(0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),

                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Padding(
                            padding: const EdgeInsets.all(18),

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [
                                // HEADER
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundColor:
                                          Colors.blueGrey.shade100,

                                      child: Icon(
                                        Icons.person,
                                        color:
                                            Colors.blueGrey.shade800,
                                      ),
                                    ),

                                    const SizedBox(width: 14),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Text(
                                            app['student_name'] ?? '',

                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight:
                                                  FontWeight.bold,
                                              color: Colors
                                                  .blueGrey.shade900,
                                            ),
                                          ),

                                          const SizedBox(height: 4),

                                          Text(
                                            "Student No: "
                                            "${app['student_number']}",

                                            style: TextStyle(
                                              color: Colors
                                                  .blueGrey.shade700,
                                            ),
                                          ),

                                          Text(
                                            "Year: "
                                            "${app['year_of_study']}",

                                            style: TextStyle(
                                              color: Colors
                                                  .blueGrey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                Divider(
                                  color:
                                      Colors.blueGrey.shade100,
                                  thickness: 1,
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  "Modules",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Colors.blueGrey.shade900,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // MODULES
                                modules.isEmpty
                                    ? Text(
                                        "No modules found",
                                        style: TextStyle(
                                          color: Colors
                                              .blueGrey.shade600,
                                        ),
                                      )
                                    : Column(
                                        children: modules
                                            .map<Widget>((module) {
                                          final status =
                                              module['status'] ??
                                                  'Pending';

                                          return Container(
                                            margin:
                                                const EdgeInsets.only(
                                              bottom: 12,
                                            ),

                                            decoration: BoxDecoration(
                                              color: Colors
                                                  .blueGrey.shade50,
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(16),
                                            ),

                                            child: ListTile(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 6,
                                              ),

                                              leading: CircleAvatar(
                                                backgroundColor:
                                                    Colors.blueGrey
                                                        .shade200,

                                                child: Icon(
                                                  Icons.book,
                                                  color: Colors
                                                      .blueGrey
                                                      .shade900,
                                                ),
                                              ),

                                              title: Text(
                                                module[
                                                        'module_name'] ??
                                                    '',

                                                style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color: Colors
                                                      .blueGrey
                                                      .shade900,
                                                ),
                                              ),

                                              subtitle: Padding(
                                                padding:
                                                    const EdgeInsets
                                                        .only(
                                                  top: 6,
                                                ),

                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                        horizontal:
                                                            10,
                                                        vertical: 4,
                                                      ),

                                                      decoration:
                                                          BoxDecoration(
                                                        color: getStatusColor(
                                                          status,
                                                        ).withOpacity(
                                                          0.15,
                                                        ),

                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          20,
                                                        ),
                                                      ),

                                                      child: Text(
                                                        status,

                                                        style:
                                                            TextStyle(
                                                          color:
                                                              getStatusColor(
                                                            status,
                                                          ),

                                                          fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              trailing:
                                                  PopupMenuButton<
                                                      String>(
                                                icon: Icon(
                                                  Icons.more_vert,
                                                  color: Colors
                                                      .blueGrey
                                                      .shade700,
                                                ),

                                                onSelected: (value) {
                                                  if (value ==
                                                      'approve') {
                                                    updateModuleStatus(
                                                      module['id'],
                                                      'Approved',
                                                    );
                                                  }

                                                  if (value ==
                                                      'reject') {
                                                    updateModuleStatus(
                                                      module['id'],
                                                      'Rejected',
                                                    );
                                                  }

                                                  if (value ==
                                                      'delete') {
                                                    deleteModule(
                                                      module['id'],
                                                    );
                                                  }
                                                },

                                                itemBuilder:
                                                    (context) => [
                                                  const PopupMenuItem(
                                                    value:
                                                        'approve',

                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .check_circle,
                                                          color:
                                                              Colors
                                                                  .green,
                                                        ),

                                                        SizedBox(
                                                          width:
                                                              10,
                                                        ),

                                                        Text(
                                                          'Approve',
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  const PopupMenuItem(
                                                    value:
                                                        'reject',

                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .cancel,
                                                          color:
                                                              Colors
                                                                  .red,
                                                        ),

                                                        SizedBox(
                                                          width:
                                                              10,
                                                        ),

                                                        Text(
                                                          'Reject',
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  const PopupMenuItem(
                                                    value:
                                                        'delete',

                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .delete,
                                                          color:
                                                              Colors
                                                                  .grey,
                                                        ),

                                                        SizedBox(
                                                          width:
                                                              10,
                                                        ),

                                                        Text(
                                                          'Delete',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}