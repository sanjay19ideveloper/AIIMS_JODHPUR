import 'dart:developer';
import 'package:aiims_heartcare/data/api/api_service.dart';
import 'package:aiims_heartcare/data/provider/localProvider.dart';
import 'package:aiims_heartcare/pages/LabReportPage.dart';
import 'package:aiims_heartcare/pages/LoginPage.dart';
import 'package:aiims_heartcare/pages/NotificationPermission.dart';
import 'package:aiims_heartcare/pages/PrivacyPolicy.dart';
import 'package:aiims_heartcare/pages/SymtomsFaq.dart';
import 'package:aiims_heartcare/pages/Terms&Condition.dart';
import 'package:flutter/material.dart';
import 'package:aiims_heartcare/l10n/app_localizations.dart';
import 'package:aiims_heartcare/pages/MedicineList.dart';
import 'package:aiims_heartcare/pages/Weight-Tracker-List.dart';
import 'package:aiims_heartcare/pages/LearningPage.dart';
import 'package:aiims_heartcare/pages/ProfilePage.dart';
import 'package:aiims_heartcare/pages/DailyLogsPage.dart';
import 'package:aiims_heartcare/data/model/medicineModel.dart';
import 'package:aiims_heartcare/data/model/weightListResp.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aiims_heartcare/blocs/home_bloc.dart';
import 'package:aiims_heartcare/blocs/bloc_manager.dart';
import 'package:aiims_heartcare/utils/user_sessions.dart';
import 'package:aiims_heartcare/utils/loading.dart';
import 'package:aiims_heartcare/utils/log.dart';
import 'package:provider/provider.dart';

class HeartCareDashboard extends StatefulWidget {
  final int? weightCount;
  final String? medicineName;
  final String? dateTime;

  const HeartCareDashboard({
    super.key,
    this.weightCount,
    this.dateTime,
    this.medicineName,
  });

  @override
  State<HeartCareDashboard> createState() => _HeartCareDashboardState();
}

class _HeartCareDashboardState extends State<HeartCareDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  bool _isDrawerOpen = false;
  bool _isLoading = false;
  List<Weight>? weightList;
  MedicineResponse? medicineList;

  final List<Widget> _pages = [
    const HomePage(),
    const WeightTrackerPage(),
    const MyLearningPage(),
    const UserProfilePage(),
    const DailyLogsPage(),
  ];

  @override
  void initState() {
    super.initState();
    requestNotificationPermission(); 
    fetchWeightList();
    fetchMedicineList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocManager(
      initState: (BuildContext context) {
        fetchWeightList();
        fetchMedicineList();
      },
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is WeightListState) {
            handleWeightResponse(state);
          }
          if (state is MedicineState) {
            handleMedicineResponse(state);
          }
        },
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF5F5F5),
          body: ScreenWithLoader(
            isLoading: _isLoading,
            body:
                _currentIndex == 0
                    ? HomePage(
                      weightList: weightList,
                      medicineList: medicineList,
                    )
                    : _pages[_currentIndex],
          ),
          drawer: _buildDrawer(context),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: const Color(0xFFF5F5F5),
            currentIndex: _currentIndex,
            onTap: (index) {
              if (_isDrawerOpen) {
                Navigator.pop(context);
                _isDrawerOpen = false;
              }
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF0D3B3F),
            unselectedItemColor: Colors.grey[600],
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                label: AppLocalizations.of(context)!.translate('home'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.monitor_weight),
                label: AppLocalizations.of(context)!.translate('weight'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.school),
                label: AppLocalizations.of(context)!.translate('myLearning'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                label: AppLocalizations.of(context)!.translate('profile'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.file_copy_outlined),
                label: AppLocalizations.of(context)!.translate('dailyLogs'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void fetchWeightList() {
    BlocProvider.of<HomeBloc>(context).add(WeightListEvent());
  }

  void fetchMedicineList() {
    BlocProvider.of<HomeBloc>(context).add(MedicineEvent());
  }

  void handleWeightResponse(WeightListState state) {
    switch (state.apiState) {
      case ApiStatus.LOADING:
        setState(() {
          _isLoading = true;
        });
        break;
      case ApiStatus.SUCCESS:
        setState(() {
          _isLoading = false;
          weightList = state.response?.weights;
          debugPrint('WEIGHT IS ${state.response?.weights?.first.weight}');
        });
        break;
      case ApiStatus.ERROR:
        setState(() {
          _isLoading = false;
        });
        break;
      case ApiStatus.INITIAL:
        break;
    }
  }

  void handleMedicineResponse(MedicineState state) {
    switch (state.apiState) {
      case ApiStatus.LOADING:
        Log.v("Loading...");
        setState(() {
          _isLoading = true;
        });
        break;
      case ApiStatus.SUCCESS:
        Log.v("Success medicine data: ${state.response}");
        setState(() {
          _isLoading = false;
          medicineList = state.response;
          log('Medicine data is ${state.response?.medications}');
        });
        break;
      case ApiStatus.ERROR:
        Log.v("Error: ${state.error}");
        setState(() {
          _isLoading = false;
        });
        break;
      case ApiStatus.INITIAL:
        break;
    }
  }

  Widget _buildDrawer(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF0D3B3F)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=12',
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${UserSession.userName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${UserSession.email}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(AppLocalizations.of(context)!.translate('home')),
            onTap: () {
              setState(() {
                _currentIndex = 0;
                _isDrawerOpen = false;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.medication),
            title: Text(AppLocalizations.of(context)!.translate('medications')),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddReminderScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(AppLocalizations.of(context)!.translate('settings')),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: Text(AppLocalizations.of(context)!.translate('helpSupport')),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: Text(
              AppLocalizations.of(context)!.translate('privacyPolicy'),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(
              AppLocalizations.of(context)!.translate('termsConditions'),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TermsConditionsScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.translate('language')),
                InkWell(
                  onTap: () => _showLanguagePopup(context),
                  child: Text(
                    localeProvider.locale.languageCode == 'en'
                        ? "English"
                        : "हिन्दी",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: "PoppinsSemibold",
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: Text(
              AppLocalizations.of(context)!.translate('logout'),
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text(
                        AppLocalizations.of(
                          context,
                        )!.translate('confirm_logout'),
                      ),
                      content: Text(
                        AppLocalizations.of(
                          context,
                        )!.translate('logout_confirmation_message'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            AppLocalizations.of(context)!.translate('cancel'),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            AppLocalizations.of(context)!.translate('logout'),
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
              );

              if (shouldLogout ?? false) {
                await UserSession.clear();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<Weight>? weightList;
  final MedicineResponse? medicineList;

  const HomePage({super.key, this.weightList, this.medicineList});

  Widget _buildFlatTrackerCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackerCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineCard(BuildContext context) {
    final medication =
        medicineList?.medications?.isNotEmpty ?? false
            ? medicineList!.medications!.first
            : null;

    String formattedTime = AppLocalizations.of(
      context,
    )!.translate('notScheduled');

    String status =
        medication?.status == true
            ? AppLocalizations.of(context)!.translate('taken')
            : AppLocalizations.of(context)!.translate('pending');

    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.medication,
                    color: Colors.blue[400],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.translate('medicine'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${medication?.medicine?.name ?? AppLocalizations.of(context)!.translate('noMedicine')} ${medication?.medicine?.dosage ?? ''}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  formattedTime,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            // const SizedBox(height: 16),
            Container(
              margin: EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color:
                    medication?.status == true
                        ? Colors.green[50]
                        : Colors.red[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    medication?.status == true
                        ? Icons.check_circle
                        : Icons.pending,
                    size: 16,
                    color:
                        medication?.status == true
                            ? Colors.green[400]
                            : Colors.red[400],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color:
                          medication?.status == true
                              ? Colors.green[700]
                              : Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightCard(BuildContext context) {
    double? latestWeight =
        weightList?.isNotEmpty ?? false
            ? double.tryParse(weightList!.first.weight ?? '0')
            : null;

    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: Stack(
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: CircularProgressIndicator(
                      value: latestWeight != null ? (latestWeight / 100) : 0.0,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF0D3B3F),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          latestWeight != null
                              ? '${latestWeight.toStringAsFixed(1)}'
                              : '--',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D3B3F),
                          ),
                        ),
                        const Text(
                          'kg',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.translate('latestWeight'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200.0,
          floating: false,
          pinned: true,
          snap: false,
          stretch: true,
          backgroundColor: const Color(0xFF0D3B3F),
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              AppLocalizations.of(context)!.translate('aiimsJodhpur'),
              style: const TextStyle(color: Colors.white, fontSize: 16.0),
            ),
            background: Image.network(
              'https://images.unsplash.com/photo-1567333971983-7ba18485eaad?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTc4fHxtZWRpY2luZXxlbnwwfHwwfHx8MA%3D%3D',
              fit: BoxFit.cover,
              color: const Color(0xFF0D3B3F).withOpacity(0.7),
              colorBlendMode: BlendMode.overlay,
            ),
            stretchModes: const [
              StretchMode.zoomBackground,
              StretchMode.blurBackground,
            ],
          ),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
         
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.translate('todaysOverview'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildWeightCard(context)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildMedicineCard(context)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFlatTrackerCard(
                  context,
                  title:
                      AppLocalizations.of(context)!.translate('labTest'),
                  icon: Icons.science,
                  color: Colors.teal,
                  description:
                      AppLocalizations.of(
                        context,
                      )!.translate('viewLabReports'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LabReportPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.translate('healthTrackers'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    _buildTrackerCard(
                      context,
                      title: AppLocalizations.of(
                        context,
                      )!.translate('weightTracker'),
                      icon: Icons.monitor_weight,
                      color: Colors.orange,
                      description: AppLocalizations.of(
                        context,
                      )!.translate('trackWeightProgress'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WeightTrackerPage(),
                          ),
                        );
                      },
                    ),
                    _buildTrackerCard(
                      context,
                      title: AppLocalizations.of(
                        context,
                      )!.translate('symptomsTracker'),
                      icon: Icons.healing,
                      color: Colors.purple,
                      description: AppLocalizations.of(
                        context,
                      )!.translate('logSymptoms'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ZoneFAQScreen(),
                          ),
                        );
                      },
                    ),
                    _buildTrackerCard(
                      context,
                      title: AppLocalizations.of(
                        context,
                      )!.translate('medicineReminder'),
                      icon: Icons.medication,
                      color: Colors.blue,
                      description: AppLocalizations.of(
                        context,
                      )!.translate('neverMissDose'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddReminderScreen(),
                          ),
                        );
                      },
                    ),
                    _buildTrackerCard(
                      context,
                      title: AppLocalizations.of(
                        context,
                      )!.translate('myLearning'),
                      icon: Icons.school,
                      color: Colors.green,
                      description: AppLocalizations.of(
                        context,
                      )!.translate('heartHealthEducation'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyLearningPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

void _showLanguagePopup(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("English"),
                onTap: () {
                  localeProvider.setLocale(const Locale('en', ''));
                  Navigator.pop(context); // Close the bottom sheet
                },
              ),
              ListTile(
                title: const Text("हिन्दी"),
                onTap: () {
                  localeProvider.setLocale(const Locale('hi', ''));
                  Navigator.pop(context); // Close the bottom sheet
                },
              ),
            ],
          );
        },
      );
    },
  );
}
