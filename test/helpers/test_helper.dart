import 'package:financas_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:financas_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:financas_app/features/auth/data/datasources/auth_local_datasource.dart';

@GenerateMocks([
  AuthRepository,
  AuthRemoteDataSource,
  AuthLocalDataSource,
])
void main() {}
