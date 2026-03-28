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
  late Future<Map<String, dynamic>?> _exercisesFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _statsFuture = _apiService.getDashboardStats();
      _exercisesFuture = _apiService.getAssignedExercises();
    });
  }

  // --- THE CHAT WIDGET LOGIC ---
  void _showChatSheet(String physioName, String? physioId) {
    if (physioId == null || physioId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No physiotherapist assigned.")),
      );
      return;
    }

    final TextEditingController messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  // Handle and Header
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "Chat with $physioName",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5550),
                      ),
                    ),
                  ),
                  const Divider(height: 1),

                  // Message List
                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: _apiService.getChatMessages(physioId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final messages = snapshot.data ?? [];
                        if (messages.isEmpty) {
                          return const Center(
                            child: Text(
                              "No messages yet. Start the conversation!",
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final msg = messages[index];
                            final bool isMe = msg['senderType'] == 'user';
                            return Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? const Color(0xFF1B5550)
                                      : const Color(0xFFF1F5F5),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  msg['content'] ?? "",
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // Input Field
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: messageController,
                            decoration: InputDecoration(
                              hintText: "Type a message...",
                              filled: true,
                              fillColor: const Color(0xFFF1F5F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Color(0xFF1B5550),
                          ),
                          onPressed: () async {
                            if (messageController.text.trim().isEmpty) return;
                            final success = await _apiService.sendChatMessage(
                              physioId,
                              messageController.text,
                            );
                            if (success) {
                              messageController.clear();
                              setModalState(() {}); // Refresh list inside modal
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([_statsFuture, _exercisesFuture]),
      builder: (context, snapshot) {
        String myPhysio = "Not Assigned";
        String? physioId;
        List<dynamic> exercises = [];

        if (snapshot.hasData) {
          final statsData = snapshot.data![0];
          if (statsData != null) {
            final data = statsData['data'];
            myPhysio = data?['physioName'] ?? "Not Assigned";
            // IMPORTANT: Get the physio UID from dashboard stats
            // If your backend doesn't send it, you'll need to add it to dashboardController.js
            physioId =
                data?['physiotherapist_assigned'] ?? data?['therapistId'];
          }

          final exerciseData = snapshot.data![1];
          if (exerciseData != null && exerciseData['status'] == 'success') {
            exercises = exerciseData['data']?['exercises'] ?? [];
          }
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "My Schedule",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5550),
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: RefreshIndicator(
            onRefresh: () async => _refreshData(),
            child: Column(
              children: [
                _buildPhysioHeader(myPhysio),
                Expanded(
                  child: exercises.isEmpty
                      ? const Center(child: Text("No exercises assigned yet."))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: exercises.length,
                          itemBuilder: (context, index) {
                            final ex = exercises[index];
                            return _sessionCard(
                              context,
                              title: ex['name'] ?? "Exercise",
                              time: "Assigned Session",
                              status: ex['hasEverCompleted'] == true
                                  ? "Completed"
                                  : "Upcoming",
                              instruction:
                                  "Goal: ${ex['sets']} sets of ${ex['reps']} reps",
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: const Color(0xFF1B5550),
            onPressed: () => _showChatSheet(myPhysio, physioId),
            icon: const Icon(Icons.message, color: Colors.white),
            label: Text(
              "Chat with ${myPhysio.split(' ')[0]}",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhysioHeader(String name) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF9F835F).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.medical_services,
            color: Color(0xFF9F835F),
            size: 20,
          ),
          const SizedBox(width: 10),
          const Text(
            "Assigned Physio: ",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5550),
            ),
          ),
        ],
      ),
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
        ? const Color(0xFF959993)
        : const Color(0xFF1B5550);

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
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Color(0xFF959993),
                        fontSize: 12,
                      ),
                    ),
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
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: statusColor.withOpacity(0.7),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    instruction,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.black87.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
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
