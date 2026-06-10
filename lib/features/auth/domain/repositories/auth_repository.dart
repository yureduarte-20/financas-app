import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> login({required String email, required String password});
  Future<Either<Failure, void>> register({required String name, required String email, required String password});
  Future<Either<Failure, User>> verifyCode({required String email, required String code, required String deviceName});
  Future<Either<Failure, void>> resendCode({required String email, required String type});
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> getProfile();
}
