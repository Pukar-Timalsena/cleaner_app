import 'package:flutter/material.dart';
import 'responsive_utils.dart';
import 'login_page.dart';

class CleanerDashboard extends StatefulWidget {
  const CleanerDashboard({super.key});

  @override
  State<CleanerDashboard> createState() => _CleanerDashboardState();
}

class _CleanerDashboardState extends State<CleanerDashboard> {
  int _currentIndex = 0;

  List<Map<String, dynamic>> assignedTasks = [
    {
      "title": "Clean Lobby",
      "location": "Building A, Floor 1",
      "status": "Ongoing",
      "priority": "High",
      "time": "2:00 PM - 4:00 PM",
      "customer": "John Smith"
    },
    {
      "title": "Clean Room 102",
      "location": "Building B, Floor 1",
      "status": "Pending",
      "priority": "Medium",
      "time": "4:30 PM - 6:00 PM",
      "customer": "Sarah Johnson"
    },
    {
      "title": "Carpet Cleaning",
      "location": "Building A, Floor 3",
      "status": "Completed",
      "priority": "Low",
      "time": "10:00 AM - 12:00 PM",
      "customer": "Mike Davis"
    },
  ];

  List<Map<String, dynamic>> activityHistory = [
    {"task": "Window Cleaning", "date": "2024-11-20", "rating": 4.5},
    {"task": "Floor Mopping", "date": "2024-11-19", "rating": 5.0},
    {"task": "Bathroom Cleaning", "date": "2024-11-18", "rating": 4.8},
    {"task": "Kitchen Cleaning", "date": "2024-11-17", "rating": 4.7},
  ];

  Map<String, String> profile = {
    "Name": "Jane Cleaner",
    "Email": "cleaner@test.com",
    "Phone": "+977 9812345678",
    "Address": "Kathmandu, Nepal",
    "Experience": "3 years",
  };

  void _completeTask(int index) {
    setState(() {
      assignedTasks[index]['status'] = 'Completed';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task marked as completed!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ---------------- TASKS BODY ----------------
  Widget _tasksBody() {
    final responsive = context.responsive;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(responsive.spacing(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "My Tasks",
                        style: TextStyle(
                          fontSize: responsive.responsiveFontSize(24),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: responsive.spacing(4)),
                      Text(
                        "Today's assignments",
                        style: TextStyle(
                          fontSize: responsive.responsiveFontSize(14),
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(responsive.spacing(8)),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${assignedTasks.where((t) => t['status'] != 'Completed').length} Active",
                      style: TextStyle(
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: responsive.responsiveFontSize(14),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: responsive.spacing(25)),

              // Task Cards
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: assignedTasks.length,
                itemBuilder: (context, index) {
                  final task = assignedTasks[index];
                  return _taskCard(task, index, responsive);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _taskCard(Map<String, dynamic> task, int index, ResponsiveUtils responsive) {
    Color statusColor;
    Color priorityColor;

    switch (task['status']) {
      case 'Completed':
        statusColor = Colors.green;
        break;
      case 'Ongoing':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.blue;
    }

    switch (task['priority']) {
      case 'High':
        priorityColor = Colors.red;
        break;
      case 'Medium':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.grey;
    }

    return Container(
      margin: EdgeInsets.only(bottom: responsive.spacing(16)),
      padding: EdgeInsets.all(responsive.spacing(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  task['title'],
                  style: TextStyle(
                    fontSize: responsive.responsiveFontSize(16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.spacing(10),
                  vertical: responsive.spacing(4),
                ),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: priorityColor),
                ),
                child: Text(
                  task['priority'],
                  style: TextStyle(
                    color: priorityColor,
                    fontSize: responsive.responsiveFontSize(11),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: responsive.spacing(12)),

          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
              SizedBox(width: responsive.spacing(4)),
              Text(
                task['location'],
                style: TextStyle(
                  fontSize: responsive.responsiveFontSize(13),
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          SizedBox(height: responsive.spacing(6)),

          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
              SizedBox(width: responsive.spacing(4)),
              Text(
                task['time'],
                style: TextStyle(
                  fontSize: responsive.responsiveFontSize(13),
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          SizedBox(height: responsive.spacing(6)),

          Row(
            children: [
              Icon(Icons.person, size: 16, color: Colors.grey.shade600),
              SizedBox(width: responsive.spacing(4)),
              Text(
                "Customer: ${task['customer']}",
                style: TextStyle(
                  fontSize: responsive.responsiveFontSize(13),
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          SizedBox(height: responsive.spacing(16)),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: responsive.spacing(8)),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor),
                  ),
                  child: Center(
                    child: Text(
                      task['status'],
                      style: TextStyle(
                        color: statusColor,
                        fontSize: responsive.responsiveFontSize(13),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              if (task['status'] != 'Completed') ...[
                SizedBox(width: responsive.spacing(12)),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _completeTask(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: responsive.spacing(8)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Complete',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsive.responsiveFontSize(13),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- ACTIVITY BODY ----------------
  Widget _activityBody() {
    final responsive = context.responsive;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(responsive.spacing(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Activity History",
                style: TextStyle(
                  fontSize: responsive.responsiveFontSize(22),
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: responsive.spacing(10)),

              Text(
                "Your completed tasks and ratings",
                style: TextStyle(
                  fontSize: responsive.responsiveFontSize(14),
                  color: Colors.grey.shade600,
                ),
              ),

              SizedBox(height: responsive.spacing(20)),

              // Stats Summary
              Row(
                children: [
                  Expanded(
                    child: _statBox("Total Tasks", "24", Colors.blue, responsive),
                  ),
                  SizedBox(width: responsive.spacing(12)),
                  Expanded(
                    child: _statBox("Avg Rating", "4.8", Colors.orange, responsive),
                  ),
                ],
              ),

              SizedBox(height: responsive.spacing(25)),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activityHistory.length,
                itemBuilder: (context, index) {
                  final activity = activityHistory[index];
                  return _activityCard(activity, responsive);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statBox(String label, String value, Color color, ResponsiveUtils responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: responsive.responsiveFontSize(28),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: responsive.spacing(4)),
          Text(
            label,
            style: TextStyle(
              fontSize: responsive.responsiveFontSize(13),
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityCard(Map<String, dynamic> activity, ResponsiveUtils responsive) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive.spacing(12)),
      padding: EdgeInsets.all(responsive.spacing(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(responsive.spacing(12)),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.check_circle, color: Colors.green, size: 24),
          ),
          SizedBox(width: responsive.spacing(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['task'],
                  style: TextStyle(
                    fontSize: responsive.responsiveFontSize(15),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: responsive.spacing(4)),
                Text(
                  activity['date'],
                  style: TextStyle(
                    fontSize: responsive.responsiveFontSize(13),
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(Icons.star, color: Colors.orange, size: 18),
              SizedBox(width: responsive.spacing(4)),
              Text(
                activity['rating'].toString(),
                style: TextStyle(
                  fontSize: responsive.responsiveFontSize(14),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- PROFILE BODY ----------------
  Widget _profileBody() {
    final responsive = context.responsive;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(responsive.spacing(24)),
          child: Column(
            children: [
              SizedBox(height: responsive.spacing(20)),
              
              CircleAvatar(
                radius: responsive.profileAvatarRadius * 1.5,
                backgroundColor: Colors.green.shade200,
                child: Icon(
                  Icons.person,
                  size: responsive.profileAvatarRadius * 1.2,
                  color: Colors.green.shade900,
                ),
              ),

              SizedBox(height: responsive.spacing(20)),

              Text(
                profile['Name']!,
                style: TextStyle(
                    fontSize: responsive.responsiveFontSize(26),
                    fontWeight: FontWeight.bold),
              ),

              SizedBox(height: responsive.spacing(10)),

              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 16, vertical: responsive.spacing(6)),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Text(
                  "Professional Cleaner",
                  style: TextStyle(
                      color: Colors.green.shade900,
                      fontSize: responsive.responsiveFontSize(16),
                      fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(height: responsive.spacing(30)),

              _infoRow(Icons.email, "Email", profile['Email']!, responsive),
              SizedBox(height: responsive.spacing(12)),
              _infoRow(Icons.phone, "Phone", profile['Phone']!, responsive),
              SizedBox(height: responsive.spacing(12)),
              _infoRow(Icons.location_on, "Address", profile['Address']!, responsive),
              SizedBox(height: responsive.spacing(12)),
              _infoRow(Icons.work, "Experience", profile['Experience']!, responsive),

              SizedBox(height: responsive.spacing(30)),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(
                      horizontal: responsive.spacing(30),
                      vertical: responsive.spacing(15)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Loginpage()),
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: Text(
                  "Log Out",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.responsiveFontSize(16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, ResponsiveUtils responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(12)),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green.shade900),
          SizedBox(width: responsive.spacing(10)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500)),
              Text(value,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  // ---------------- MAIN UI ----------------
  @override
  Widget build(BuildContext context) {
    final List<BottomNavigationBarItem> navItems = const [
      BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Tasks"),
      BottomNavigationBarItem(icon: Icon(Icons.history), label: "Activity"),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
    ];

    final pages = [
      _tasksBody(),
      _activityBody(),
      _profileBody(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: navItems,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
