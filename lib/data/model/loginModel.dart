// ignore_for_file: file_names

class LoginResponse {
  String? token;
  User? user;

  LoginResponse({this.token, this.user});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  String? id;
  String? name;
  String? email;
  String? emailVerifiedAt;
  String? dob;
  String? gender;
  String? patientId;
  String? role;
  String? createdAt;
  String? updatedAt;
  String? educationLevel;
  String? livingPlace;
  String? maritalStatus;
  String? occupation;
  String? familyType;
  String? dietaryPattern;
  String? economicStatus;
  String? monthlyIncome;
  String? age;
  Smoking? smoking;
  AlcoholConsumption? alcoholConsumption;
  ClinicalProfiles? clinicalProfiles;
  ClinicalOutcomes? clinicalOutcomes;
  List<Weights>? weights;
  List<LabRecords>? labRecords;

  User(
      {this.id,
        this.name,
        this.email,
        this.emailVerifiedAt,
        this.dob,
        this.gender,
        this.patientId,
        this.role,
        this.createdAt,
        this.updatedAt,
        this.educationLevel,
        this.livingPlace,
        this.maritalStatus,
        this.occupation,
        this.familyType,
        this.dietaryPattern,
        this.economicStatus,
        this.monthlyIncome,
        this.age,
        this.smoking,
        this.alcoholConsumption,
        this.clinicalProfiles,
        this.clinicalOutcomes,
        this.weights,
        this.labRecords});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    dob = json['dob'];
    gender = json['gender'];
    patientId = json['patient_id'];
    role = json['role'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    educationLevel = json['education_level'];
    livingPlace = json['living_place'];
    maritalStatus = json['marital_status'];
    occupation = json['occupation'];
    familyType = json['family_type'];
    dietaryPattern = json['dietary_pattern'];
    economicStatus = json['economic_status'];
    monthlyIncome = json['monthly_income'];
    age = json['age'];
    smoking =
    json['smoking'] != null ? new Smoking.fromJson(json['smoking']) : null;
    alcoholConsumption = json['alcohol_consumption'] != null
        ? new AlcoholConsumption.fromJson(json['alcohol_consumption'])
        : null;
    clinicalProfiles = json['clinical_profiles'] != null
        ? new ClinicalProfiles.fromJson(json['clinical_profiles'])
        : null;
    clinicalOutcomes = json['clinical_outcomes'] != null
        ? new ClinicalOutcomes.fromJson(json['clinical_outcomes'])
        : null;
    if (json['weights'] != null) {
      weights = <Weights>[];
      json['weights'].forEach((v) {
        weights!.add(new Weights.fromJson(v));
      });
    }
    if (json['lab_records'] != null) {
      labRecords = <LabRecords>[];
      json['lab_records'].forEach((v) {
        labRecords!.add(new LabRecords.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['dob'] = this.dob;
    data['gender'] = this.gender;
    data['patient_id'] = this.patientId;
    data['role'] = this.role;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['education_level'] = this.educationLevel;
    data['living_place'] = this.livingPlace;
    data['marital_status'] = this.maritalStatus;
    data['occupation'] = this.occupation;
    data['family_type'] = this.familyType;
    data['dietary_pattern'] = this.dietaryPattern;
    data['economic_status'] = this.economicStatus;
    data['monthly_income'] = this.monthlyIncome;
    data['age'] = this.age;
    if (this.smoking != null) {
      data['smoking'] = this.smoking!.toJson();
    }
    if (this.alcoholConsumption != null) {
      data['alcohol_consumption'] = this.alcoholConsumption!.toJson();
    }
    if (this.clinicalProfiles != null) {
      data['clinical_profiles'] = this.clinicalProfiles!.toJson();
    }
    if (this.clinicalOutcomes != null) {
      data['clinical_outcomes'] = this.clinicalOutcomes!.toJson();
    }
    if (this.weights != null) {
      data['weights'] = this.weights!.map((v) => v.toJson()).toList();
    }
    if (this.labRecords != null) {
      data['lab_records'] = this.labRecords!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Smoking {
  String? id;
  String? userId;
  String? smokingStatus;
  String? durationOfSmoking;
  String? levelOfSmoking;
  String? createdAt;
  String? updatedAt;

  Smoking(
      {this.id,
        this.userId,
        this.smokingStatus,
        this.durationOfSmoking,
        this.levelOfSmoking,
        this.createdAt,
        this.updatedAt});

  Smoking.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    smokingStatus = json['smoking_status'];
    durationOfSmoking = json['duration_of_smoking'];
    levelOfSmoking = json['level_of_smoking'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['smoking_status'] = this.smokingStatus;
    data['duration_of_smoking'] = this.durationOfSmoking;
    data['level_of_smoking'] = this.levelOfSmoking;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class AlcoholConsumption {
  String? id;
  String? userId;
  String? alcoholStatus;
  String? frequencyOfConsumption;
  String? durationOfConsumption;
  String? createdAt;
  String? updatedAt;

  AlcoholConsumption(
      {this.id,
        this.userId,
        this.alcoholStatus,
        this.frequencyOfConsumption,
        this.durationOfConsumption,
        this.createdAt,
        this.updatedAt});

  AlcoholConsumption.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    alcoholStatus = json['alcohol_status'];
    frequencyOfConsumption = json['frequency_of_consumption'];
    durationOfConsumption = json['duration_of_consumption'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['alcohol_status'] = this.alcoholStatus;
    data['frequency_of_consumption'] = this.frequencyOfConsumption;
    data['duration_of_consumption'] = this.durationOfConsumption;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class ClinicalProfiles {
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

  ClinicalProfiles(
      {this.id,
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
        this.updatedAt});

  ClinicalProfiles.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    heartFailureType = json['heart_failure_type'];
    coMorbidities = json['co_morbidities'];
    familyHistoryHeartFailure = json['family_history_heart_failure'];
    durationOfIllness = json['duration_of_illness'];
    medicationStatus = json['medication_status'];
    medicationTypes = json['medication_types'];
    medicationDuration = json['medication_duration'];
    nyhaClass = json['nyha_class'];
    killipClassification = json['killip_classification'];
    lvef = json['lvef'];
    unplannedHospitalVisits = json['unplanned_hospital_visits'];
    unplannedHospitalAdmissions = json['unplanned_hospital_admissions'];
    monthlyHealthExpense = json['monthly_health_expense'];
    bmi = json['bmi'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['heart_failure_type'] = this.heartFailureType;
    data['co_morbidities'] = this.coMorbidities;
    data['family_history_heart_failure'] = this.familyHistoryHeartFailure;
    data['duration_of_illness'] = this.durationOfIllness;
    data['medication_status'] = this.medicationStatus;
    data['medication_types'] = this.medicationTypes;
    data['medication_duration'] = this.medicationDuration;
    data['nyha_class'] = this.nyhaClass;
    data['killip_classification'] = this.killipClassification;
    data['lvef'] = this.lvef;
    data['unplanned_hospital_visits'] = this.unplannedHospitalVisits;
    data['unplanned_hospital_admissions'] = this.unplannedHospitalAdmissions;
    data['monthly_health_expense'] = this.monthlyHealthExpense;
    data['bmi'] = this.bmi;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class ClinicalOutcomes {
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

  ClinicalOutcomes(
      {this.id,
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
        this.updatedAt});

  ClinicalOutcomes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    haemoglobin = json['haemoglobin'];
    ferritin = json['ferritin'];
    tibc = json['tibc'];
    tsat = json['tsat'];
    mcv = json['mcv'];
    mchc = json['mchc'];
    hsCrp = json['hs_crp'];
    ntProBnp = json['nt_pro_bnp'];
    lipidProfile = json['lipid_profile'];
    bloodSugar = json['blood_sugar'];
    vitalSigns = json['vital_signs'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['haemoglobin'] = this.haemoglobin;
    data['ferritin'] = this.ferritin;
    data['tibc'] = this.tibc;
    data['tsat'] = this.tsat;
    data['mcv'] = this.mcv;
    data['mchc'] = this.mchc;
    data['hs_crp'] = this.hsCrp;
    data['nt_pro_bnp'] = this.ntProBnp;
    data['lipid_profile'] = this.lipidProfile;
    data['blood_sugar'] = this.bloodSugar;
    data['vital_signs'] = this.vitalSigns;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Weights {
  String? id;
  String? userId;
  String? weight;
  String? measuredAt;
  String? measuredIn;
  String? createdAt;
  String? updatedAt;

  Weights(
      {this.id,
        this.userId,
        this.weight,
        this.measuredAt,
        this.measuredIn,
        this.createdAt,
        this.updatedAt});

  Weights.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    weight = json['weight'];
    measuredAt = json['measured_at'];
    measuredIn = json['measured_in'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['weight'] = this.weight;
    data['measured_at'] = this.measuredAt;
    data['measured_in'] = this.measuredIn;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class LabRecords {
  String? id;
  String? userId;
  String? hemoglobin;
  String? ferritin;
  String? tibc;
  String? isat;
  String? mcv;
  String? mchc;
  String? hsCrp;
  String? ntProBnp;
  String? cholesterol;
  String? hdl;
  String? ldl;
  String? triglycerides;
  String? bloodSugar;
  String? pulseRate;
  String? bloodPressure;
  String? weight;
  String? date;
  String? createdAt;
  String? updatedAt;

  LabRecords(
      {this.id,
        this.userId,
        this.hemoglobin,
        this.ferritin,
        this.tibc,
        this.isat,
        this.mcv,
        this.mchc,
        this.hsCrp,
        this.ntProBnp,
        this.cholesterol,
        this.hdl,
        this.ldl,
        this.triglycerides,
        this.bloodSugar,
        this.pulseRate,
        this.bloodPressure,
        this.weight,
        this.date,
        this.createdAt,
        this.updatedAt});

  LabRecords.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    hemoglobin = json['hemoglobin'];
    ferritin = json['ferritin'];
    tibc = json['tibc'];
    isat = json['isat'];
    mcv = json['mcv'];
    mchc = json['mchc'];
    hsCrp = json['hs_crp'];
    ntProBnp = json['nt_pro_bnp'];
    cholesterol = json['cholesterol'];
    hdl = json['hdl'];
    ldl = json['ldl'];
    triglycerides = json['triglycerides'];
    bloodSugar = json['blood_sugar'];
    pulseRate = json['pulse_rate'];
    bloodPressure = json['blood_pressure'];
    weight = json['weight'];
    date = json['date'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['hemoglobin'] = this.hemoglobin;
    data['ferritin'] = this.ferritin;
    data['tibc'] = this.tibc;
    data['isat'] = this.isat;
    data['mcv'] = this.mcv;
    data['mchc'] = this.mchc;
    data['hs_crp'] = this.hsCrp;
    data['nt_pro_bnp'] = this.ntProBnp;
    data['cholesterol'] = this.cholesterol;
    data['hdl'] = this.hdl;
    data['ldl'] = this.ldl;
    data['triglycerides'] = this.triglycerides;
    data['blood_sugar'] = this.bloodSugar;
    data['pulse_rate'] = this.pulseRate;
    data['blood_pressure'] = this.bloodPressure;
    data['weight'] = this.weight;
    data['date'] = this.date;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}