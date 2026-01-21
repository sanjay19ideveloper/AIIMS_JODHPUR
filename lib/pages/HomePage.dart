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
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Load user data from preferences when dashboard initializes
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
          backgroundColor: const Color(0xFFF8F9FA),
          body: ScreenWithLoader(
            isLoading: _isLoading,
            body:
                _currentIndex == 0
                    ? HomePage(
                      weightList: weightList,
                      medicineList: medicineList,
                      scaffoldKey: _scaffoldKey,
                    )
                    : Scaffold(
                      backgroundColor: const Color(0xFFF8F9FA),
                      appBar: AppBar(
                        elevation: 0,
                        backgroundColor: const Color(0xFF0D3B3F),
                        title: Text(
                          _getPageTitle(context),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                        leading: Builder(
                          builder: (BuildContext context) {
                            return IconButton(
                              icon: const Icon(Icons.menu, color: Colors.white),
                              onPressed: () {
                                _scaffoldKey.currentState?.openDrawer();
                              },
                            );
                          },
                        ),
                      ),
                      body: _pages[_currentIndex],
                    ),
          ),
          drawer: _buildDrawer(context),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
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
              unselectedItemColor: Colors.grey[400],
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedFontSize: 12,
              unselectedFontSize: 11,
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined, size: 24),
                  activeIcon: const Icon(Icons.home, size: 26),
                  label: AppLocalizations.of(context)!.translate('home'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.monitor_weight_outlined, size: 24),
                  activeIcon: const Icon(Icons.monitor_weight, size: 26),
                  label: AppLocalizations.of(context)!.translate('weight'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.school_outlined, size: 24),
                  activeIcon: const Icon(Icons.school, size: 26),
                  label: AppLocalizations.of(context)!.translate('myLearning'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline, size: 24),
                  activeIcon: const Icon(Icons.person, size: 26),
                  label: AppLocalizations.of(context)!.translate('profile'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.description_outlined, size: 24),
                  activeIcon: const Icon(Icons.description, size: 26),
                  label: AppLocalizations.of(context)!.translate('dailyLogs'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getPageTitle(BuildContext context) {
    switch (_currentIndex) {
      case 0:
        return AppLocalizations.of(context)!.translate('home');
      case 1:
        return AppLocalizations.of(context)!.translate('weightTracker');
      case 2:
        return AppLocalizations.of(context)!.translate('myLearning');
      case 3:
        return AppLocalizations.of(context)!.translate('profile');
      case 4:
        return AppLocalizations.of(context)!.translate('dailyLogs');
      default:
        return AppLocalizations.of(context)!.translate('home');
    }
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
        setState(() {
          _isLoading = true;
        });
        break;
      case ApiStatus.SUCCESS:
        setState(() {
          _isLoading = false;
          medicineList = state.response;
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

  Widget _buildDrawer(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D3B3F), Color(0xFF1A5D63)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const CircleAvatar(
                        radius: 35,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?img=12',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      UserSession.userName?.isNotEmpty == true
                          ? UserSession.userName!
                          : 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      UserSession.email?.isNotEmpty == true
                          ? UserSession.email!
                          : 'No email',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildDrawerItem(
              context,
              icon: Icons.home_outlined,
              title: AppLocalizations.of(context)!.translate('home'),
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                  _isDrawerOpen = false;
                });
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.medication_outlined,
              title: AppLocalizations.of(context)!.translate('medications'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddReminderScreen(),
                  ),
                );
              },
            ),
            const Divider(height: 24, indent: 16, endIndent: 16),
            _buildDrawerItem(
              context,
              icon: Icons.settings_outlined,
              title: AppLocalizations.of(context)!.translate('settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.help_outline,
              title: AppLocalizations.of(context)!.translate('helpSupport'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(height: 24, indent: 16, endIndent: 16),
            _buildDrawerItem(
              context,
              icon: Icons.privacy_tip_outlined,
              title: AppLocalizations.of(context)!.translate('privacyPolicy'),
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
            _buildDrawerItem(
              context,
              icon: Icons.description_outlined,
              title: AppLocalizations.of(context)!.translate('termsConditions'),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.language_outlined,
                    color: Colors.grey[700],
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.translate('language'),
                      style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                    ),
                  ),
                  InkWell(
                    onTap: () => _showLanguagePopup(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D3B3F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        localeProvider.locale.languageCode == 'en'
                            ? "English"
                            : "हिन्दी",
                        style: const TextStyle(
                          color: Color(0xFF0D3B3F),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24, indent: 16, endIndent: 16),
            _buildDrawerItem(
              context,
              icon: Icons.logout,
              title: AppLocalizations.of(context)!.translate('logout'),
              color: Colors.red,
              onTap: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              AppLocalizations.of(context)!.translate('logout'),
                              style: const TextStyle(color: Colors.white),
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey[700], size: 24),
      title: Text(
        title,
        style: TextStyle(color: color ?? Colors.grey[800], fontSize: 15),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<Weight>? weightList;
  final MedicineResponse? medicineList;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const HomePage({
    super.key,
    this.weightList,
    this.medicineList,
    this.scaffoldKey,
  });

  Widget _buildTrackerCard(
    BuildContext context, {
    required String title,
    required String iconPath,
    required Color cardColor,

    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cardColor.withOpacity(0.1), cardColor.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: cardColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  iconPath,
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cardColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: cardColor.withOpacity(0.7),
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
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.medication,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)!.translate('medicine'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${medication?.medicine?.name ?? AppLocalizations.of(context)!.translate('noMedicine')} ${medication?.medicine?.dosage ?? ''}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Text(
                  formattedTime,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      medication?.status == true
                          ? [Colors.green.shade50, Colors.green.shade100]
                          : [Colors.orange.shade50, Colors.orange.shade100],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    medication?.status == true
                        ? Icons.check_circle
                        : Icons.pending_outlined,
                    size: 16,
                    color:
                        medication?.status == true
                            ? Colors.green[700]
                            : Colors.orange[700],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          medication?.status == true
                              ? Colors.green[700]
                              : Colors.orange[700],
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
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 110,
              width: 110,
              child: Stack(
                children: [
                  SizedBox(
                    height: 110,
                    width: 110,
                    child: CircularProgressIndicator(
                      value: latestWeight != null ? (latestWeight / 150) : 0.0,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey[100],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF0D3B3F),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          latestWeight != null
                              ? latestWeight.toStringAsFixed(1)
                              : '--',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D3B3F),
                          ),
                        ),
                        Text(
                          'kg',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
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
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabTestCard(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LabReportPage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade400, Colors.teal.shade600],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.science, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('labTest'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.translate('viewLabReports'),
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 18),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = UserSession.userName ?? 'User';
    final age = UserSession.age ?? '';

    String getOnlyYears(String age) {
      final match = RegExp(r'(\d+)\s*year').firstMatch(age);
      return match != null ? '${match.group(1)} years' : '';
    }

    String formattedAge = getOnlyYears(age);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0D3B3F),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            scaffoldKey?.currentState?.openDrawer();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              username,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (formattedAge.isNotEmpty)
              Text(
                formattedAge,
                style: const TextStyle(color: Colors.white70, fontSize: 13.0),
              ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D3B3F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Color(0xFF0D3B3F),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Health Trackers',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.85,
            children: [
              _buildTrackerCard(
                context,
                title: AppLocalizations.of(context)!.translate('weightTracker'),
                iconPath: 'assets/images/scales.png',
                cardColor: const Color(0xFF0D3B3F),

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
              // Symptoms Tracker - Orange
              _buildTrackerCard(
                context,
                title: AppLocalizations.of(
                  context,
                )!.translate('symptomsTracker'),
                iconPath: 'assets/images/palliative.png',
                cardColor: const Color(0xFFF97316), // Orange

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
              // Medicine Reminder - Purple
              _buildTrackerCard(
                context,
                title: AppLocalizations.of(
                  context,
                )!.translate('medicineReminder'),
                iconPath: 'assets/images/drugs.png',
                cardColor: const Color(0xFF7C3AED), // Purple

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
              // My Learning - Green
              _buildTrackerCard(
                context,
                title: AppLocalizations.of(context)!.translate('myLearning'),
                iconPath: 'assets/images/online-course.png',
                cardColor: const Color(0xFF059669), // Green

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
          const SizedBox(height: 32),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D3B3F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.timeline,
                  color: Color(0xFF0D3B3F),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Today\'s Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildWeightCard(context)),
              const SizedBox(width: 16),
              Expanded(child: _buildMedicineCard(context)),
            ],
          ),
          const SizedBox(height: 20),
          _buildLabTestCard(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

void _showLanguagePopup(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Consumer<LocaleProvider>(
          builder: (context, localeProvider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          localeProvider.locale.languageCode == 'en'
                              ? const Color(0xFF0D3B3F).withOpacity(0.1)
                              : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.language,
                      color:
                          localeProvider.locale.languageCode == 'en'
                              ? const Color(0xFF0D3B3F)
                              : Colors.grey[600],
                    ),
                  ),
                  title: const Text(
                    "English",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  trailing:
                      localeProvider.locale.languageCode == 'en'
                          ? const Icon(
                            Icons.check_circle,
                            color: Color(0xFF0D3B3F),
                          )
                          : null,
                  onTap: () {
                    localeProvider.setLocale(const Locale('en', ''));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          localeProvider.locale.languageCode == 'hi'
                              ? const Color(0xFF0D3B3F).withOpacity(0.1)
                              : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.language,
                      color:
                          localeProvider.locale.languageCode == 'hi'
                              ? const Color(0xFF0D3B3F)
                              : Colors.grey[600],
                    ),
                  ),
                  title: const Text(
                    "हिन्दी",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  trailing:
                      localeProvider.locale.languageCode == 'hi'
                          ? const Icon(
                            Icons.check_circle,
                            color: Color(0xFF0D3B3F),
                          )
                          : null,
                  onTap: () {
                    localeProvider.setLocale(const Locale('hi', ''));
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      );
    },
  );
}
