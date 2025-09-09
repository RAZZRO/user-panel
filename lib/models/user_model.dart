class User {
  final String nationalCode;
  final String firstName;
  final String lastName;
  final String phone;
  final String? startDate; 
  User({
    required this.nationalCode,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.startDate, 
  });

    factory User.fromJson(Map<String, dynamic> json) {
    return User(
      nationalCode: json['id'] ?? '',
      phone: json['phone'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      startDate: json['start_date'] ?? '',
    );
  }
}
