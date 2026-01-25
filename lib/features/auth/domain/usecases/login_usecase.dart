import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_response_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthResponseEntity>> call({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return Left(
        ValidationFailure(
          message: 'Email and password are required',
          errors: {
            'form': ['Email and password are required'],
          },
        ),
      );
    }

    if (!_isValidEmail(email)) {
      return Left(
        ValidationFailure(
          message: 'Invalid email format',
          errors: {
            'email': ['Invalid email format'],
          },
        ),
      );
    }

    if (password.length < 6) {
      return Left(
        ValidationFailure(
          message: 'Password must be at least 6 characters',
          errors: {
            'password': ['Password must be at least 6 characters'],
          },
        ),
      );
    }

    return await repository.login(email: email, password: password);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
