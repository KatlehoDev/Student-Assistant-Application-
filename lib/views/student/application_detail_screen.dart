import 'package:flutter/material.dart';

class ApplicationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> application;

  const ApplicationDetailScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    // =====================================
    // MODULES
    // =====================================
    final modules = application['application_modules'] ?? [];

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,

      appBar: AppBar(
        title: const Text(
          "Application Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),

            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),

          child: Card(
            elevation: 0,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),

            child: Padding(
              padding: const EdgeInsets.all(24),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // =========================
                  // SUCCESS ICON
                  // =========================
                  Center(
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.green.shade100,

                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 60,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =========================
                  // SUCCESS TITLE
                  // =========================
                  const Center(
                    child: Text(
                      "Application Submitted Successfully",
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Center(
                    child: Text(
                      "Your application has been received.",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blueGrey.shade600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  // =========================
                  // APPLICATION INFO TITLE
                  // =========================
                  Text(
                    "Application Information",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade900,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =========================
                  // APPLICATION INFO
                  // =========================
                  buildDetailCard(
                    Icons.confirmation_number,
                    "Application ID",
                    application['id'].toString(),
                  ),

                  buildDetailCard(
                    Icons.person,
                    "Student Name",
                    application['student_name'] ?? '',
                  ),

                  buildDetailCard(
                    Icons.badge,
                    "Student Number",
                    application['student_number'] ?? '',
                  ),

                  buildDetailCard(
                    Icons.school,
                    "Year Of Study",
                    application['year_of_study'] ?? '',
                  ),

                  buildStatusCard(application['status'] ?? 'Pending'),

                  const SizedBox(height: 30),

                  // =========================
                  // MODULES TITLE
                  // =========================
                  Text(
                    "Modules Applied For",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade900,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // =========================
                  // MODULES LIST
                  // =========================
                  modules.isEmpty
                      ? Text(
                          "No modules found",
                          style: TextStyle(color: Colors.blueGrey.shade600),
                        )
                      : Column(
                          children: modules.map<Widget>((module) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),

                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade50,

                                borderRadius: BorderRadius.circular(18),
                              ),

                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),

                                leading: CircleAvatar(
                                  backgroundColor: Colors.blueGrey.shade200,

                                  child: Icon(
                                    Icons.book,
                                    color: Colors.blueGrey.shade900,
                                  ),
                                ),

                                title: Text(
                                  module['module_name'] ?? '',

                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey.shade900,
                                  ),
                                ),

                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8),

                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),

                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,

                                      borderRadius: BorderRadius.circular(20),
                                    ),

                                    child: Text(
                                      module['status'] ?? '',

                                      style: TextStyle(
                                        color: Colors.orange.shade900,

                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =====================================
  // DETAIL CARD
  // =====================================
  Widget buildDetailCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          CircleAvatar(
            backgroundColor: Colors.blueGrey.shade200,

            child: Icon(icon, color: Colors.blueGrey.shade900),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade600,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  value,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.blueGrey.shade900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================
  // STATUS CARD
  // =====================================
  Widget buildStatusCard(String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,

            child: const Icon(Icons.pending_actions, color: Colors.blue),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  "Application Status",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade600,
                  ),
                ),

                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    status,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
