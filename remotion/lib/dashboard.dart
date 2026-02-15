import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ────────────────────────────────────────────────
// Your theme file (paste this in theme.dart or lib/theme.dart)
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
    bodyLarge: TextStyle(
      color: Color(0xFF1E6F6B),
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      color: Color(0xFF1E6F6B),
      fontSize: 14,
    ),
    bodySmall: TextStyle(
      color: Color(0xFF9AA5A1),
      fontSize: 12,
    ),
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 1,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1E6F6B),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Color(0xFF2FB7A3),
    linearTrackColor: Color(0xFF9AA5A1),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFF1E6F6B),
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: Color(0xFF1E6F6B),
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
);

// ────────────────────────────────────────────────
// Dashboard Screen
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // 1. Today's Rehab Status – Primary Card
                _buildTodayStatusCard(context),

                // 2. Adherence & Streak
                _buildStreakCard(),

                // 3. Recovery Snapshot
                _buildRecoverySnapshotCard(),

                // 4. Upcoming Schedule
                _buildUpcomingScheduleCard(context),

                // 5. Quick Actions / Alerts
                _buildQuickActionsSection(context),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayStatusCard(BuildContext context) {
    final now = DateTime.now();
    final nextSession = DateTime(now.year, now.month, now.day + 1, 10, 0); // example

    final isCompletedToday = true; // ← connect to real data later
    final hasMissed = false;

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
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (isCompletedToday)
                  const Icon(Icons.check_circle, color: Color(0xFF2FB7A3), size: 28)
                else
                  const Icon(Icons.pending_outlined, color: Colors.orange, size: 28),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 20, color: Color(0xFF9AA5A1)),
                const SizedBox(width: 8),
                Text(
                  isCompletedToday ? "Completed" : "Pending",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isCompletedToday ? const Color(0xFF2FB7A3) : Colors.orange[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 20, color: Color(0xFF9AA5A1)),
                const SizedBox(width: 8),
                Text(
                  "Next: ${DateFormat('EEE h:mm a').format(nextSession)}",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),

            if (hasMissed) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "You missed a session yesterday",
                    style: TextStyle(color: Colors.redAccent[700]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    const streak = 5;
    const completedThisWeek = 4;
    const totalThisWeek = 5;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_fire_department, color: Color(0xFFC8A96A), size: 28),
                const SizedBox(width: 8),
                Text(
                  "$streak-day streak",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFC8A96A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              "Sessions this week",
              style: reMotionTheme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: completedThisWeek / totalThisWeek,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "$completedThisWeek / $totalThisWeek",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Text(
              "You're doing great! Keep the momentum going 💪",
              style: TextStyle(color: Color(0xFF2FB7A3), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoverySnapshotCard() {
    const progressStatus = "Improving";
    const painTrend = "Decreasing";
    const physioNote = "Good progress on knee flexion. Continue with exercises.";

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Recovery Snapshot", style: reMotionTheme.textTheme.titleMedium),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMiniStat("Progress", progressStatus, const Color(0xFF2FB7A3)),
                _buildMiniStat("Pain", painTrend, const Color(0xFF2FB7A3)),
              ],
            ),

            const SizedBox(height: 16),
            const Text("Latest note from physiotherapist:", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text(physioNote, style: reMotionTheme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF9AA5A1), fontSize: 13)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingScheduleCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Upcoming Sessions", style: reMotionTheme.textTheme.titleMedium),
            const SizedBox(height: 16),

            _buildSessionTile("Tomorrow", "10:00 AM", "Home Exercise – Knee Mobility"),
            const Divider(height: 28),
            _buildSessionTile("Thu, Feb 19", "11:30 AM", "Clinic Visit – Dr. Sharma"),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => FullScheduleScreen()));
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF1E6F6B)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("View Full Schedule"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTile(String day, String time, String title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Text(day, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            Text(time, style: const TextStyle(color: Color(0xFF9AA5A1), fontSize: 13)),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 15))),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Need Help?", style: reMotionTheme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  icon: Icons.report_problem_outlined,
                  label: "Report Pain",
                  color: Colors.redAccent,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  icon: Icons.phone_in_talk_outlined,
                  label: "Request Callback",
                  color: const Color(0xFF1E6F6B),
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _actionButton(
            icon: Icons.help_outline_rounded,
            label: "Get Help",
            color: const Color(0xFF2FB7A3),
            fullWidth: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Row(
            mainAxisAlignment: fullWidth ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 22),
              if (!fullWidth) const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}