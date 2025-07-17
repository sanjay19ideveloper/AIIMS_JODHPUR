import 'package:aiims_heartcare/data/model/AttemptSaveResponse.dart';
import 'package:aiims_heartcare/data/model/DailyLogSaveResponse.dart';
import 'package:aiims_heartcare/data/model/DailyLogsResp.dart';
import 'package:aiims_heartcare/data/model/LabReportResp.dart';
import 'package:aiims_heartcare/data/model/LearningContent.dart';
import 'package:aiims_heartcare/data/model/LearningModel.dart';
import 'package:aiims_heartcare/data/model/QuestionListResp.dart';
import 'package:aiims_heartcare/data/model/ZoneSaveResp.dart';
import 'package:aiims_heartcare/data/model/attemptCreateModel.dart';
import 'package:aiims_heartcare/data/model/attemptModel.dart';
import 'package:aiims_heartcare/data/model/loginModel.dart';
import 'package:aiims_heartcare/data/model/medicineModel.dart';
import 'package:aiims_heartcare/data/model/profileModel.dart';
import 'package:aiims_heartcare/data/model/request/AttemptSaveRequest.dart';
import 'package:aiims_heartcare/data/model/request/login_request.dart';
import 'package:aiims_heartcare/data/model/weightListResp.dart';
import 'package:aiims_heartcare/data/provider/home_provider.dart';
import 'package:aiims_heartcare/utils/log.dart' show Log;
import 'package:aiims_heartcare/utils/user_sessions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeRepository {
  HomeRepository({required this.homeProvider});

  final HomeProvider homeProvider;

  Future<LoginResponse> login({LoginRequest? request}) async {
    try {
      final response = await homeProvider.login(request: request);

      if (response != null && response.success) {
        Log.v("Login Success: ${response.body}");
        LoginResponse user = LoginResponse.fromJson(response.body);
        // Preference.setString(Preference.USER_TOKEN, user.token!);
        UserSession.userToken = user.token!;
        UserSession.email = user.user?.email;
        UserSession.userName = user.user?.name;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userToken', user.token!); // Save token
        await prefs.setString('email', user.user?.email ?? '');
        await prefs.setString('userName', user.user?.name ?? '');
        await prefs.setString('daily_liquid_intake_limit', user.user?.daily_liquid_intake_limit ?? '');
        await prefs.setString('liquid_intake_limit_measurement', user.user?.liquidIntakeLimitMeasurement ?? '');
        return user;
      } else {
        Log.v("Login Failed: ${response?.body}");
        return LoginResponse();
      }
    } catch (e, stackTrace) {
      Log.v("Exception occurred in HomeRepository.login: $e");
      Log.v("Stack trace: $stackTrace");
      return LoginResponse();
    }
  }

  Future<AttemptSaveResponse> getSaveResponse({
    AttemptSaveRequest? request,
  }) async {
    try {
      final response = await homeProvider.getSaveResponse(request: request);

      if (response != null && response.success) {
        Log.v("save question success: ${response.body}");
        AttemptSaveResponse attemptDetails = AttemptSaveResponse.fromJson(
          response.body,
        );

        return attemptDetails;
      } else {
        Log.v("save question Failed: ${response?.body}");
        return AttemptSaveResponse();
      }
    } catch (e, stackTrace) {
      Log.v("Exception occurred in HomeRepository.login: $e");
      Log.v("Stack trace: $stackTrace");
      return AttemptSaveResponse();
    }
  }

  Future<LearningModel> myLearning() async {
    try {
      final response = await homeProvider.myLearning();

      if (response != null && response.success) {
        Log.v("Login Success: ${response.body}");
        LearningModel learingDataResp = LearningModel.fromJson(response.body);

        return learingDataResp;
      } else {
        Log.v("Login Failed: ${response?.body}");
        return LearningModel();
      }
    } catch (e, stackTrace) {
      Log.v("Exception occurred in HomeRepository.login: $e");
      Log.v("Stack trace: $stackTrace");
      return LearningModel();
    }
  }

  Future<AttemptResponse> getAttemptList() async {
    try {
      final response = await homeProvider.getAttemptList();

      if (response != null && response.success) {
        Log.v("Login Success: ${response.body}");
        AttemptResponse learingDataResp = AttemptResponse.fromJson(
          response.body,
        );

        return learingDataResp;
      } else {
        Log.v("Login Failed: ${response?.body}");
        return AttemptResponse();
      }
    } catch (e, stackTrace) {
      Log.v("Exception occurred in HomeRepository.login: $e");
      Log.v("Stack trace: $stackTrace");
      return AttemptResponse();
    }
  }

  Future<AttemptCreateResponse> getAttemptCreate() async {
    try {
      final response = await homeProvider.getAttemptCreate();

      if (response != null && response.success) {
        Log.v("Login Success: ${response.body}");
        AttemptCreateResponse learingDataResp = AttemptCreateResponse.fromJson(
          response.body,
        );

        return learingDataResp;
      } else {
        Log.v("Login Failed: ${response?.body}");
        return AttemptCreateResponse();
      }
    } catch (e, stackTrace) {
      Log.v("Exception occurred in HomeRepository.login: $e");
      Log.v("Stack trace: $stackTrace");
      return AttemptCreateResponse();
    }
  }

  Future<QuestionListResponse> getQuestionList() async {
    try {
      final response = await homeProvider.getQuestionList();

      if (response != null && response.success) {
        Log.v("Login Success: ${response.body}");
        QuestionListResponse learingDataResp = QuestionListResponse.fromJson(
          response.body,
        );

        return learingDataResp;
      } else {
        Log.v("Login Failed: ${response?.body}");
        return QuestionListResponse();
      }
    } catch (e, stackTrace) {
      Log.v("Exception occurred in HomeRepository.login: $e");
      Log.v("Stack trace: $stackTrace");
      return QuestionListResponse();
    }
  }

  Future<LabReportResponse> getLabReport() async {
    try {
      final response = await homeProvider.getLabReport();

      if (response != null && response.success) {
        Log.v("Login Success: ${response.body}");
        LabReportResponse learingDataResp = LabReportResponse.fromJson(
          response.body,
        );

        return learingDataResp;
      } else {
        Log.v("Login Failed: ${response?.body}");
        return LabReportResponse();
      }
    } catch (e, stackTrace) {
      Log.v("Exception occurred in HomeRepository.login: $e");
      Log.v("Stack trace: $stackTrace");
      return LabReportResponse();
    }
  }

  Future<LearningContent> getLearningContent({required String slug}) async {
    try {
      final response = await homeProvider.getLearningContent(slug: slug);

      if (response != null && response.success) {
        Log.v("Login Success: ${response.body}");
        LearningContent learingDataResp = LearningContent.fromJson(
          response.body,
        );

        return learingDataResp;
      } else {
        Log.v("Login Failed: ${response?.body}");
        return LearningContent();
      }
    } catch (e, stackTrace) {
      Log.v("Exception occurred in HomeRepository.login: $e");
      Log.v("Stack trace: $stackTrace");
      return LearningContent();
    }
  }

  Future<DailyLogResp> myReminder() async {
    try {
      final response = await homeProvider.myReminder();

      if (response != null && response.success) {
        Log.v("logs Success: ${response.body}");
        DailyLogResp logResponse = DailyLogResp.fromJson(response.body);

        return logResponse;
      } else {
        Log.v("logs Failed: ${response?.body}");
        return DailyLogResp();
      }
    } catch (e, stackTrace) {
      Log.v("Exception occurred in HomeRepository.logs: $e");
      Log.v("Stack trace: $stackTrace");
      return DailyLogResp();
    }
  }

  Future<ProfileModel> myProfile() async {
    try {
      final response = await homeProvider.myProfile();

      if (response != null && response.success) {
        Log.v("profile Success: ${response.body}");
        ProfileModel profileResponse = ProfileModel.fromJson(response.body);

        return profileResponse;
      } else {
        Log.v("profile Failed: ${response?.body}");
        return ProfileModel();
      }
    } catch (e, stackTrace) {
      Log.v("Exception occurred in HomeRepository.profile: $e");
      Log.v("Stack trace: $stackTrace");
      return ProfileModel();
    }
  }

  Future<WeightListResp> weightSave({String? weight}) async {
    try {
      final response = await homeProvider.weightSave(weight: weight);

      if (response != null && response.success) {
        Log.v("profile Success: ${response.body}");
        WeightListResp weightListResponse = WeightListResp.fromJson(
          response.body,
        );

        return weightListResponse;
      } else {
        Log.v("profile Failed: ${response?.body}");
        return WeightListResp();
      }
    } catch (e, stackTrace) {
      Log.v("Exception occurred in HomeRepository.profile: $e");
      Log.v("Stack trace: $stackTrace");
      return WeightListResp();
    }
  }

  Future<ZoneSaveResponse> getZoneSave({String? zone}) async {
    try {
      final response = await homeProvider.getZoneSave(zone: zone);

      if (response != null && response.success) {
        Log.v("zone save  Success: ${response.body}");
        ZoneSaveResponse weightListResponse = ZoneSaveResponse.fromJson(
          response.body,
        );

        return weightListResponse;
      } else {
        Log.v("savwe  Failed: ${response?.body}");
        return ZoneSaveResponse();
      }
    } catch (e, stackTrace) {
      Log.v("Exception occurred in HomeRepository.profile: $e");
      Log.v("Stack trace: $stackTrace");
      return ZoneSaveResponse();
    }
  }

  Future<DailyLogSaveResponse> logSave({String? howMuch}) async {
    try {
      final response = await homeProvider.logSave(howMuch: howMuch);

      if (response != null && response.success) {
        Log.v("profile Success: ${response.body}");
        DailyLogSaveResponse dailyLogResponse = DailyLogSaveResponse.fromJson(response.body);

        return dailyLogResponse;
      } else {
        Log.v("profile Failed: ${response?.body}");
        return DailyLogSaveResponse();
      }
    } catch (e, stackTrace) {
      Log.v("Exception occurred in HomeRepository.profile: $e");
      Log.v("Stack trace: $stackTrace");
      return DailyLogSaveResponse();
    }
  }

  Future<WeightListResp> getWeightList() async {
    try {
      final response = await homeProvider.getWeightList();

      if (response != null && response.success) {
        Log.v("profile Success: ${response.body}");
        WeightListResp weightListResponse = WeightListResp.fromJson(
          response.body,
        );

        return weightListResponse;
      } else {
        Log.v("profile Failed: ${response?.body}");
        return WeightListResp();
      }
    } catch (e, stackTrace) {
      Log.v("Exception occurred in HomeRepository.profile: $e");
      Log.v("Stack trace: $stackTrace");
      return WeightListResp();
    }
  }

  Future<MedicineResponse> getMedicineList() async {
    try {
      final response = await homeProvider.getMedicineList();

      if (response != null && response.success) {
        Log.v("profile Success: ${response.body}");
        MedicineResponse MedicineResp = MedicineResponse.fromJson(
          response.body,
        );

        return MedicineResp;
      } else {
        Log.v("profile Failed: ${response?.body}");
        return MedicineResponse();
      }
    } catch (e, stackTrace) {
      Log.v("Exception occurred in HomeRepository.profile: $e");
      Log.v("Stack trace: $stackTrace");
      return MedicineResponse();
    }
  }
}
