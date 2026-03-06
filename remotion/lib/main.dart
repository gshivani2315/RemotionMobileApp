// import 'package:flutter/material.dart';

// import 'dashboard.dart';
// import 'progress.dart';
// import 'schedule.dart';

// void main() {
//   runApp(const ReMotionApp());
// }

// class ReMotionApp extends StatelessWidget {
//   const ReMotionApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'ReMotion',
//       theme: ThemeData(
//         useMaterial3: true,
//         primaryColor: const Color(0xFF1E4D4A),
//         scaffoldBackgroundColor: Colors.white,
//         fontFamily: 'sans-serif',
//       ),
//       home: const LoginPage(),
//     );
//   }
// }

// class LoginPage extends StatelessWidget {
//   const LoginPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // The Animation Builder starts as soon as the widget is built
//       body: TweenAnimationBuilder<double>(
//         tween: Tween<double>(begin: 0.0, end: 1.0),
//         duration: const Duration(milliseconds: 1000), // 1 second "swoosh"
//         curve:
//             Curves.easeOutCubic, // Makes the movement feel smooth and premium
//         builder: (context, value, child) {
//           return Opacity(
//             opacity: value,
//             child: Transform.translate(
//               // Moves from 50 pixels down up to its original position
//               offset: Offset(0, 50 * (1 - value)),
//               child: child,
//             ),
//           );
//         },
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             bool isMobile = constraints.maxWidth < 800;
//             return Flex(
//               direction: isMobile ? Axis.vertical : Axis.horizontal,
//               children: [
//                 // Teal Side
//                 Expanded(
//                   flex: isMobile ? 2 : 1,
//                   child: Container(
//                     width: double.infinity,
//                     color: const Color(0xFF1E4D4A),
//                     padding: const EdgeInsets.all(40.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "ReMotion",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 60),
//                         const Text(
//                           "Hello,\nwelcome!",
//                           style: TextStyle(
//                             color: Color(0xFFFFB4A2),
//                             fontSize: 48,
//                             fontWeight: FontWeight.bold,
//                             height: 1.1,
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         const Text(
//                           "Manage your rehabilitation programs, track patient progress, and stay connected effectively.",
//                           style: TextStyle(color: Colors.white70, fontSize: 16),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Form Side
//                 Expanded(
//                   flex: isMobile ? 3 : 1,
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: isMobile ? 30 : 80,
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Center(
//                           child: Text(
//                             "Sign In",
//                             style: TextStyle(
//                               fontSize: 32,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 40),
//                         const Text(
//                           "Email address",
//                           style: TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                         const SizedBox(height: 8),
//                         TextField(
//                           decoration: InputDecoration(
//                             hintText: "name@mail.com",
//                             filled: true,
//                             fillColor: const Color(0xFFF1F5F5),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide.none,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         const Text(
//                           "Password",
//                           style: TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                         const SizedBox(height: 8),
//                         TextField(
//                           obscureText: true,
//                           decoration: InputDecoration(
//                             filled: true,
//                             fillColor: const Color(0xFFF1F5F5),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide.none,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 30),
//                         SizedBox(
//                           width: double.infinity,
//                           height: 55,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF1E4D4A),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             onPressed: () {
//                               Navigator.pushReplacement(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => const MainNavigation(),
//                                 ),
//                               );
//                             },
//                             child: const Text(
//                               "Sign In",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class MainNavigation extends StatefulWidget {
//   const MainNavigation({super.key});

//   @override
//   State<MainNavigation> createState() => _MainNavigationState();
// }

// class _MainNavigationState extends State<MainNavigation> {
//   int _selectedIndex = 0;

//   // These widgets come from your dashboard.dart, progress.dart, and schedule.dart
//   final List<Widget> _pages = [
//     const DashboardPage(),
//     const ProgressPage(),
//     const SchedulePage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(index: _selectedIndex, children: _pages),
//       bottomNavigationBar: NavigationBar(
//         backgroundColor: Colors.white,
//         indicatorColor: const Color(0xFF1E4D4A).withOpacity(0.1),
//         selectedIndex: _selectedIndex,
//         onDestinationSelected: (int index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//         destinations: const [
//           NavigationDestination(
//             icon: Icon(Icons.dashboard_outlined),
//             selectedIcon: Icon(Icons.dashboard, color: Color(0xFF1E4D4A)),
//             label: 'Dashboard',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.bar_chart_rounded),
//             selectedIcon: Icon(
//               Icons.bar_chart_rounded,
//               color: Color(0xFF1E4D4A),
//             ),
//             label: 'Progress',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.calendar_month_outlined),
//             selectedIcon: Icon(Icons.calendar_month, color: Color(0xFF1E4D4A)),
//             label: 'Schedule',
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Your existing imports
import 'dashboard.dart';
import 'progress.dart';
import 'schedule.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Ensure you've run 'flutterfire configure'
  runApp(const ReMotionApp());
}

class ReMotionApp extends StatelessWidget {
  const ReMotionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReMotion',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF1E4D4A),
        scaffoldBackgroundColor: Colors.white,
      ),
      // AUTH GATEKEEPER: Listens to login/logout events automatically
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return const MainNavigation(); // Logged in? Go to App
          }
          return const LoginPage(); // Logged out? Go to Login
        },
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // StreamBuilder will handle the navigation automatically
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Login Failed")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: child,
            ),
          );
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 800;
            return Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              children: [
                // Teal Branding Side
                Expanded(
                  flex: isMobile ? 2 : 1,
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFF1E4D4A),
                    padding: const EdgeInsets.all(40.0),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ReMotion",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 60),
                        Text(
                          "Hello,\nwelcome!",
                          style: TextStyle(
                            color: Color(0xFFFFB4A2),
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Manage your rehabilitation programs effectively.",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                // Login Form Side
                Expanded(
                  flex: isMobile ? 3 : 1,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 30 : 80,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          "Email address",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: "name@mail.com",
                            filled: true,
                            fillColor: const Color(0xFFF1F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Password",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF1F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E4D4A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isLoading ? null : _handleLogin,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Sign In",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Main Navigation Wrapper
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const DashboardPage(),
    const ProgressPage(),
    const SchedulePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ReMotion"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance
                .signOut(), // Logs out & triggers StreamBuilder
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Progress'),
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: 'Schedule',
          ),
        ],
      ),
    );
  }
}
