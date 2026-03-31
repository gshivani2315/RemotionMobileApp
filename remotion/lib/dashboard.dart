import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:remotion/services/api_service.dart';

final ThemeData reMotionTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF1E6F6B),
    onPrimary: Colors.white,
    secondary: Color(0xFF2FB7A3),
    onSecondary: Colors.white,
    tertiary: Color(0xFFC8A96A),
    onTertiary: Colors.white,
    surface: Color(0xFFF4F6F8),
    onSurface: Color(0xFF1E6F6B),
    outline: Color(0xFF9AA5A1),
    error: Colors.redAccent,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFFF4F6F8),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      color: Color(0xFF1E6F6B),
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      color: Color(0xFF1E6F6B),
      fontSize: 18,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(color: Color(0xFF1E6F6B), fontSize: 16),
    bodyMedium: TextStyle(color: Color(0xFF1E6F6B), fontSize: 14),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
);

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>?> _statsFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _statsFuture = _apiService.getDashboardStats();
    });
  }

  // --- 1. PROGRAM DETAILS POPUP ---
  void _showProgramDetails({
    required String nextSession,
    required double recovery,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Active Recovery Plan",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E6F6B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Phase 1: Foundation & Mobility",
              style: TextStyle(color: Colors.grey),
            ),
            const Divider(height: 32),
            _programDetailRow(
              Icons.flag_circle_outlined,
              "Current Goal",
              "Restore baseline range of motion",
            ),
            const SizedBox(height: 16),
            _programDetailRow(
              Icons.event_available_outlined,
              "Next Activity",
              nextSession,
            ),
            const SizedBox(height: 16),
            _programDetailRow(
              Icons.trending_up_rounded,
              "Current Progress",
              "${(recovery * 100).toInt()}% Complete",
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E6F6B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Close",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _programDetailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1E6F6B), size: 28),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: reMotionTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ReMotion'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              onPressed: _confirmLogout,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async => _refreshData(),
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _statsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || snapshot.data == null) {
                return _buildErrorView();
              }

              final stats = snapshot.data!['data'] ?? {};

              return _buildDashboardContent(
                userName: stats['userName'] ?? 'User',
                physioName: stats['physioName'] ?? 'Not Assigned',
                streak: (stats['streak'] ?? 0) as int,
                recovery: (stats['recoveryProgress'] ?? 0.0).toDouble(),
                level: (stats['currentLevel'] ?? 1) as int,
                nextSession: stats['nextSession'] ?? 'Check schedule',
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent({
    required String userName,
    required String physioName,
    required int streak,
    required double recovery,
    required int level,
    required String nextSession,
  }) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Hello, $userName!",
              style: reMotionTheme.textTheme.titleLarge,
            ),
          ),

          _buildLevelHeader(level),
          _buildStreakCard(streak),
          _buildRecoveryCard(recovery, physioName),

          // Updated: Active Program Card now triggers popup
          _buildProgramAction(nextSession, recovery),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildLevelHeader(int level) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E6F6B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars_rounded, color: Color(0xFFC8A96A), size: 40),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Recovery Status",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                "Level $level Athlete",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(int streak) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(
              Icons.local_fire_department_rounded,
              color: Colors.orange,
              size: 32,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$streak-Day Streak",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Consistency is key to recovery!",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoveryCard(double progress, String physio) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Progress",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: const Color(0xFFF1F5F5),
                color: const Color(0xFF2FB7A3),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${(progress * 100).toInt()}% Recovered",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Physio: $physio",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramAction(String nextSession, double recovery) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () =>
            _showProgramDetails(nextSession: nextSession, recovery: recovery),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E6F6B).withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF1E6F6B).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.assignment_turned_in_rounded,
                color: Color(0xFF1E6F6B),
                size: 30,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Active Program",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      nextSession,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF1E6F6B),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("Unable to load dashboard"),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _refreshData, child: const Text("Retry")),
        ],
      ),
    );
  }
}
