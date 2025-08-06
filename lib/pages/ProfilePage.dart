import 'dart:developer';
import 'package:aiims_heartcare/blocs/bloc_manager.dart';
import 'package:aiims_heartcare/blocs/home_bloc.dart';
import 'package:aiims_heartcare/data/api/api_service.dart';
import 'package:aiims_heartcare/data/model/profileModel.dart';
import 'package:aiims_heartcare/utils/loading.dart';
import 'package:aiims_heartcare/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isLoading = false;
  ProfileModel? user;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  void fetchProfileData() {
    BlocProvider.of<HomeBloc>(context).add(ProfileEvent());
  }

  void handleProfileResponse(ProfileState state) {
    switch (state.apiState) {
      case ApiStatus.LOADING:
        Log.v("Loading profile...");
        setState(() {
          _isLoading = true;
        });
        break;
      case ApiStatus.SUCCESS:
        Log.v("Success profile data: ${state.response?.toJson()}");
        setState(() {
          _isLoading = false;
          user = state.response;
          log('Profile data is $user');
        });
        break;
      case ApiStatus.ERROR:
        Log.v("Error: ${state.error}");
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error ?? 'Failed to load profile')),
        );
        break;
      case ApiStatus.INITIAL:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocManager(
      initState: (BuildContext context) {},
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is ProfileState) {
            handleProfileResponse(state);
          }
        },
        child: Scaffold(
          body: ScreenWithLoader(
            isLoading: _isLoading,
            body: Stack(
              children: [
                // Fixed AppBar
                _buildFixedAppBar(context),

                // Scrollable Content
                Positioned(
                  top: 180, // Height of the app bar
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 16,
                          ), // Extra space below app bar
                          _buildInfoCard(),
                          const SizedBox(height: 16),
                          _buildSmokingAlcoholCard(),
                          const SizedBox(height: 16),
                          _buildClinicalProfileCard(),
                          const SizedBox(height: 16),
                          _buildClinicalOutcomeCard(),
                          const SizedBox(height: 16), // Extra space at bottom
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFixedAppBar(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Material(
        elevation: 4,
        color: const Color(0xFF0D3B3F),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.pexels.com/photos/8943324/pexels-photo-8943324.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
              fit: BoxFit.cover,
              color: const Color(0xFF0D3B3F).withOpacity(0.7),
              colorBlendMode: BlendMode.overlay,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 38,
                        backgroundImage: NetworkImage(
                          'https://ui-avatars.com/api/?name=${user?.name ?? 'User'}&background=0D3B3F&color=fff&size=200',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'User',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (user?.email != null)
                          Text(
                            user?.email ?? 'user@example.com',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Back button at top
            // Positioned(
            //   top: MediaQuery.of(context).padding.top,
            //   left: 0,
            //   child: IconButton(
            //     icon: const Icon(Icons.arrow_back, color: Colors.white),
            //     onPressed: () => Navigator.of(context).pop(),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Socio-demographic Variables',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D3B3F),
              ),
            ),
            const Divider(),
            _buildInfoRow(Icons.email, 'Email', user?.email ?? 'N/A'),
            if (user?.dob != null)
              _buildInfoRow(
                Icons.cake,
                'Date of Birth',
                DateTime.tryParse(user?.dob ?? '') != null
                    ? DateFormat(
                      'yyyy-MM-dd',
                    ).format(DateTime.parse(user?.dob ?? ''))
                    : user?.dob ?? 'N/A',
              ),
            if (user?.gender != null)
              _buildInfoRow(
                Icons.wc,
                'Gender',
                _capitalizeFirstLetter(user?.gender ?? ''),
              ),
            if (user?.patientId != null)
              _buildInfoRow(Icons.badge, 'Patient ID', user?.patientId ?? ''),
            if (user?.educationLevel != null)
              _buildInfoRow(
                Icons.school,
                'Education',
                _capitalizeFirstLetter(user?.educationLevel ?? ''),
              ),
            if (user?.livingPlace != null)
              _buildInfoRow(
                Icons.home,
                'Living Place',
                _capitalizeFirstLetter(user?.livingPlace ?? ''),
              ),
            if (user?.maritalStatus != null)
              _buildInfoRow(
                Icons.favorite,
                'Marital Status',
                _capitalizeFirstLetter(user?.maritalStatus ?? ''),
              ),
            if (user?.occupation != null)
              _buildInfoRow(
                Icons.work,
                'Occupation',
                _capitalizeFirstLetter(user?.occupation ?? ''),
              ),
            if (user?.familyType != null)
              _buildInfoRow(
                Icons.family_restroom,
                'Family Type',
                _capitalizeFirstLetter(user?.familyType ?? ''),
              ),
            if (user?.monthlyIncome != null)
              _buildInfoRow(
                Icons.attach_money,
                'Monthly Income',
                '₹${user?.monthlyIncome}',
              ),
            if (user?.economicStatus != null)
              _buildInfoRow(
                Icons.account_balance,
                'Economic Status',
                _capitalizeFirstLetter(user?.economicStatus ?? ''),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmokingAlcoholCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Smoking & Alcohol',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D3B3F),
              ),
            ),
            const Divider(),
            const Text(
              'Smoking',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D3B3F),
              ),
            ),
            const SizedBox(height: 8),
            if (user?.smoking != null) ...[
              if (user?.smoking?.smokingStatus != null)
                _buildInfoRow(
                  Icons.smoking_rooms,
                  'Status',
                  _capitalizeFirstLetter(user?.smoking?.smokingStatus ?? ''),
                ),
              if (user?.smoking?.durationOfSmoking != null)
                _buildInfoRow(
                  Icons.timelapse,
                  'Duration',
                  user?.smoking?.durationOfSmoking ?? '',
                ),
              if (user?.smoking?.levelOfSmoking != null)
                _buildInfoRow(
                  Icons.bar_chart,
                  'Level',
                  _capitalizeFirstLetter(user?.smoking?.levelOfSmoking ?? ''),
                ),
            ] else
              _buildInfoRow(Icons.smoking_rooms, 'Status', 'No smoking data'),
            const SizedBox(height: 16),
            const Text(
              'Alcohol Consumption',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D3B3F),
              ),
            ),
            const SizedBox(height: 8),
            if (user?.alcoholConsumption != null) ...[
              if (user?.alcoholConsumption?.alcoholStatus != null)
                _buildInfoRow(
                  Icons.local_bar,
                  'Status',
                  _capitalizeFirstLetter(
                    user?.alcoholConsumption?.alcoholStatus ?? '',
                  ),
                ),
              if (user?.alcoholConsumption?.durationOfConsumption != null)
                _buildInfoRow(
                  Icons.timelapse,
                  'Duration',
                  user?.alcoholConsumption?.durationOfConsumption ?? '',
                ),
              if (user?.alcoholConsumption?.frequencyOfConsumption != null)
                _buildInfoRow(
                  Icons.bar_chart,
                  'Frequency',
                  _capitalizeFirstLetter(
                    user?.alcoholConsumption?.frequencyOfConsumption ?? '',
                  ),
                ),
            ] else
              _buildInfoRow(Icons.local_bar, 'Status', 'No alcohol data'),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicalProfileCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Clinical Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D3B3F),
              ),
            ),
            const Divider(),
            if (user?.clinicalProfile != null) ...[
              if (user?.clinicalProfile?.heartFailureType != null)
                _buildInfoRow(
                  Icons.favorite_border,
                  'Heart Failure Type',
                  _capitalizeFirstLetter(
                    user?.clinicalProfile?.heartFailureType ?? '',
                  ),
                ),
              if (user?.clinicalProfile?.coMorbidities != null)
                _buildInfoRow(
                  Icons.local_hospital,
                  'Co-morbidities',
                  user?.clinicalProfile?.coMorbidities ?? '',
                ),
              if (user?.clinicalProfile?.familyHistoryHeartFailure != null)
                _buildInfoRow(
                  Icons.group,
                  'Family History of Heart Failure',
                  user?.clinicalProfile?.familyHistoryHeartFailure == 1
                      ? 'Yes'
                      : 'No',
                ),
              if (user?.clinicalProfile?.durationOfIllness != null)
                _buildInfoRow(
                  Icons.timelapse,
                  'Duration of Illness',
                  user?.clinicalProfile?.durationOfIllness ?? '',
                ),
              if (user?.clinicalProfile?.medicationStatus != null)
                _buildInfoRow(
                  Icons.medical_services,
                  'Medication Status',
                  user?.clinicalProfile?.medicationStatus == 1 ? 'On' : 'Off',
                ),
              if (user?.clinicalProfile?.medicationTypes != null)
                _buildInfoRow(
                  Icons.medication,
                  'Medication Types',
                  user?.clinicalProfile?.medicationTypes ?? '',
                ),
              if (user?.clinicalProfile?.medicationDuration != null)
                _buildInfoRow(
                  Icons.schedule,
                  'Medication Duration',
                  user?.clinicalProfile?.medicationDuration ?? '',
                ),
              if (user?.clinicalProfile?.nyhaClass != null)
                _buildInfoRow(
                  Icons.assessment,
                  'NYHA Class',
                  user?.clinicalProfile?.nyhaClass ?? '',
                ),
              if (user?.clinicalProfile?.killipClassification != null)
                _buildInfoRow(
                  Icons.category,
                  'Killip Classification',
                  user?.clinicalProfile?.killipClassification ?? '',
                ),
              if (user?.clinicalProfile?.lvef != null)
                _buildInfoRow(
                  Icons.monitor_heart,
                  'LVEF',
                  user?.clinicalProfile?.lvef ?? '',
                ),
              if (user?.clinicalProfile?.unplannedHospitalVisits != null)
                _buildInfoRow(
                  Icons.local_hospital,
                  'Unplanned Hospital Visits',
                  user?.clinicalProfile?.unplannedHospitalVisits?.toString() ??
                      '',
                ),
              if (user?.clinicalProfile?.unplannedHospitalAdmissions != null)
                _buildInfoRow(
                  Icons.local_hospital,
                  'Unplanned Hospital Admissions',
                  user?.clinicalProfile?.unplannedHospitalAdmissions
                          ?.toString() ??
                      '',
                ),
              if (user?.clinicalProfile?.monthlyHealthExpense != null)
                _buildInfoRow(
                  Icons.attach_money,
                  'Monthly Health Expense',
                  '₹${user?.clinicalProfile?.monthlyHealthExpense}',
                ),
              if (user?.clinicalProfile?.bmi != null)
                _buildInfoRow(
                  Icons.fitness_center,
                  'BMI',
                  user?.clinicalProfile?.bmi ?? '',
                ),
            ] else
              _buildInfoRow(
                Icons.local_hospital,
                'Status',
                'No clinical profile data',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicalOutcomeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Clinical Outcome',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D3B3F),
              ),
            ),
            const Divider(),
            if (user?.clinicalOutcome != null) ...[
              if (user?.clinicalOutcome?.haemoglobin != null)
                _buildInfoRow(
                  Icons.bloodtype,
                  'Haemoglobin',
                  user?.clinicalOutcome?.haemoglobin ?? '',
                ),
              if (user?.clinicalOutcome?.ferritin != null)
                _buildInfoRow(
                  Icons.science,
                  'Ferritin',
                  user?.clinicalOutcome?.ferritin ?? '',
                ),
              if (user?.clinicalOutcome?.tibc != null)
                _buildInfoRow(
                  Icons.science,
                  'TIBC',
                  user?.clinicalOutcome?.tibc ?? '',
                ),
              if (user?.clinicalOutcome?.tsat != null)
                _buildInfoRow(
                  Icons.science,
                  'TSAT',
                  user?.clinicalOutcome?.tsat ?? '',
                ),
              if (user?.clinicalOutcome?.mcv != null)
                _buildInfoRow(
                  Icons.science,
                  'MCV',
                  user?.clinicalOutcome?.mcv ?? '',
                ),
              if (user?.clinicalOutcome?.mchc != null)
                _buildInfoRow(
                  Icons.science,
                  'MCHC',
                  user?.clinicalOutcome?.mchc ?? '',
                ),
              if (user?.clinicalOutcome?.hsCrp != null)
                _buildInfoRow(
                  Icons.science,
                  'hs-CRP',
                  user?.clinicalOutcome?.hsCrp ?? '',
                ),
              if (user?.clinicalOutcome?.ntProBnp != null)
                _buildInfoRow(
                  Icons.science,
                  'NT-proBNP',
                  user?.clinicalOutcome?.ntProBnp ?? '',
                ),
              if (user?.clinicalOutcome?.lipidProfile != null)
                _buildInfoRow(
                  Icons.science,
                  'Lipid Profile',
                  user?.clinicalOutcome?.lipidProfile ?? '',
                ),
              if (user?.clinicalOutcome?.bloodSugar != null)
                _buildInfoRow(
                  Icons.science,
                  'Blood Sugar',
                  user?.clinicalOutcome?.bloodSugar ?? '',
                ),
              if (user?.clinicalOutcome?.vitalSigns != null)
                _buildInfoRow(
                  Icons.monitor_heart,
                  'Vital Signs',
                  user?.clinicalOutcome?.vitalSigns ?? '',
                ),
                if (user?.clinicalOutcome?.hbalc != null)
                _buildInfoRow(
                  Icons.monitor_heart,
                  'hbalc',
                  user?.clinicalOutcome?.hbalc ?? '',
                ),
                 if (user?.clinicalOutcome?.urea != null)
                _buildInfoRow(
                  Icons.monitor_heart,
                  'Urea',
                  user?.clinicalOutcome?.urea ?? '',
                ),
                 if (user?.clinicalOutcome?.creatinine != null)
                _buildInfoRow(
                  Icons.monitor_heart,
                  'Creatinine',
                  user?.clinicalOutcome?.creatinine ?? '',
                ),

                 if (user?.clinicalOutcome?.sodium != null)
                _buildInfoRow(
                  Icons.monitor_heart,
                  'Sodium',
                  user?.clinicalOutcome?.sodium ?? '',
                ),
                 if (user?.clinicalOutcome?.potassium != null)
                _buildInfoRow(
                  Icons.monitor_heart,
                  'Potassium',
                  user?.clinicalOutcome?.potassium ?? '',
                ),

                if (user?.clinicalOutcome?.chloride!= null)
                _buildInfoRow(
                  Icons.monitor_heart,
                  'Chloride',
                  user?.clinicalOutcome?.chloride ?? '',
                ),
            ] else
              _buildInfoRow(
                Icons.science,
                'Status',
                'No clinical outcome data',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0D3B3F), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
