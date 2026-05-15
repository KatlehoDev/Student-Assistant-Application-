// models/application_model.dart
/*
Student Numbers : 224005352, 224120586, 224063746, 224049675, 224124912, 222022131, 224127468, 224124382, 224086876

Student Names : Mphomela Katleho, Motaung Vincent, Asande Mkabela, Vuyisile Fihlo, Tabi Malefetsane, Tsebano Stemer,
                Hlongwane Luyanda, Sisekelo Mtshali, Kasa Tlotliso

Question Page : Application Model


*/ 




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
