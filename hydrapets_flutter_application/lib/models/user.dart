class User {
  final String userId;
  final String userName;
  final String userEmail;
  final String userPassword;
  final String petName;
  final String timestamp;

  User({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPassword,
    required this.petName,
    required this.timestamp,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name'] ?? '',
      userEmail: json['user_email'] ?? '',
      userPassword: json['user_password'] ?? '',
      petName: json['pet_name'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'user_password': userPassword,
      'pet_name': petName,
      'timestamp': timestamp,
    };
  }

  @override
  String toString() {
    return 'User(userId: $userId, userName: $userName, userEmail: $userEmail, petName: $petName, timestamp: $timestamp)';
  }
} 