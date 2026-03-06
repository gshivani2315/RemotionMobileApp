import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  late Future<Map<String, dynamic>?> _profileFuture;

  @override
  void initState() {
    super.initState();
    // 1. Start the API call to your Express backend immediately
    _profileFuture = _apiService.getProtectedData();
  }

  void _retryConnection() {
    setState(() {
      _profileFuture = _apiService.getProtectedData();
    });
  }

  // 2. Professional Logout with Confirmation
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to log out of ReMotion?"),
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
        backgroundColor: reMotionTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('ReMotion Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              tooltip: "Logout",
              onPressed: _confirmLogout,
            ),
          ],
        ),
        // 3. FUTUREBUILDER: The gatekeeper that prevents UI load if API fails
        body: FutureBuilder<Map<String, dynamic>?>(
          future: _profileFuture,
          builder: (context, snapshot) {
            // Loading State
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Error State: This triggers if Express is offline or Token is invalid
            if (snapshot.hasError || snapshot.data == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Authentication Verified, but Backend is Offline",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Ensure your Express server is running on http://localhost:3000",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _retryConnection,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Retry Connection"),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Success State: API responded with 200 OK and JSON data
            final data = snapshot.data!;
            return _buildDashboardContent(data['email'] ?? 'User');
          },
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  // DASHBOARD CONTENT UI (Only visible on Success)
  // ────────────────────────────────────────────────

  Widget _buildDashboardContent(String userEmail) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Welcome back,\n$userEmail",
                style: reMotionTheme.textTheme.titleLarge,
              ),
            ),
            _buildTodayStatusCard(),
            _buildStreakCard(),
            _buildRecoverySnapshotCard(),
            _buildUpcomingScheduleCard(),
            _buildQuickActionsSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Today's Rehab",
                  style: reMotionTheme.textTheme.titleMedium,
                ),
                const Spacer(),
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF2FB7A3),
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 20,
                  color: Color(0xFF9AA5A1),
                ),
                SizedBox(width: 8),
                Text(
                  "Completed",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2FB7A3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Color(0xFFC8A96A),
                  size: 28,
                ),
                SizedBox(width: 8),
                Text(
                  "5-day streak",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFC8A96A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: 0.8,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoverySnapshotCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Recovery Snapshot",
              style: reMotionTheme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              "Latest note from physiotherapist:",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const Text(
              "Good progress on knee flexion. Continue exercises.",
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingScheduleCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Upcoming Sessions",
              style: reMotionTheme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.calendar_today, color: Color(0xFF1E6F6B)),
              title: Text("Home Exercise"),
              subtitle: Text("Tomorrow, 10:00 AM"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _actionBtn(Icons.report, "Report Pain", Colors.redAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _actionBtn(
              Icons.chat,
              "Message Doc",
              const Color(0xFF1E6F6B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
