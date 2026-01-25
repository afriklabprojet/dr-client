import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_response_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, AuthResponseEntity>> call({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? address,
  }) async {
    // Validation
    if (name.isEmpty) {
      return Left(
        ValidationFailure(
          message: 'Name is required',
          errors: {
            'name': ['Name is required'],
          },
        ),
      );
    }

    if (email.isEmpty || !_isValidEmail(email)) {
      return Left(
        ValidationFailure(
          message: 'Invalid email format',
          errors: {
            'email': ['Invalid email format'],
          },
        ),
      );
    }

    if (phone.isEmpty || !_isValidPhone(phone)) {
      return Left(
        ValidationFailure(
          message: 'Invalid phone number',
          errors: {
            'phone': ['Invalid phone number'],
          },
        ),
      );
    }

    if (password.isEmpty || password.length < 6) {
      return Left(
        ValidationFailure(
          message: 'Password must be at least 6 characters',
          errors: {
            'password': ['Password must be at least 6 characters'],
          },
        ),
      );
    }

    if (password != passwordConfirmation) {
      return Left(
        ValidationFailure(
          message: 'Passwords do not match',
          errors: {
            'password': ['Passwords do not match'],
          },
        ),
      );
    }

    return await repository.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      address: address,
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    // Côte d'Ivoire phone format: +225 XX XX XX XX XX or variations
    final phoneRegex = RegExp(r'^(\+?225)?[0-9]{10}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'\s'), ''));
  }
}
