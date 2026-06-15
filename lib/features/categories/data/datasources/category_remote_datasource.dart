import 'package:dio/dio.dart';
import '../../../../core/constants/api_paths.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getAll();
  Future<CategoryModel> getById(String id);
  Future<CategoryModel> create({
    required String name,
    required String icon,
    required String color,
  });
  Future<CategoryModel> update({
    required String id,
    required String name,
    required String icon,
    required String color,
  });
  Future<void> delete(String id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final Dio dio;

  CategoryRemoteDataSourceImpl(this.dio);

  @override
  Future<List<CategoryModel>> getAll() async {
    final response = await dio.get(ApiPaths.categories);
    final data = response.data['data'] as List<dynamic>? ?? [];
    return data
        .map((j) => CategoryModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CategoryModel> getById(String id) async {
    final response = await dio.get('${ApiPaths.categories}/$id');
    final data = response.data['data'] as Map<String, dynamic>;
    return CategoryModel.fromJson(data);
  }

  @override
  Future<CategoryModel> create({
    required String name,
    required String icon,
    required String color,
  }) async {
    final response = await dio.post(
      ApiPaths.categories,
      data: {'name': name, 'icon': icon, 'color': color},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return CategoryModel.fromJson(data);
  }

  @override
  Future<CategoryModel> update({
    required String id,
    required String name,
    required String icon,
    required String color,
  }) async {
    final response = await dio.put(
      '${ApiPaths.categories}/$id',
      data: {'name': name, 'icon': icon, 'color': color},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return CategoryModel.fromJson(data);
  }

  @override
  Future<void> delete(String id) async {
    await dio.delete('${ApiPaths.categories}/$id');
  }
}
