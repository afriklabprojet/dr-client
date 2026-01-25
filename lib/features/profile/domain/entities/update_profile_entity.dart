import 'package:equatable/equatable.dart';

class UpdateProfileEntity extends Equatable {
  final String? name;
  final String? email;
  final String? phone;
  final String? currentPassword;
  final String? newPassword;
  final String? newPasswordConfirmation;

  const UpdateProfileEntity({
    this.name,
    this.email,
    this.phone,
    this.currentPassword,
    this.newPassword,
    this.newPasswordConfirmation,
  });

  bool get hasPasswordChange =>
      currentPassword != null && newPassword != null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (name != null) json['name'] = name;
    if (email != null) json['email'] = email;
    if (phone != null) json['phone'] = phone;
    if (currentPassword != null) json['current_password'] = currentPassword;
    if (newPassword != null) json['password'] = newPassword;
    if (newPasswordConfirmation != null) {
      json['password_confirmation'] = newPasswordConfirmation;
    }

    return json;
  }

  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        currentPassword,
        newPassword,
        newPasswordConfirmation,
      ];
}
