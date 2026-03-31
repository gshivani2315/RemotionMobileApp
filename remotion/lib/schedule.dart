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

  // --- EXERCISE DETAILS POPUP ---
  void _showExerciseDetails(Map<String, dynamic> ex) {
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
            Text(
              ex['name'] ?? "Exercise Detail",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5550),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Instructions",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              ex['instruction'] ?? "Focus on slow, controlled movements.",
              style: TextStyle(color: Colors.grey[700], height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _infoBadge("Sets", "${ex['sets']}"),
                const SizedBox(width: 12),
                _infoBadge("Reps", "${ex['reps']}"),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5550),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Got it!",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        "$label: $value",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // --- THE CHAT WIDGET LOGIC ---
  void _showChatSheet(String physioName, String? physioId) {
    if (physioId == null || physioId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No physio assigned.")));
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
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Text(
                  "Chat with $physioName",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Divider(),
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: _apiService.getChatMessages(physioId),
                    builder: (context, snapshot) {
                      final messages = snapshot.data ?? [];
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
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? const Color(0xFF1B5550)
                                    : const Color(0xFFF1F5F5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                msg['content'] ?? "",
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: const InputDecoration(
                            hintText: "Type...",
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF1B5550)),
                        onPressed: () async {
                          if (messageController.text.isEmpty) return;
                          await _apiService.sendChatMessage(
                            physioId,
                            messageController.text,
                          );
                          messageController.clear();
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
          final stats = snapshot.data![0];
          myPhysio = stats?['data']?['physioName'] ?? "Not Assigned";
          physioId =
              stats?['data']?['therapistId'] ??
              stats?['data']?['physiotherapist_assigned'];
          exercises = snapshot.data![1]?['data']?['exercises'] ?? [];
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
                      ? const Center(child: Text("No exercises today."))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: exercises.length,
                          itemBuilder: (context, index) =>
                              _sessionCard(context, exercises[index]),
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
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF9F835F).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.medical_services, size: 20),
          const SizedBox(width: 10),
          Text("Physio: $name"),
        ],
      ),
    );
  }

  Widget _sessionCard(BuildContext context, Map<String, dynamic> ex) {
    final bool isCompleted = ex['hasEverCompleted'] == true;
    final Color statusColor = isCompleted
        ? Colors.grey
        : const Color(0xFF1B5550);

    return GestureDetector(
      onTap: () => _showExerciseDetails(ex), // Opens the instructions popup
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ex['name'] ?? "Exercise",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Goal: ${ex['sets']} sets x ${ex['reps']} reps",
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
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
                      isCompleted ? "Completed" : "Upcoming",
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
