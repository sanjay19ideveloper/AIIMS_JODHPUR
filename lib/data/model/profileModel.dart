import 'dart:convert';

class ProfileModel {
  String? id;
  String? name;
  String? email;
  String? emailVerifiedAt;
  String? createdAt;
  String? updatedAt;
  String? dob;
  String? gender;
  String? patientId;
  String? role;
  String? educationLevel;
  String? livingPlace;
  String? maritalStatus;
  String? occupation;
  String? familyType;
  String? dietaryPattern;
  String? economicStatus;
  String? monthlyIncome;
  dynamic deletedAt;
  int? canWebLogin;
  int? canAppLogin;
  int? status;
  Smoking? smoking;
  AlcoholConsumption? alcoholConsumption;
  ClinicalProfile? clinicalProfile;
  ClinicalOutcome? clinicalOutcome;

  ProfileModel({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.dob,
    this.gender,
    this.patientId,
    this.role,
    this.educationLevel,
    this.livingPlace,
    this.maritalStatus,
    this.occupation,
    this.familyType,
    this.dietaryPattern,
    this.economicStatus,
    this.monthlyIncome,
    this.deletedAt,
    this.canWebLogin,
    this.canAppLogin,
    this.status,
    this.smoking,
    this.alcoholConsumption,
    this.clinicalProfile,
    this.clinicalOutcome,
  });

  factory ProfileModel.fromRawJson(String str) =>
      ProfileModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    id: json["id"]?.toString(),
    name: json["name"]?.toString(),
    email: json["email"]?.toString(),
    emailVerifiedAt: json["email_verified_at"]?.toString(),
    createdAt: json["created_at"]?.toString(),
    updatedAt: json["updated_at"]?.toString(),
    dob: json["dob"]?.toString(),
    gender: json["gender"]?.toString(),
    patientId: json["patient_id"]?.toString(),
    role: json["role"]?.toString(),
    educationLevel: json["education_level"]?.toString(),
    livingPlace: json["living_place"]?.toString(),
    maritalStatus: json["marital_status"]?.toString(),
    occupation: json["occupation"]?.toString(),
    familyType: json["family_type"]?.toString(),
    dietaryPattern: json["dietary_pattern"]?.toString(),
    economicStatus: json["economic_status"]?.toString(),
    monthlyIncome: json["monthly_income"]?.toString(),
    deletedAt: json["deleted_at"],
    canWebLogin:
        json["can_web_login"] is int
            ? json["can_web_login"]
            : int.tryParse(json["can_web_login"]?.toString() ?? ''),
    canAppLogin:
        json["can_app_login"] is int
            ? json["can_app_login"]
            : int.tryParse(json["can_app_login"]?.toString() ?? ''),
    status:
        json["status"] is int
            ? json["status"]
            : int.tryParse(json["status"]?.toString() ?? ''),
    smoking: json["smoking"] == null ? null : Smoking.fromJson(json["smoking"]),
    alcoholConsumption:
        json["alcohol_consumption"] == null
            ? null
            : AlcoholConsumption.fromJson(json["alcohol_consumption"]),
    clinicalProfile:
        json["clinical_profile"] == null
            ? null
            : ClinicalProfile.fromJson(json["clinical_profile"]),
    clinicalOutcome:
        json["clinical_outcome"] == null
            ? null
            : ClinicalOutcome.fromJson(json["clinical_outcome"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "email_verified_at": emailVerifiedAt,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "dob": dob,
    "gender": gender,
    "patient_id": patientId,
    "role": role,
    "education_level": educationLevel,
    "living_place": livingPlace,
    "marital_status": maritalStatus,
    "occupation": occupation,
    "family_type": familyType,
    "dietary_pattern": dietaryPattern,
    "economic_status": economicStatus,
    "monthly_income": monthlyIncome,
    "deleted_at": deletedAt,
    "can_web_login": canWebLogin,
    "can_app_login": canAppLogin,
    "status": status,
    "smoking": smoking?.toJson(),
    "alcohol_consumption": alcoholConsumption?.toJson(),
    "clinical_profile": clinicalProfile?.toJson(),
    "clinical_outcome": clinicalOutcome?.toJson(),
  };
}

class AlcoholConsumption {
  String? id;
  String? userId;
  String? alcoholStatus;
  String? frequencyOfConsumption;
  String? durationOfConsumption;
  String? createdAt;
  String? updatedAt;

  AlcoholConsumption({
    this.id,
    this.userId,
    this.alcoholStatus,
    this.frequencyOfConsumption,
    this.durationOfConsumption,
    this.createdAt,
    this.updatedAt,
  });

  factory AlcoholConsumption.fromRawJson(String str) =>
      AlcoholConsumption.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AlcoholConsumption.fromJson(Map<String, dynamic> json) =>
      AlcoholConsumption(
        id: json["id"]?.toString(),
        userId: json["user_id"]?.toString(),
        alcoholStatus: json["alcohol_status"]?.toString(),
        frequencyOfConsumption: json["frequency_of_consumption"]?.toString(),
        durationOfConsumption: json["duration_of_consumption"]?.toString(),
        createdAt: json["created_at"]?.toString(),
        updatedAt: json["updated_at"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "alcohol_status": alcoholStatus,
    "frequency_of_consumption": frequencyOfConsumption,
    "duration_of_consumption": durationOfConsumption,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class ClinicalOutcome {
  String? id;
  String? userId;
  String? haemoglobin;
  String? ferritin;
  String? tibc;
  String? tsat;
  String? mcv;
  String? mchc;
  String? hsCrp;
  String? ntProBnp;
  String? lipidProfile;
  String? bloodSugar;
  String? vitalSigns;
  String? createdAt;
  String? updatedAt;

  ClinicalOutcome({
    this.id,
    this.userId,
    this.haemoglobin,
    this.ferritin,
    this.tibc,
    this.tsat,
    this.mcv,
    this.mchc,
    this.hsCrp,
    this.ntProBnp,
    this.lipidProfile,
    this.bloodSugar,
    this.vitalSigns,
    this.createdAt,
    this.updatedAt,
  });

  factory ClinicalOutcome.fromRawJson(String str) =>
      ClinicalOutcome.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ClinicalOutcome.fromJson(Map<String, dynamic> json) =>
      ClinicalOutcome(
        id: json["id"]?.toString(),
        userId: json["user_id"]?.toString(),
        haemoglobin: json["haemoglobin"]?.toString(),
        ferritin: json["ferritin"]?.toString(),
        tibc: json["tibc"]?.toString(),
        tsat: json["tsat"]?.toString(),
        mcv: json["mcv"]?.toString(),
        mchc: json["mchc"]?.toString(),
        hsCrp: json["hs_crp"]?.toString(),
        ntProBnp: json["nt_pro_bnp"]?.toString(),
        lipidProfile: json["lipid_profile"]?.toString(),
        bloodSugar: json["blood_sugar"]?.toString(),
        vitalSigns: json["vital_signs"]?.toString(),
        createdAt: json["created_at"]?.toString(),
        updatedAt: json["updated_at"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "haemoglobin": haemoglobin,
    "ferritin": ferritin,
    "tibc": tibc,
    "tsat": tsat,
    "mcv": mcv,
    "mchc": mchc,
    "hs_crp": hsCrp,
    "nt_pro_bnp": ntProBnp,
    "lipid_profile": lipidProfile,
    "blood_sugar": bloodSugar,
    "vital_signs": vitalSigns,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class ClinicalProfile {
  String? id;
  String? userId;
  String? heartFailureType;
  String? coMorbidities;
  int? familyHistoryHeartFailure;
  String? durationOfIllness;
  int? medicationStatus;
  String? medicationTypes;
  String? medicationDuration;
  String? nyhaClass;
  String? killipClassification;
  String? lvef;
  int? unplannedHospitalVisits;
  int? unplannedHospitalAdmissions;
  String? monthlyHealthExpense;
  String? bmi;
  String? createdAt;
  String? updatedAt;

  ClinicalProfile({
    this.id,
    this.userId,
    this.heartFailureType,
    this.coMorbidities,
    this.familyHistoryHeartFailure,
    this.durationOfIllness,
    this.medicationStatus,
    this.medicationTypes,
    this.medicationDuration,
    this.nyhaClass,
    this.killipClassification,
    this.lvef,
    this.unplannedHospitalVisits,
    this.unplannedHospitalAdmissions,
    this.monthlyHealthExpense,
    this.bmi,
    this.createdAt,
    this.updatedAt,
  });

  factory ClinicalProfile.fromRawJson(String str) =>
      ClinicalProfile.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ClinicalProfile.fromJson(Map<String, dynamic> json) =>
      ClinicalProfile(
        id: json["id"]?.toString(),
        userId: json["user_id"]?.toString(),
        heartFailureType: json["heart_failure_type"]?.toString(),
        coMorbidities: json["co_morbidities"]?.toString(),
        familyHistoryHeartFailure:
            json["family_history_heart_failure"] is int
                ? json["family_history_heart_failure"]
                : int.tryParse(
                  json["family_history_heart_failure"]?.toString() ?? '',
                ),
        durationOfIllness: json["duration_of_illness"]?.toString(),
        medicationStatus:
            json["medication_status"] is int
                ? json["medication_status"]
                : int.tryParse(json["medication_status"]?.toString() ?? ''),
        medicationTypes: json["medication_types"]?.toString(),
        medicationDuration: json["medication_duration"]?.toString(),
        nyhaClass: json["nyha_class"]?.toString(),
        killipClassification: json["killip_classification"]?.toString(),
        lvef: json["lvef"]?.toString(),
        unplannedHospitalVisits:
            json["unplanned_hospital_visits"] is int
                ? json["unplanned_hospital_visits"]
                : int.tryParse(
                  json["unplanned_hospital_visits"]?.toString() ?? '',
                ),
        unplannedHospitalAdmissions:
            json["unplanned_hospital_admissions"] is int
                ? json["unplanned_hospital_admissions"]
                : int.tryParse(
                  json["unplanned_hospital_admissions"]?.toString() ?? '',
                ),
        monthlyHealthExpense: json["monthly_health_expense"]?.toString(),
        bmi: json["bmi"]?.toString(),
        createdAt: json["created_at"]?.toString(),
        updatedAt: json["updated_at"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "heart_failure_type": heartFailureType,
    "co_morbidities": coMorbidities,
    "family_history_heart_failure": familyHistoryHeartFailure,
    "duration_of_illness": durationOfIllness,
    "medication_status": medicationStatus,
    "medication_types": medicationTypes,
    "medication_duration": medicationDuration,
    "nyha_class": nyhaClass,
    "killip_classification": killipClassification,
    "lvef": lvef,
    "unplanned_hospital_visits": unplannedHospitalVisits,
    "unplanned_hospital_admissions": unplannedHospitalAdmissions,
    "monthly_health_expense": monthlyHealthExpense,
    "bmi": bmi,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class Smoking {
  String? id;
  String? userId;
  String? smokingStatus;
  String? durationOfSmoking;
  String? levelOfSmoking;
  String? createdAt;
  String? updatedAt;

  Smoking({
    this.id,
    this.userId,
    this.smokingStatus,
    this.durationOfSmoking,
    this.levelOfSmoking,
    this.createdAt,
    this.updatedAt,
  });

  factory Smoking.fromRawJson(String str) => Smoking.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Smoking.fromJson(Map<String, dynamic> json) => Smoking(
    id: json["id"]?.toString(),
    userId: json["user_id"]?.toString(),
    smokingStatus: json["smoking_status"]?.toString(),
    durationOfSmoking: json["duration_of_smoking"]?.toString(),
    levelOfSmoking: json["level_of_smoking"]?.toString(),
    createdAt: json["created_at"]?.toString(),
    updatedAt: json["updated_at"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "smoking_status": smokingStatus,
    "duration_of_smoking": durationOfSmoking,
    "level_of_smoking": levelOfSmoking,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
