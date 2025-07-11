// Future<LoginResponse> loginUser(LoginRequest loginRequest) async {
//     try {
//       final response = await _apiClient.post("/Authentication/Login", data: loginRequest.toJson());
//       return LoginResponse.fromJson(response.data);
//     } catch (e) {
//       rethrow;
//     }
//   }

import 'package:birhthday_display/api/models/birthdayModel.dart';
import 'package:birhthday_display/api/services/apiservice.dart';

class Birthdayservice {
  final Apiservice _apiservice = Apiservice();
  Future<BirthdayModel> getBirhday() async {
    try {
      final response = await _apiservice.get("/Generic/GetBirthday");
      return BirthdayModel.fromJson(response.data);
    } catch (c) {
      rethrow;
    }
  }
}
