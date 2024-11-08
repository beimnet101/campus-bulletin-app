class Student {
  String? firstName;
  String? lastName;
  String? userName;
  String? email;
  int? department;
  int? year;
  String? phoneNumber;
  String? passwordHash;
  String? avatar;

  Student({
    this.firstName,
    this.lastName,
    this.userName,
    this.email,
    this.department,
    this.year,
    this.phoneNumber,
    this.passwordHash,
    this.avatar,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      firstName: json['firstName'],
      lastName: json['lastName'],
      userName: json['userName'],
      email: json['email'],
      department: json['department'],
      year: json['yearOfStudy'],
      phoneNumber: json['phoneNumber'],
      passwordHash: json['passwordHash'],
      avatar: json['photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'department': department,
      'year': year,
      'phoneNumber': phoneNumber,
      'userName': userName,
      'avatar': avatar,
      'passwordHash': passwordHash,
    };
  }
}
