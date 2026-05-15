class ApplicationModel {
  final String id;
  final String studentName;
  final String studentNumber;
  final String yearOfStudy;
  final String moduleOne;
  final String moduleTwo;
  final String status;

  ApplicationModel({
    required this.id,
    required this.studentName,
    required this.studentNumber,
    required this.yearOfStudy,
    required this.moduleOne,
    required this.moduleTwo,
    required this.status,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'],
      studentName: json['student_name'],
      studentNumber: json['student_number'],
      yearOfStudy: json['year_of_study'],
      moduleOne: json['module_one_name'],
      moduleTwo: json['module_two_name'] ?? '',
      status: json['status'],
    );
  }
}
