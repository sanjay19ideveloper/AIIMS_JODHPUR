import 'dart:convert';

class ProfileModel {
    String? id;
    String? name;
    String? email;
    dynamic emailVerifiedAt;
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
    String? dailyLiquidIntakeLimit;
    String? liquidIntakeLimitMeasurement;
    dynamic deletedAt;
    int? canWebLogin;
    int? canAppLogin;
    int? status;
    dynamic customFields;
    dynamic avatarUrl;
    String? age;
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
        this.dailyLiquidIntakeLimit,
        this.liquidIntakeLimitMeasurement,
        this.deletedAt,
        this.canWebLogin,
        this.canAppLogin,
        this.status,
        this.customFields,
        this.avatarUrl,
        this.age,
        this.smoking,
        this.alcoholConsumption,
        this.clinicalProfile,
        this.clinicalOutcome,
    });

    factory ProfileModel.fromRawJson(String str) => ProfileModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        emailVerifiedAt: json["email_verified_at"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        dob: json["dob"],
        gender: json["gender"],
        patientId: json["patient_id"],
        role: json["role"],
        educationLevel: json["education_level"],
        livingPlace: json["living_place"],
        maritalStatus: json["marital_status"],
        occupation: json["occupation"],
        familyType: json["family_type"],
        dietaryPattern: json["dietary_pattern"],
        economicStatus: json["economic_status"],
        monthlyIncome: json["monthly_income"],
        dailyLiquidIntakeLimit: json["daily_liquid_intake_limit"],
        liquidIntakeLimitMeasurement: json["liquid_intake_limit_measurement"],
        deletedAt: json["deleted_at"],
        canWebLogin: json["can_web_login"],
        canAppLogin: json["can_app_login"],
        status: json["status"],
        customFields: json["custom_fields"],
        avatarUrl: json["avatar_url"],
        age: json["age"],
        smoking: json["smoking"] == null ? null : Smoking.fromJson(json["smoking"]),
        alcoholConsumption: json["alcohol_consumption"] == null ? null : AlcoholConsumption.fromJson(json["alcohol_consumption"]),
        clinicalProfile: json["clinical_profile"] == null ? null : ClinicalProfile.fromJson(json["clinical_profile"]),
        clinicalOutcome: json["clinical_outcome"] == null ? null : ClinicalOutcome.fromJson(json["clinical_outcome"]),
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
        "daily_liquid_intake_limit": dailyLiquidIntakeLimit,
        "liquid_intake_limit_measurement": liquidIntakeLimitMeasurement,
        "deleted_at": deletedAt,
        "can_web_login": canWebLogin,
        "can_app_login": canAppLogin,
        "status": status,
        "custom_fields": customFields,
        "avatar_url": avatarUrl,
        "age": age,
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

    factory AlcoholConsumption.fromRawJson(String str) => AlcoholConsumption.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory AlcoholConsumption.fromJson(Map<String, dynamic> json) => AlcoholConsumption(
        id: json["id"],
        userId: json["user_id"],
        alcoholStatus: json["alcohol_status"],
        frequencyOfConsumption: json["frequency_of_consumption"],
        durationOfConsumption: json["duration_of_consumption"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
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
    dynamic hbalc;
    String? urea;
    String? creatinine;
    String? sodium;
    String? potassium;
    String? chloride;
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
        this.hbalc,
        this.urea,
        this.creatinine,
        this.sodium,
        this.potassium,
        this.chloride,
        this.createdAt,
        this.updatedAt,
    });

    factory ClinicalOutcome.fromRawJson(String str) => ClinicalOutcome.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ClinicalOutcome.fromJson(Map<String, dynamic> json) => ClinicalOutcome(
        id: json["id"],
        userId: json["user_id"],
        haemoglobin: json["haemoglobin"],
        ferritin: json["ferritin"],
        tibc: json["tibc"],
        tsat: json["tsat"],
        mcv: json["mcv"],
        mchc: json["mchc"],
        hsCrp: json["hs_crp"],
        ntProBnp: json["nt_pro_bnp"],
        lipidProfile: json["lipid_profile"],
        bloodSugar: json["blood_sugar"],
        vitalSigns: json["vital_signs"],
        hbalc: json["hbalc"],
        urea: json["urea"],
        creatinine: json["creatinine"],
        sodium: json["sodium"],
        potassium: json["potassium"],
        chloride: json["chloride"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
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
        "hbalc": hbalc,
        "urea": urea,
        "creatinine": creatinine,
        "sodium": sodium,
        "potassium": potassium,
        "chloride": chloride,
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

    factory ClinicalProfile.fromRawJson(String str) => ClinicalProfile.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ClinicalProfile.fromJson(Map<String, dynamic> json) => ClinicalProfile(
        id: json["id"],
        userId: json["user_id"],
        heartFailureType: json["heart_failure_type"],
        coMorbidities: json["co_morbidities"],
        familyHistoryHeartFailure: json["family_history_heart_failure"],
        durationOfIllness: json["duration_of_illness"],
        medicationStatus: json["medication_status"],
        medicationTypes: json["medication_types"],
        medicationDuration: json["medication_duration"],
        nyhaClass: json["nyha_class"],
        killipClassification: json["killip_classification"],
        lvef: json["lvef"],
        unplannedHospitalVisits: json["unplanned_hospital_visits"],
        unplannedHospitalAdmissions: json["unplanned_hospital_admissions"],
        monthlyHealthExpense: json["monthly_health_expense"],
        bmi: json["bmi"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
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
        id: json["id"],
        userId: json["user_id"],
        smokingStatus: json["smoking_status"],
        durationOfSmoking: json["duration_of_smoking"],
        levelOfSmoking: json["level_of_smoking"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
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
