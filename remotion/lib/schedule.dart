import 'package:flutter/material.dart';
import 'package:remotion/services/api_service.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>?> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _apiService.getDashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _statsFuture,
      builder: (context, snapshot) {
        String myPhysio = "Loading...";
        
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data != null) {
            myPhysio = snapshot.data!['data']?['physioName'] ?? "Not Assigned";
          } else {
            myPhysio = "Unavailable";
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "My Schedule", 
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5550))
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFF1B5550).withOpacity(0.1),
                  child: const Icon(Icons.person, color: Color(0xFF1B5550)),
                ),
              )
            ],
          ),
          body: Column(
            children: [
              // Persistent Physio Header
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF9F835F).withOpacity(0.1), // Using your Motivation/Accent color
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.medical_services, color: Color(0xFF9F835F), size: 20),
                    const SizedBox(width: 10),
                    const Text("Assigned Physio: ", style: TextStyle(fontWeight: FontWeight.w500)),
                    Text(myPhysio, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5550))),
                  ],
                ),
              ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _sessionCard(
                  context,
                  title: "Knee Rehab Session",
                  time: "Today • 4:00 PM",
                  status: "Upcoming",
                  instruction: "Focus on slow extensions",
                ),
                _sessionCard(
                  context,
                  title: "Daily Mobility Drill",
                  time: "Tomorrow • 10:00 AM",
                  status: "Upcoming",
                  instruction: "Use the resistance band",
                ),
                _sessionCard(
                  context,
                  title: "Initial Assessment",
                  time: "Feb 12 • 6:00 PM",
                  status: "Completed",
                  instruction: "Baseline established",
                ),
              ],
            ),
          ),
        ],
      ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: const Color(0xFF1B5550),
            onPressed: () {},
            icon: const Icon(Icons.message, color: Colors.white),
            label: Text(
              myPhysio == "Loading..." || myPhysio == "Unavailable" || myPhysio == "Not Assigned" 
                ? "Chat with Physio" 
                : "Chat with ${myPhysio.split(' ')[0]}", 
              style: const TextStyle(color: Colors.white)
            ),
          ),
        );
      }
    );
  }

  Widget _sessionCard(
    BuildContext context, {
    required String title,
    required String time,
    required String status,
    required String instruction,
  }) {
    final bool isCompleted = status == "Completed";
    final Color statusColor = isCompleted 
        ? const Color(0xFF959993) // Muted Grey
        : const Color(0xFF1B5550); // Brand Green

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title, 
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? const Color(0xFF959993) : const Color(0xFF1B5550),
                      )
                    ),
                    const SizedBox(height: 4),
                    Text(time, style: const TextStyle(color: Color(0xFF959993), fontSize: 12)),
                  ],
                ),
                Icon(
                  isCompleted ? Icons.check_circle : Icons.arrow_forward_ios,
                  color: statusColor,
                  size: 20,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: statusColor.withOpacity(0.7)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    instruction,
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black87.withOpacity(0.7), fontSize: 13),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
