import 'dart:convert';
import 'package:awesome_portfolio/apps/data/apps_model.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

part 'apps_state.dart';

class AppsCubit extends Cubit<AppsState> {
  AppsCubit() : super(AppsInitial());
  final dio = Dio();

  // دالة لتحميل أسماء الملفات التي تحتوي على صور
  Future<List<String>> fetchFileNames(String repoUrl) async {
    final response = await dio.get("$repoUrl/contents");

    if (response.statusCode == 200) {
      final List<dynamic> files = response.data;
      final List<String> filteredFiles = [];
      for (var i in files) {
        if (i['type'] == 'dir') {
          filteredFiles.add(i['name']);
        }
      }
      return filteredFiles;
    } else {
      print("error");
      throw Exception('Failed to load files');
    }
  }

  // دالة لتحميل جميع الصور داخل ملف معين
  Future<FileImagesModel> fetchAllImages(String fileUrl) async {
    final response = await dio.get(fileUrl);

    if (response.statusCode == 200) {
      final List<dynamic> images = response.data;
      return FileImagesModel.fromJson(images);
    } else {
      throw Exception('Failed to load images');
    }
  }

  // تحميل الملفات من الـ repo
  Future<void> loadFiles(String repoUrl) async {
    emit(FileGridLoading());
    try {
      final files = await fetchFileNames(repoUrl);
      emit(FileGridLoaded(files));
    } catch (e) {
      emit(FileGridError(e.toString()));
    }
  }

  // تحميل الصور داخل ملف معين
  Future<void> loadFileImages(String fileUrl) async {
    emit(FileImagesLoading());
    try {
      final images = await fetchAllImages(fileUrl);
      print("images.images");
      print(images.images);
      emit(FileImagesLoaded(images.images));
    } catch (e) {
      print(e);
      emit(FileImagesError(e.toString()));
    }
  }
}
