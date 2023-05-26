import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/image_model.dart';

class ApiService {
  final String baseUrl = 'https://picsum.photos';
  final String apiEndpoint = '/v2/list';
  final int perPage = 15;

  Future<List<ImageModel>> fetchImages(int page,
      {String filter = 'all'}) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl$apiEndpoint?page=$page&limit=$perPage&filter=$filter'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => ImageModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load images');
    }
  }
}
