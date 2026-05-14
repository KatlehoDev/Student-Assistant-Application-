import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'application_detail_screen.dart';

class ApplicationFormScreen extends StatefulWidget {
  const ApplicationFormScreen({super.key});

  @override
  State<ApplicationFormScreen> createState() =>
      _ApplicationFormScreenState();
}

class _ApplicationFormScreenState
    extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController =
      TextEditingController();

  final TextEditingController studentNumberController =
      TextEditingController();
  final List<String> modules = [
    "SOD",
    "INT",
    "TPG",
    "GUD",
    "MAD",
  ];

  String? selectedModule1;
  String? selectedModule2;

  String? yearOfStudy;

  bool isLoading = false;

  @override
  void dispose() {
    fullNameController.dispose();
    studentNumberController.dispose();
    super.dispose();
  }

  Future<void> submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedModule1 == selectedModule2 &&
        selectedModule2 != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade400,
          content: const Text(
            "You cannot select the same module twice",
          ),
        ),
      );

      return;
    }

    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    setState(() => isLoading = true);

    final supabase = Supabase.instance.client;

    try {
      final app = await supabase
          .from('applications')
          .insert({
            'user_id': user.id,
            'student_name':
                fullNameController.text.trim(),
            'student_number':
                studentNumberController.text.trim(),
            'year_of_study': yearOfStudy,
            'status': 'Pending',
          })
          .select()
          .single();

      final String applicationId =
          app['id'].toString();

      await supabase
          .from('application_modules')
          .insert({
        'application_id': applicationId,
        'module_name': selectedModule1,
        'status': 'Pending',
      });

      if (selectedModule2 != null &&
          selectedModule2!.isNotEmpty) {
        await supabase
            .from('application_modules')
            .insert({
          'application_id': applicationId,
          'module_name': selectedModule2,
          'status': 'Pending',
        });
      }

      if (!mounted) return;

      final applicationData = {
        'id': applicationId,
        'student_name':
            fullNameController.text.trim(),
        'student_number':
            studentNumberController.text.trim(),
        'year_of_study': yearOfStudy,
        'status': 'Pending',
        'application_modules': [
          {
            'module_name': selectedModule1,
            'status': 'Pending',
          },
          if (selectedModule2 != null &&
              selectedModule2!.isNotEmpty)
            {
              'module_name': selectedModule2,
              'status': 'Pending',
            },
        ],
      };

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ApplicationDetailScreen(
            application: applicationData,
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        "SUBMIT APPLICATION ERROR: $e",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade400,
          content: Text("Error: $e"),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  InputDecoration customDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,

      prefixIcon: Icon(
        icon,
        color: Colors.blueGrey,
      ),

      filled: true,
      fillColor: Colors.blueGrey.shade50,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.blueGrey,
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,

      appBar: AppBar(
        title: const Text(
          "Student Assistant Application",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Container(
            padding: const EdgeInsets.all(24),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),

              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),

            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                 
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor:
                          Colors.blueGrey.shade100,

                      child: Icon(
                        Icons.assignment,
                        size: 45,
                        color:
                            Colors.blueGrey.shade800,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      "Application Form",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color:
                            Colors.blueGrey.shade900,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Center(
                    child: Text(
                      "Fill in your details below",
                      style: TextStyle(
                        color:
                            Colors.blueGrey.shade600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  
                  TextFormField(
                    controller: fullNameController,

                    decoration: customDecoration(
                      "Full Name",
                      Icons.person_outline,
                    ),

                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return "Enter full name";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                 
                  TextFormField(
                    controller:
                        studentNumberController,

                    decoration: customDecoration(
                      "Student Number",
                      Icons.badge_outlined,
                    ),

                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return "Enter student number";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  
                  DropdownButtonFormField<String>(
                    initialValue: yearOfStudy,

                    decoration: customDecoration(
                      "Year Of Study",
                      Icons.school_outlined,
                    ),

                    items: const [
                      DropdownMenuItem(
                        value: "1st Year",
                        child: Text("1st Year"),
                      ),

                      DropdownMenuItem(
                        value: "2nd Year",
                        child: Text("2nd Year"),
                      ),

                      DropdownMenuItem(
                        value: "3rd Year",
                        child: Text("3rd Year"),
                      ),
                    ],

                    onChanged: (value) {
                      setState(() {
                        yearOfStudy = value;
                      });
                    },

                    validator: (value) {
                      if (value == null) {
                        return "Select year";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  DropdownButtonFormField<String>(
                    initialValue: selectedModule1,

                    decoration: customDecoration(
                      "Module 1",
                      Icons.book_outlined,
                    ),

                    items: modules.map((module) {
                      return DropdownMenuItem(
                        value: module,
                        child: Text(module),
                      );
                    }).toList(),

                    onChanged: (value) {
                      setState(() {
                        selectedModule1 = value;
                      });
                    },

                    validator: (value) {
                      if (value == null) {
                        return "Select module 1";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  DropdownButtonFormField<String>(
                    initialValue: selectedModule2,

                    decoration: customDecoration(
                      "Module 2 (Optional)",
                      Icons.menu_book_outlined,
                    ),

                    items: modules.map((module) {
                      return DropdownMenuItem(
                        value: module,
                        child: Text(module),
                      );
                    }).toList(),

                    onChanged: (value) {
                      setState(() {
                        selectedModule2 = value;
                      });
                    },
                  ),

                  const SizedBox(height: 35),

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.blueGrey,
                        foregroundColor:
                            Colors.white,
                        elevation: 3,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                        ),
                      ),

                      onPressed: isLoading
                          ? null
                          : submitApplication,

                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "SUBMIT APPLICATION",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}