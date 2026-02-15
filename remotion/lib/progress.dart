// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// 1. DATA MODELS & MOCK DATA
// ---------------------------------------------------------------------------

class StatItem {
  final String label;
  final String value;
  final double percentage;
  final Color color;
  final IconData icon;

  StatItem(this.label, this.value, this.percentage, this.color, this.icon);
}

// ---------------------------------------------------------------------------
// 2. MAIN PAGE WIDGET
// ---------------------------------------------------------------------------

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  // Toggle this to show/hide the Level Up overlay
  bool _showLevelUpScreen = true;

  void _dismissLevelUp() {
    setState(() {
      _showLevelUpScreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If showLevelUpScreen is true, we show the Celebration Overlay
    // Otherwise, we show the actual Dashboard.
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8), // Surface color from theme
      body: Stack(
        children: [
          // The Main Dashboard (Behind the overlay initially)
          const DashboardView(),

          // The Level Up Overlay
          if (_showLevelUpScreen) LevelUpOverlay(onDismiss: _dismissLevelUp),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. LEVEL UP OVERLAY (Matches image_fe220f.png)
// ---------------------------------------------------------------------------

class LevelUpOverlay extends StatelessWidget {
  final VoidCallback onDismiss;

  const LevelUpOverlay({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      // The Teal gradient/solid color from the image
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2FB7A3), Color(0xFF1E6F6B)],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // 3D Diamond Icon Placeholder
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.diamond,
                size: 100,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Level 5",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black26, blurRadius: 10)],
              ),
            ),
            const Text(
              "RECOVERY LEVEL UP!",
              style: TextStyle(
                fontSize: 16,
                letterSpacing: 1.2,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            // Streak Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_fire_department, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    "5 Day Streak",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "Your body remembers\nprogress",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            // Unlock Text
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_outlined, color: Colors.white70, size: 16),
                SizedBox(width: 8),
                Text(
                  "CONSISTENCY CHAMPION UNLOCKED",
                  style: TextStyle(color: Colors.white70, letterSpacing: 1),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Continue Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: ElevatedButton(
                onPressed: onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1E6F6B),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Continue Journey"),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. DASHBOARD VIEW (Matches image_fe21cb.png)
// ---------------------------------------------------------------------------

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Recovery Journey"),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Every step forward is a step towards strength.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // --- Timeline Section ---
            const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: TimelineRow(),
            ),
            const SizedBox(height: 20),

            // --- Streak Badge ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.orange, Colors.orangeAccent],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.orangeAccent,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                "🔥 5 Day Streak",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Main Content Stack (Converted from Web Row to Mobile Column) ---

            // 1. Recovery Level Card
            const RecoveryLevelCard(),
            const SizedBox(height: 16),

            // 2. Body Map Card
            const BodyMapCard(),
            const SizedBox(height: 16),

            // 3. Movement Quality Grid
            const MovementQualitySection(),
            const SizedBox(height: 16),

            // 4. Achievements (Purple Card)
            const AchievementsCard(),
            const SizedBox(height: 16),

            // 5. Physio Note (Requested in prompt text)
            const PhysioNoteCard(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. SUB-COMPONENTS (CARDS & WIDGETS)
// ---------------------------------------------------------------------------

class RecoveryLevelCard extends StatelessWidget {
  const RecoveryLevelCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "RECOVERY LEVEL",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            // Circular Progress
            Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: 0.75, // 75%
                    strokeWidth: 10,
                    backgroundColor: Color(0xFFE0E0E0),
                    color: Color(0xFF00C8B0), // Cyan/Teal
                  ),
                ),
                const Text(
                  "4",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E6F6B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // XP Bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E0), // Light orange bg
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "XP",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        "200 / 1,000 XP",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.2,
                    backgroundColor: Colors.white,
                    color: Colors.orange,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Stats Rows
            _buildStatRow("SLEEP QUALITY", 0.85, const Color(0xFF6C63FF)),
            const SizedBox(height: 8),
            _buildStatRow("HYDRATION", 0.60, Colors.blue),
            const SizedBox(height: 8),
            _buildStatRow("MOBILITY", 0.72, const Color(0xFF00C8B0)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Text(
              "${(value * 100).toInt()}%",
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          color: color,
          backgroundColor: color.withOpacity(0.2),
          minHeight: 6,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

class BodyMapCard extends StatelessWidget {
  const BodyMapCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recovery Body Map",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E6F6B),
                ),
              ),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Your Status", style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 20),
            // Placeholder for Body Image using Icon
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.accessibility,
                    size: 200,
                    color: Colors.grey.shade300,
                  ),
                  // Overlay dots/zones (Simulating the image)
                  Positioned(
                    top: 60,
                    child: Container(
                      width: 60,
                      height: 10,
                      color: Colors.redAccent.withOpacity(0.6),
                    ), // Shoulders
                  ),
                  Positioned(
                    top: 80,
                    child: Container(
                      width: 50,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C8B0).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ), // Torso
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendItem(Colors.redAccent, "FOCUS"),
                const SizedBox(width: 12),
                _legendItem(const Color(0xFF00C8B0), "GOOD"),
                const SizedBox(width: 12),
                _legendItem(Colors.grey, "REST"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class MovementQualitySection extends StatelessWidget {
  const MovementQualitySection({super.key});

  @override
  Widget build(BuildContext context) {
    // Grid Data
    final items = [
      StatItem("FLEXIBILITY", "72%", 0.72, Colors.redAccent, Icons.open_with),
      StatItem("STRENGTH", "58%", 0.58, Colors.amber, Icons.bolt),
      StatItem("ENDURANCE", "65%", 0.65, Colors.green, Icons.favorite),
      StatItem("BALANCE", "80%", 0.80, Colors.deepPurple, Icons.balance),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            "MOVEMENT QUALITY",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: item.color.withOpacity(0.2), // Subtle background tint
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: item.percentage,
                        color: item.color,
                        backgroundColor: Colors.grey.shade200,
                      ),
                      Icon(item.icon, color: item.color, size: 20),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class AchievementsCard extends StatelessWidget {
  const AchievementsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.emoji_events_outlined, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "ACHIEVEMENTS",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _achievementBadge(
                Icons.diamond,
                "Consistency\nDiamond",
                Colors.blue,
              ),
              _achievementBadge(Icons.star, "Recovery\nStar", Colors.amber),
              _achievementBadge(
                Icons.track_changes,
                "Balance\nBadge",
                Colors.purpleAccent,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar at bottom of card
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const Expanded(flex: 1, child: SizedBox()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _achievementBadge(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
            border: Border.all(color: Colors.white30),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }
}

class PhysioNoteCard extends StatelessWidget {
  const PhysioNoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.medical_services_outlined,
                  color: Color(0xFF1E6F6B),
                ),
                const SizedBox(width: 8),
                Text(
                  "Physio Note",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(),
            const Text(
              "\"Great progress on the knee extension exercises this week. Your stability score has increased by 15%. Keep maintaining this form for the next session.\"",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "- Dr. Sarah M.",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimelineRow extends StatelessWidget {
  const TimelineRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _step("STARTED", Icons.eco, true, true),
        _line(true),
        _step("WEEK 1", Icons.local_fire_department, true, true),
        _line(true),
        _step("FIRST GEM", Icons.diamond, true, true),
        _line(true),
        _step("RISING STAR", Icons.star, true, true), // Current
        _line(false),
        _step("PRO", Icons.lock_outline, false, false),
      ],
    );
  }

  Widget _step(String label, IconData icon, bool isCompleted, bool isCurrent) {
    final color = isCompleted ? const Color(0xFF00C8B0) : Colors.grey.shade300;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: color, width: 2),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Icon(icon, size: 20, color: isCompleted ? color : Colors.grey),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _line(bool isActive) {
    return Container(
      width: 30,
      height: 4,
      color: isActive ? const Color(0xFF00C8B0) : Colors.grey.shade300,
      margin: const EdgeInsets.only(bottom: 20, left: 4, right: 4),
    );
  }
}
