import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/application_viewmodel.dart';
import 'application_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    Future.microtask(() {
      Provider.of<ApplicationViewModel>(
        context,
        listen: false,
      ).fetchStudentApplications();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Provider.of<ApplicationViewModel>(
        context,
        listen: false,
      ).fetchStudentApplications();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ApplicationViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,

      appBar: AppBar(
        title: const Text(
          "My Applications",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ApplicationFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: vm.isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.blueGrey,
              ),
            )
          : vm.applications.isEmpty
              ? Center(
                  child: Text(
                    "No applications found",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: vm.applications.length,
                  itemBuilder: (context, index) {
                    final app = vm.applications[index];

                    final modules = List<Map<String, dynamic>>.from(
                      app['application_modules'] ?? [],
                    );

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),

                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),

                          childrenPadding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),

                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),

                          leading: CircleAvatar(
                            backgroundColor: Colors.blueGrey.shade100,
                            child: Icon(
                              Icons.person,
                              color: Colors.blueGrey.shade800,
                            ),
                          ),

                          title: Text(
                            app['student_name'] ?? "",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade900,
                              fontSize: 16,
                            ),
                          ),

                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                app['status'] ?? "Pending",
                                style: TextStyle(
                                  color: Colors.blueGrey.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          children: [
                            Divider(
                              color: Colors.blueGrey.shade100,
                              thickness: 1,
                            ),

                            const SizedBox(height: 10),

                            _buildInfoRow(
                              Icons.badge,
                              "Student Number",
                              app['student_number'].toString(),
                            ),

                            const SizedBox(height: 10),

                            _buildInfoRow(
                              Icons.school,
                              "Year of Study",
                              app['year_of_study'].toString(),
                            ),

                            const SizedBox(height: 18),

                            Text(
                              "Modules",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blueGrey.shade900,
                              ),
                            ),

                            const SizedBox(height: 10),

                            ...modules.map((m) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade50,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        Colors.blueGrey.shade200,
                                    child: Icon(
                                      Icons.book,
                                      color: Colors.blueGrey.shade900,
                                      size: 20,
                                    ),
                                  ),

                                  title: Text(
                                    m['module_name'] ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blueGrey.shade900,
                                    ),
                                  ),

                                  subtitle: Text(
                                    m['status'] ?? '',
                                    style: TextStyle(
                                      color: Colors.blueGrey.shade700,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.blueGrey,
        ),

        const SizedBox(width: 10),

        Text(
          "$title: ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey.shade800,
          ),
        ),

        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.blueGrey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}