// ignore_for_file: override_on_non_overriding_member

import 'package:aiims_heartcare/data/api/api_service.dart';
import 'package:aiims_heartcare/data/model/AttemptSaveResponse.dart';
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
import 'package:aiims_heartcare/data/repositories/home_repository.dart';
import 'package:aiims_heartcare/utils/log.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/widgets.dart';
import 'package:injector/injector.dart';

abstract class HomeEvent {
  HomeEvent([List event = const []]) : super();
}

class LoginEvent extends HomeEvent {
  final LoginRequest? request;

  LoginEvent({@required this.request}) : super([request]);

  // TODO: implement props
  List<Object> get props => throw UnimplementedError();
}

class AttemptSaveEvent extends HomeEvent {
  final AttemptSaveRequest? request;

  AttemptSaveEvent({@required this.request}) : super([request]);

  // TODO: implement props
  List<Object> get props => throw UnimplementedError();
}

class MyLearningEvent extends HomeEvent {
  MyLearningEvent() : super([]);
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();
}

class LearningContentEvent extends HomeEvent {
  final String slug; // Non-nullable
  LearningContentEvent({required this.slug}) : super([]);
  @override
  List<Object> get props => [slug];
}

class AttemptEvent extends HomeEvent {
  AttemptEvent() : super([]);
  @override
  List<Object> get props => [];
}

class AttemptCreateEvent extends HomeEvent {
  AttemptCreateEvent() : super([]);
  @override
  List<Object> get props => [];
}

class QuestionEvent extends HomeEvent {
  QuestionEvent() : super([]);
  @override
  List<Object> get props => [];
}

class ReminderEvent extends HomeEvent {
  ReminderEvent() : super([]);
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();
}

class ProfileEvent extends HomeEvent {
  ProfileEvent() : super([]);
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();
}

class LabReportEvent extends HomeEvent {
  LabReportEvent() : super([]);

  List<Object> get props => throw UnimplementedError();
}

class WeightSaveEvent extends HomeEvent {
  String? weight;

  WeightSaveEvent({this.weight}) : super([]);

  List<Object> get props => throw UnimplementedError();
}

class ZoneSaveEvent extends HomeEvent {
  String? zone;

  ZoneSaveEvent({this.zone}) : super([]);

  List<Object> get props => throw UnimplementedError();
}

class LogSaveEvent extends HomeEvent {
  String? howMuch;

  LogSaveEvent({this.howMuch}) : super([]);

  List<Object> get props => throw UnimplementedError();
}

class SaveResponseEvent extends HomeEvent {
  final Map<String, dynamic> payload;

  SaveResponseEvent({required this.payload});

  List<Object> get props => throw UnimplementedError();
}

class WeightListEvent extends HomeEvent {
  WeightListEvent() : super([]);

  List<Object> get props => throw UnimplementedError();
}

class MedicineEvent extends HomeEvent {
  MedicineEvent() : super([]);

  List<Object> get props => throw UnimplementedError();
}

abstract class HomeState {
  HomeState([List states = const []]) : super();

  @override
  List<Object> get props => [];
}

// Create Intial State..........................................................

class HomeInitial extends HomeState {
  HomeInitial() : super([]);
}

class LoginState extends HomeState {
  ApiStatus state;

  ApiStatus get apiState => state;
  LoginResponse? response;
  String? error;

  LoginState(this.state, {this.response, this.error});
}

class AttemptSaveState extends HomeState {
  ApiStatus state;

  ApiStatus get apiState => state;
  AttemptSaveResponse? response;
  String? error;

  AttemptSaveState(this.state, {this.response, this.error});
}

class LearningState extends HomeState {
  ApiStatus state;

  ApiStatus get apiState => state;
  LearningModel? response;
  String? error;

  LearningState(this.state, {this.response, this.error});
}

class AttemptCreateState extends HomeState {
  ApiStatus state;

  ApiStatus get apiState => state;
  AttemptCreateResponse? response;
  String? error;

  AttemptCreateState(this.state, {this.response, this.error});
}

class SaveResponseState extends HomeState {
  final ApiStatus apiState;
  final dynamic response;
  final String? error;

  SaveResponseState({required this.apiState, this.response, this.error});
}

class QuestionState extends HomeState {
  ApiStatus state;

  ApiStatus get apiState => state;
  QuestionListResponse? response;
  String? error;

  QuestionState(this.state, {this.response, this.error});
}

class LabReportState extends HomeState {
  ApiStatus state;

  ApiStatus get apiState => state;
  LabReportResponse? response;
  String? error;

  LabReportState(this.state, {this.response, this.error});
}

class LearningContentState extends HomeState {
  ApiStatus state;

  ApiStatus get apiState => state;
  LearningContent? response;
  String? error;

  LearningContentState(this.state, {this.response, this.error});
}

class MedicineState extends HomeState {
  ApiStatus state;

  ApiStatus get apiState => state;
  MedicineResponse? response;
  String? error;

  MedicineState(this.state, {this.response, this.error});
}

class AttemptState extends HomeState {
  ApiStatus state;

  ApiStatus get apiState => state;
  AttemptResponse? response;
  String? error;

  AttemptState(this.state, {this.response, this.error});
}

class ReminderState extends HomeState {
  ApiStatus state;

  ApiStatus get apiState => state;
  DailyLogResp? response;
  String? error;

  ReminderState(this.state, {this.response, this.error});
}

class ProfileState extends HomeState {
  ApiStatus state;

  ApiStatus get apiState => state;
  ProfileModel? response;
  String? error;

  ProfileState(this.state, {this.response, this.error});
}

class WeightListState extends HomeState {
  ApiStatus state;

  ApiStatus get apiState => state;
  WeightListResp? response;
  String? error;

  WeightListState(this.state, {this.response, this.error});
}

class WeightSaveState extends HomeState {
  ApiStatus state;

  ApiStatus get apiState => state;
  WeightListResp? response;
  String? error;

  WeightSaveState(this.state, {this.response, this.error});
}

class LogSaveState extends HomeState {
  ApiStatus state;

  ApiStatus get apiState => state;
  DailyLogResp? response;
  String? error;

  LogSaveState(this.state, {this.response, this.error});
}

class ZoneSaveState extends HomeState {
  ApiStatus state;

  ApiStatus get apiState => state;
  ZoneSaveResponse? response;
  String? error;

  ZoneSaveState(this.state, {this.response, this.error});
}


class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final homeRepository = Injector.appInstance.get<HomeRepository>();

  HomeBloc(super.initialState) {
    on<LoginEvent>((event, emit) async {
      try {
        emit(LoginState(ApiStatus.LOADING));
        final response = await homeRepository.login(request: event.request!);
        if (response.token != null) {
          emit(LoginState(ApiStatus.SUCCESS, response: response));
        } else {
          Log.v("ERROR DATA ::: $response");
          emit(LoginState(ApiStatus.ERROR, error: 'Something went wrong'));
        }
      } catch (e) {
        Log.v("ERROR DATA : $e");
        emit(LoginState(ApiStatus.ERROR, error: 'Something went wrong'));
      }
    }, transformer: concurrent());

    on<AttemptSaveEvent>((event, emit) async {
      try {
        emit(AttemptSaveState(ApiStatus.LOADING));
        final response = await homeRepository.getSaveResponse(
          request: event.request,
        );
        if (response.status == true) {
          emit(AttemptSaveState(ApiStatus.SUCCESS, response: response));
        } else {
          Log.v("ERROR DATA ::: $response");
          emit(
            AttemptSaveState(ApiStatus.ERROR, error: 'Something went wrong'),
          );
        }
      } catch (e) {
        Log.v("ERROR DATA : $e");
        emit(AttemptSaveState(ApiStatus.ERROR, error: 'Something went wrong'));
      }
    }, transformer: concurrent());

    on<MyLearningEvent>((event, emit) async {
      try {
        emit(LearningState(ApiStatus.LOADING));
        debugPrint('Bloc received slug: $event');
        final response = await homeRepository.myLearning();
        Log.v("Learning API Response: ${response.toJson()}");

        if (response.status == true) {
          emit(LearningState(ApiStatus.SUCCESS, response: response));
        } else {
          // Use the server's message if available, otherwise fallback
          final errorMessage =
              response.message ?? 'No learning content available';
          Log.v("API returned false status: $errorMessage");
          emit(LearningState(ApiStatus.ERROR, error: errorMessage));
        }
      } catch (e, stackTrace) {
        Log.v("Learning API Error: $e\n$stackTrace");
        emit(
          LearningState(
            ApiStatus.ERROR,
            error:
                e is Exception
                    ? e.toString()
                    : 'Failed to load learning content',
          ),
        );
      }
    }, transformer: concurrent());

    on<AttemptCreateEvent>((event, emit) async {
      try {
        emit(AttemptCreateState(ApiStatus.LOADING));
        debugPrint('Bloc received slug: $event');
        final response = await homeRepository.getAttemptCreate();
        Log.v("Learning API Response: ${response.toJson()}");

        if (response.status == true) {
          emit(AttemptCreateState(ApiStatus.SUCCESS, response: response));
        } else {
          // Use the server's message if available, otherwise fallback
          final errorMessage =
              response.message ?? 'No learning content available';
          Log.v("API returned false status: $errorMessage");
          emit(AttemptCreateState(ApiStatus.ERROR, error: errorMessage));
        }
      } catch (e, stackTrace) {
        Log.v("Learning API Error: $e\n$stackTrace");
        emit(
          AttemptCreateState(
            ApiStatus.ERROR,
            error:
                e is Exception
                    ? e.toString()
                    : 'Failed to load learning content',
          ),
        );
      }
    }, transformer: concurrent());

    on<QuestionEvent>((event, emit) async {
      try {
        emit(QuestionState(ApiStatus.LOADING));
        debugPrint('Bloc received slug: $event');
        final response = await homeRepository.getQuestionList();
        Log.v("Learning API Response: ${response.toJson()}");

        if (response.status == true) {
          emit(QuestionState(ApiStatus.SUCCESS, response: response));
        } else {
          // Use the server's message if available, otherwise fallback
          final errorMessage =
              response.message ?? 'No learning content available';
          Log.v("API returned false status: $errorMessage");
          emit(QuestionState(ApiStatus.ERROR, error: errorMessage));
        }
      } catch (e, stackTrace) {
        Log.v("Learning API Error: $e\n$stackTrace");
        emit(
          QuestionState(
            ApiStatus.ERROR,
            error:
                e is Exception
                    ? e.toString()
                    : 'Failed to load learning content',
          ),
        );
      }
    }, transformer: concurrent());

    on<LabReportEvent>((event, emit) async {
      try {
        emit(LabReportState(ApiStatus.LOADING));
        debugPrint('Bloc received slug: $event');
        final response = await homeRepository.getLabReport();
        Log.v("Learning API Response: ${response.toJson()}");

        if (response.status == true) {
          emit(LabReportState(ApiStatus.SUCCESS, response: response));
        } else {
          // Use the server's message if available, otherwise fallback
          final errorMessage =
              response.message ?? 'No learning content available';
          Log.v("API returned false status: $errorMessage");
          emit(LabReportState(ApiStatus.ERROR, error: errorMessage));
        }
      } catch (e, stackTrace) {
        Log.v("Learning API Error: $e\n$stackTrace");
        emit(
          LabReportState(
            ApiStatus.ERROR,
            error:
                e is Exception
                    ? e.toString()
                    : 'Failed to load learning content',
          ),
        );
      }
    }, transformer: concurrent());

    on<LearningContentEvent>((event, emit) async {
      try {
        emit(LearningContentState(ApiStatus.LOADING));
        debugPrint('Bloc received slug: ${event.slug}'); // Fixed line
        final response = await homeRepository.getLearningContent(
          slug: event.slug,
        );
        Log.v("LearningContent API Response: ${response.toJson()}");

        if (response.status == true) {
          emit(LearningContentState(ApiStatus.SUCCESS, response: response));
        } else {
          final errorMessage =
              response.message ?? 'No LearningContent content available';
          Log.v("API returned false status: $errorMessage");
          emit(LearningContentState(ApiStatus.ERROR, error: errorMessage));
        }
      } catch (e, stackTrace) {
        Log.v("LearningContent API Error: $e\n$stackTrace");
        emit(
          LearningContentState(
            ApiStatus.ERROR,
            error:
                e is Exception
                    ? e.toString()
                    : 'Failed to load learning content',
          ),
        );
      }
    }, transformer: concurrent());


     on<ZoneSaveEvent>((event, emit) async {
      try {
        emit(ZoneSaveState(ApiStatus.LOADING));
        debugPrint('Bloc received slug: ${event.zone}'); 
        final response = await homeRepository.getZoneSave(
          zone: event.zone,
        );
        Log.v("ZoneSave API Response: ${response.toJson()}");

        if (response.status == true) {
          emit(ZoneSaveState(ApiStatus.SUCCESS, response: response));
        } else {
          final errorMessage =
              response.message ?? 'No ZoneSave content available';
          Log.v("API returned false status: $errorMessage");
          emit(ZoneSaveState(ApiStatus.ERROR, error: errorMessage));
        }
      } catch (e, stackTrace) {
        Log.v("ZoneSave API Error: $e\n$stackTrace");
        emit(
          ZoneSaveState(
            ApiStatus.ERROR,
            error:
                e is Exception
                    ? e.toString()
                    : 'Failed to load learning content',
          ),
        );
      }
    }, transformer: concurrent());

    on<ReminderEvent>((event, emit) async {
      try {
        emit(ReminderState(ApiStatus.LOADING));

        final response = await homeRepository.myReminder();
        Log.v("Reminder API Response: ${response.toJson()}");

        if (response.status == true) {
          emit(ReminderState(ApiStatus.SUCCESS, response: response));
        } else {
          // Use the server's message if available, otherwise fallback
          final errorMessage =
              response.message ?? 'No Reminder content available';
          Log.v("API returned false status: $errorMessage");
          emit(ReminderState(ApiStatus.ERROR, error: errorMessage));
        }
      } catch (e, stackTrace) {
        Log.v("Reminder API Error: $e\n$stackTrace");
        emit(
          ReminderState(
            ApiStatus.ERROR,
            error:
                e is Exception
                    ? e.toString()
                    : 'Failed to load learning content',
          ),
        );
      }
    }, transformer: concurrent());

    on<AttemptEvent>((event, emit) async {
      try {
        emit(AttemptState(ApiStatus.LOADING));

        final response = await homeRepository.getAttemptList();
        Log.v("Attempt API Response: ${response.toJson()}");

        if (response.status == true) {
          emit(AttemptState(ApiStatus.SUCCESS, response: response));
        } else {
          // Use the server's message if available, otherwise fallback
          final errorMessage =
              response.message ?? 'No Attempt content available';
          Log.v("API returned false status: $errorMessage");
          emit(AttemptState(ApiStatus.ERROR, error: errorMessage));
        }
      } catch (e, stackTrace) {
        Log.v("Attempt API Error: $e\n$stackTrace");
        emit(
          AttemptState(
            ApiStatus.ERROR,
            error:
                e is Exception
                    ? e.toString()
                    : 'Failed to load learning content',
          ),
        );
      }
    }, transformer: concurrent());

    on<ProfileEvent>((event, emit) async {
      try {
        emit(ProfileState(ApiStatus.LOADING));

        final response = await homeRepository.myProfile();
        Log.v("Profile API Response: ${response.toJson()}");

        if (response.id != null) {
          emit(ProfileState(ApiStatus.SUCCESS, response: response));
          Log.v("Profile Success Response: ${response.toJson()}");
        } else {
          emit(
            ProfileState(ApiStatus.ERROR, error: 'No profile data available'),
          );
        }
      } catch (e, stackTrace) {
        Log.v("Profile API Error: $e\n$stackTrace");
        emit(
          ProfileState(
            ApiStatus.ERROR,
            error:
                e is Exception
                    ? e.toString()
                    : 'Failed to load profile content',
          ),
        );
      }
    }, transformer: concurrent());

    on<WeightSaveEvent>((event, emit) async {
      try {
        emit(WeightSaveState(ApiStatus.LOADING));

        final response = await homeRepository.weightSave(weight: event.weight);
        Log.v("WeightList API Response: ${response.toJson()}");

        if (response.status == true) {
          emit(WeightSaveState(ApiStatus.SUCCESS, response: response));
        } else {
          // Use the server's message if available, otherwise fallback
          final errorMessage =
              response.message ?? 'No WeightList content available';
          Log.v("API returned false status: $errorMessage");
          emit(WeightSaveState(ApiStatus.ERROR, error: errorMessage));
        }
      } catch (e, stackTrace) {
        Log.v("WeightList API Error: $e\n$stackTrace");
        emit(
          WeightSaveState(
            ApiStatus.ERROR,
            error:
                e is Exception
                    ? e.toString()
                    : 'Failed to load learning content',
          ),
        );
      }
    }, transformer: concurrent());

    on<LogSaveEvent>((event, emit) async {
      try {
        emit(LogSaveState(ApiStatus.LOADING));

        final response = await homeRepository.logSave(howMuch: event.howMuch);
        Log.v("WeightList API Response: ${response.toJson()}");

        if (response.status == true) {
          emit(LogSaveState(ApiStatus.SUCCESS, response: response));
        } else {
          // Use the server's message if available, otherwise fallback
          final errorMessage =
              response.message ?? 'No WeightList content available';
          Log.v("API returned false status: $errorMessage");
          emit(LogSaveState(ApiStatus.ERROR, error: errorMessage));
        }
      } catch (e, stackTrace) {
        Log.v("WeightList API Error: $e\n$stackTrace");
        emit(
          LogSaveState(
            ApiStatus.ERROR,
            error:
                e is Exception
                    ? e.toString()
                    : 'Failed to load learning content',
          ),
        );
      }
    }, transformer: concurrent());

    on<WeightListEvent>((event, emit) async {
      try {
        emit(WeightListState(ApiStatus.LOADING));

        final response = await homeRepository.getWeightList();
        Log.v("WeightList API Response: ${response.toJson()}");

        if (response.status == true) {
          emit(WeightListState(ApiStatus.SUCCESS, response: response));
        } else {
          // Use the server's message if available, otherwise fallback
          final errorMessage =
              response.message ?? 'No WeightList content available';
          Log.v("API returned false status: $errorMessage");
          emit(WeightListState(ApiStatus.ERROR, error: errorMessage));
        }
      } catch (e, stackTrace) {
        Log.v("WeightList API Error: $e\n$stackTrace");
        emit(
          WeightListState(
            ApiStatus.ERROR,
            error:
                e is Exception
                    ? e.toString()
                    : 'Failed to load learning content',
          ),
        );
      }
    }, transformer: concurrent());

    on<MedicineEvent>((event, emit) async {
      try {
        emit(MedicineState(ApiStatus.LOADING));

        final response = await homeRepository.getMedicineList();
        Log.v("Medicine API Response: ${response.toJson()}");

        if (response.status == true) {
          emit(MedicineState(ApiStatus.SUCCESS, response: response));
        } else {
          // Use the server's message if available, otherwise fallback
          final errorMessage =
              response.message ?? 'No Medicine content available';
          Log.v("API returned false status: $errorMessage");
          emit(MedicineState(ApiStatus.ERROR, error: errorMessage));
        }
      } catch (e, stackTrace) {
        Log.v("Medicine API Error: $e\n$stackTrace");
        emit(
          MedicineState(
            ApiStatus.ERROR,
            error:
                e is Exception
                    ? e.toString()
                    : 'Failed to load learning content',
          ),
        );
      }
    }, transformer: concurrent());
  }
}
