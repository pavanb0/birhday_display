import 'package:dio/dio.dart';

class Apiservice {
  late Dio _dio;
  //local link
  //String BaserUrl = "https://a7ff-152-52-228-70.ngrok-free.app/";
  // String BaserUrl = "http://192.168.64.2:5136/";

  //Productio link.
  String BaserUrl = "https://api.mahaagro.org/";

  Apiservice() {
    _dio = Dio(
      BaseOptions(
        baseUrl: BaserUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
  }

  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(endpoint, queryParameters: queryParameters);
  }

  Future<Response> post(String endpoint, {dynamic data}) {
    return _dio.post(endpoint, data: data);
  }
}
