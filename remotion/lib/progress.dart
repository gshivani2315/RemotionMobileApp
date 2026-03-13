// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:remotion/services/api_service.dart';

// ---------------------------------------------------------------------------
// 1. DATA MODELS
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
  final ApiService _apiService = ApiService();
  late Future<ProgressData?> _progressFuture;
  bool _showLevelUpScreen = false;
  ProgressData? _cachedData;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  void _loadProgressData() {
    _progressFuture = _apiService.getProgressData().then((data) {
      if (data != null) {
        _cachedData = data;
        if (data.levelUp.showLevelUp) {
          setState(() => _showLevelUpScreen = true);
        }
      }
      return data;
    });
  }

  void _retryLoad() {
    setState(() {
      _loadProgressData();
    });
  }

  void _dismissLevelUp() {
    _apiService.markLevelUpSeen();
    setState(() {
      _showLevelUpScreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Stack(
        children: [
          FutureBuilder<ProgressData?>(
            future: _progressFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _LoadingView();
              }

              if (snapshot.hasError || snapshot.data == null) {
                return _ErrorView(onRetry: _retryLoad);
              }

              return DashboardView(data: snapshot.data!);
            },
          ),
          if (_showLevelUpScreen && _cachedData != null)
            LevelUpOverlay(
              data: _cachedData!.levelUp,
              onDismiss: _dismissLevelUp,
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. LOADING VIEW
// ---------------------------------------------------------------------------

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF1E6F6B)),
          SizedBox(height: 16),
          Text(
            "Loading your progress...",
            style: TextStyle(color: Color(0xFF1E6F6B), fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. ERROR VIEW
// ---------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              "Unable to load progress",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E6F6B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Please check your connection and try again",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E6F6B),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. LEVEL UP OVERLAY
// ---------------------------------------------------------------------------

class LevelUpOverlay extends StatelessWidget {
  final LevelUpData data;
  final VoidCallback onDismiss;

  const LevelUpOverlay({
    super.key,
    required this.data,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2FB7A3), Color(0xFF1E6F6B)],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 400;
            final iconSize = isSmallScreen ? 80.0 : 100.0;
            final levelFontSize = isSmallScreen ? 40.0 : 48.0;
            final messageFontSize = isSmallScreen ? 24.0 : 28.0;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
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
                  child: Icon(
                    Icons.diamond,
                    size: iconSize,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Level ${data.currentLevel}",
                  style: TextStyle(
                    fontSize: levelFontSize,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: const [
                      Shadow(color: Colors.black26, blurRadius: 10),
                    ],
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${data.streak} Day Streak",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    data.message.isNotEmpty
                        ? data.message
                        : "Your body remembers\nprogress",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: messageFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      data.achievement.isNotEmpty
                          ? data.achievement
                          : "ACHIEVEMENT UNLOCKED",
                      style: const TextStyle(
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. DASHBOARD VIEW - RESPONSIVE
// ---------------------------------------------------------------------------

class DashboardView extends StatelessWidget {
  final ProgressData data;

  const DashboardView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Recovery Journey"),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive breakpoints
          final isWide = constraints.maxWidth >= 900;
          final isMedium =
              constraints.maxWidth >= 600 && constraints.maxWidth < 900;

          if (isWide) {
            return _buildWideLayout(context, constraints);
          } else if (isMedium) {
            return _buildMediumLayout(context, constraints);
          } else {
            return _buildMobileLayout(context);
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Every step forward is a step towards strength.",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: TimelineRow(timeline: data.timeline),
          ),
          const SizedBox(height: 20),
          StreakBadge(streak: data.streak),
          const SizedBox(height: 24),
          RecoveryLevelCard(data: data.recoveryLevel),
          const SizedBox(height: 16),
          BodyMapCard(data: data.bodyMap),
          const SizedBox(height: 16),
          MovementQualitySection(data: data.movementQuality),
          const SizedBox(height: 16),
          AchievementsCard(data: data.achievements),
          const SizedBox(height: 16),
          PhysioNoteCard(data: data.physioNote),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildMediumLayout(BuildContext context, BoxConstraints constraints) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Every step forward is a step towards strength.",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: TimelineRow(timeline: data.timeline),
          ),
          const SizedBox(height: 20),
          StreakBadge(streak: data.streak),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: RecoveryLevelCard(data: data.recoveryLevel)),
              const SizedBox(width: 16),
              Expanded(child: BodyMapCard(data: data.bodyMap)),
            ],
          ),
          const SizedBox(height: 16),
          MovementQualitySection(data: data.movementQuality, crossAxisCount: 4),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: AchievementsCard(data: data.achievements)),
              const SizedBox(width: 16),
              Expanded(child: PhysioNoteCard(data: data.physioNote)),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, BoxConstraints constraints) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Every step forward is a step towards strength.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 24),
          TimelineRow(timeline: data.timeline),
          const SizedBox(height: 24),
          StreakBadge(streak: data.streak),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    RecoveryLevelCard(data: data.recoveryLevel),
                    const SizedBox(height: 16),
                    MovementQualitySection(
                      data: data.movementQuality,
                      crossAxisCount: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: BodyMapCard(data: data.bodyMap)),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    AchievementsCard(data: data.achievements),
                    const SizedBox(height: 16),
                    PhysioNoteCard(data: data.physioNote),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 7. STREAK BADGE
// ---------------------------------------------------------------------------

class StreakBadge extends StatelessWidget {
  final StreakData streak;

  const StreakBadge({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: streak.isActive
              ? [Colors.orange, Colors.orangeAccent]
              : [Colors.grey, Colors.grey.shade400],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: streak.isActive ? Colors.orangeAccent : Colors.grey,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        "🔥 ${streak.days} Day Streak",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 8. RECOVERY LEVEL CARD
// ---------------------------------------------------------------------------

class RecoveryLevelCard extends StatelessWidget {
  final RecoveryLevelData data;

  const RecoveryLevelCard({super.key, required this.data});

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
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: data.percentage,
                    strokeWidth: 10,
                    backgroundColor: const Color(0xFFE0E0E0),
                    color: const Color(0xFF00C8B0),
                  ),
                ),
                Text(
                  "${data.level}",
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E6F6B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "XP",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        "${data.xp.current} / ${data.xp.max} XP",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: data.xp.progress,
                    backgroundColor: Colors.white,
                    color: Colors.orange,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildStatRow(
              "SLEEP QUALITY",
              data.stats.sleepQuality,
              const Color(0xFF6C63FF),
            ),
            const SizedBox(height: 8),
            _buildStatRow("HYDRATION", data.stats.hydration, Colors.blue),
            const SizedBox(height: 8),
            _buildStatRow(
              "MOBILITY",
              data.stats.mobility,
              const Color(0xFF00C8B0),
            ),
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

// ---------------------------------------------------------------------------
// 9. BODY MAP CARD
// ---------------------------------------------------------------------------

class BodyMapCard extends StatelessWidget {
  final BodyMapData data;

  const BodyMapCard({super.key, required this.data});

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
                  ..._buildZoneOverlays(),
                ],
              ),
            ),
            const SizedBox(height: 10),
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

  List<Widget> _buildZoneOverlays() {
    List<Widget> overlays = [];
    for (var zone in data.zones) {
      Color color;
      switch (zone.status) {
        case 'focus':
          color = Colors.redAccent;
          break;
        case 'good':
          color = const Color(0xFF00C8B0);
          break;
        default:
          color = Colors.grey;
      }

      Positioned overlay;
      switch (zone.area) {
        case 'shoulders':
          overlay = Positioned(
            top: 60,
            child: Container(
              width: 60,
              height: 10,
              color: color.withOpacity(0.6 + zone.intensity * 0.4),
            ),
          );
          break;
        case 'torso':
          overlay = Positioned(
            top: 80,
            child: Container(
              width: 50,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.6 + zone.intensity * 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          break;
        case 'legs':
          overlay = Positioned(
            top: 130,
            child: Container(
              width: 30,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3 + zone.intensity * 0.4),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          break;
        default:
          continue;
      }
      overlays.add(overlay);
    }
    return overlays;
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

// ---------------------------------------------------------------------------
// 10. MOVEMENT QUALITY SECTION
// ---------------------------------------------------------------------------

class MovementQualitySection extends StatelessWidget {
  final MovementQualityData data;
  final int crossAxisCount;

  const MovementQualitySection({
    super.key,
    required this.data,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      StatItem(
        "FLEXIBILITY",
        "${data.flexibility.value}%",
        data.flexibility.percentage,
        Colors.redAccent,
        Icons.open_with,
      ),
      StatItem(
        "STRENGTH",
        "${data.strength.value}%",
        data.strength.percentage,
        Colors.amber,
        Icons.bolt,
      ),
      StatItem(
        "ENDURANCE",
        "${data.endurance.value}%",
        data.endurance.percentage,
        Colors.green,
        Icons.favorite,
      ),
      StatItem(
        "BALANCE",
        "${data.balance.value}%",
        data.balance.percentage,
        Colors.deepPurple,
        Icons.balance,
      ),
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
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
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
              color: item.color.withOpacity(0.2),
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

// ---------------------------------------------------------------------------
// 11. ACHIEVEMENTS CARD
// ---------------------------------------------------------------------------

class AchievementsCard extends StatelessWidget {
  final AchievementsData data;

  const AchievementsCard({super.key, required this.data});

  IconData _getIconForBadge(String iconName) {
    switch (iconName) {
      case 'diamond':
        return Icons.diamond;
      case 'star':
        return Icons.star;
      case 'track_changes':
        return Icons.track_changes;
      default:
        return Icons.emoji_events;
    }
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.amber,
      Colors.purpleAccent,
      Colors.green,
      Colors.orange,
    ];
    return colors[index % colors.length];
  }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events_outlined, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    "ACHIEVEMENTS (${data.unlocked}/${data.total})",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final badges = data.badges.take(3).toList();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: badges.asMap().entries.map((entry) {
                  final index = entry.key;
                  final badge = entry.value;
                  return _achievementBadge(
                    _getIconForBadge(badge.icon),
                    badge.name.replaceAll(' ', '\n'),
                    _getColorForIndex(index),
                    badge.unlocked,
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 10),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: data.progress,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _achievementBadge(
    IconData icon,
    String label,
    Color color,
    bool unlocked,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(unlocked ? 0.1 : 0.05),
            border: Border.all(
              color: unlocked ? Colors.white30 : Colors.white10,
            ),
          ),
          child: Icon(icon, color: unlocked ? color : Colors.grey, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: unlocked ? Colors.white70 : Colors.white38,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 12. PHYSIO NOTE CARD
// ---------------------------------------------------------------------------

class PhysioNoteCard extends StatelessWidget {
  final PhysioNoteData data;

  const PhysioNoteCard({super.key, required this.data});

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
            Text(
              '"${data.message}"',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "- ${data.author}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 13. TIMELINE ROW
// ---------------------------------------------------------------------------

class TimelineRow extends StatelessWidget {
  final List<TimelineItem> timeline;

  const TimelineRow({super.key, required this.timeline});

  IconData _getIconForName(String iconName) {
    switch (iconName) {
      case 'eco':
        return Icons.eco;
      case 'fire':
        return Icons.local_fire_department;
      case 'diamond':
        return Icons.diamond;
      case 'star':
        return Icons.star;
      case 'lock':
        return Icons.lock_outline;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (int i = 0; i < timeline.length; i++) {
      final item = timeline[i];
      children.add(
        _step(
          item.label,
          _getIconForName(item.icon),
          item.completed,
          item.current,
        ),
      );
      if (i < timeline.length - 1) {
        children.add(_line(item.completed));
      }
    }

    return Row(children: children);
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
