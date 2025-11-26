import 'package:flutter/material.dart';
import 'responsive_utils.dart';
import 'login_page.dart';
import 'services/api_service.dart';

class CleanerDashboard extends StatefulWidget {
  const CleanerDashboard({super.key});

  @override
  State<CleanerDashboard> createState() => _CleanerDashboardState();
}

class _CleanerDashboardState extends State<CleanerDashboard> {
  int _currentIndex = 0;

  // Dynamic data
  List<Map<String, dynamic>> assignedTasks = [];
  List<Map<String, dynamic>> completedTasks = [];
  Map<String, dynamic>? _cleanerUser;

  // Loading states
  bool _isLoadingTasks = true;
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadAssignedTasks(),
      _loadCompletedTasks(),
      _loadCleanerUser(),
    ]);
  }

  Future<void> _loadAssignedTasks() async {
    setState(() {
      _isLoadingTasks = true;
    });

    try {
      final bookingsList = await ApiService.getCleanerBookings();
      setState(() {
        // Filter for active tasks (assigned, in_progress)
        assignedTasks = bookingsList
            .where((b) => b['status'] == 'assigned' || b['status'] == 'in_progress' || b['status'] == 'pending')
            .map((b) => Map<String, dynamic>.from(b))
            .toList();
        _isLoadingTasks = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTasks = false;
      });
      _showError('Failed to load tasks: $e');
    }
  }

  Future<void> _loadCompletedTasks() async {
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final bookingsList = await ApiService.getCleanerBookings();
      setState(() {
        // Filter for completed tasks
        completedTasks = bookingsList
            .where((b) => b['status'] == 'completed')
            .map((b) => Map<String, dynamic>.from(b))
            .toList();
        _isLoadingHistory = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingHistory = false;
      });
      _showError('Failed to load history: $e');
    }
  }

  Future<void> _loadCleanerUser() async {
    try {
      final userData = await ApiService.getUserData();
      setState(() {
        _cleanerUser = userData;
      });
    } catch (e) {
      // Silently fail
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _startTask(String bookingId) async {
    try {
      await ApiService.updateBookingStatus(bookingId, 'in_progress');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task started!'),
          backgroundColor: Colors.blue,
        ),
      );
      await _loadAssignedTasks();
    } catch (e) {
      _showError('Failed to start task: $e');
    }
  }

  Future<void> _completeTask(String bookingId) async {
    try {
      await ApiService.updateBookingStatus(bookingId, 'completed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task marked as completed!'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadAssignedTasks();
      await _loadCompletedTasks();
    } catch (e) {
      _showError('Failed to complete task: $e');
    }
  }

  // Get user info
  String get _cleanerName => _cleanerUser?['name'] ?? "Cleaner";
  String? get _cleanerEmail => _cleanerUser?['email'];
  String? get _cleanerPhone => _cleanerUser?['phone'];
  String? get _cleanerAddress => _cleanerUser?['address'];

  // Format date for display
  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  // Get image based on service category
  String _getServiceImage(Map<String, dynamic> booking) {
    final category = booking['service']?['category'] ?? '';
    switch (category) {
      case 'house-cleaning':
        return 'assets/cleaning.jpg';
      case 'house-painting':
        return 'assets/house.jpg';
      case 'carpet-cleaning':
        return 'assets/carpet.jpg';
      case 'sanitary-cleaning':
        return 'assets/drapery.jpg';
      default:
        return 'assets/cleaning.jpg';
    }
  }

  // ---------------- TASKS BODY ----------------
  Widget _tasksBody() {
    final responsive = context.responsive;
    final activeTasks = assignedTasks.where((t) => t['status'] != 'completed').toList();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadAssignedTasks,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                          "Your assigned jobs",
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
                        "${activeTasks.length} Active",
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
                _isLoadingTasks
                    ? const Center(child: CircularProgressIndicator())
                    : assignedTasks.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(responsive.spacing(40)),
                              child: Column(
                                children: [
                                  Icon(Icons.assignment_outlined, size: 60, color: Colors.grey.shade400),
                                  SizedBox(height: responsive.spacing(12)),
                                  Text(
                                    "No tasks assigned yet",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: responsive.responsiveFontSize(16),
                                    ),
                                  ),
                                  SizedBox(height: responsive.spacing(8)),
                                  Text(
                                    "Tasks will appear here when admin assigns them to you",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: responsive.responsiveFontSize(13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: assignedTasks.length,
                            itemBuilder: (context, index) {
                              final task = assignedTasks[index];
                              return _taskCard(task, responsive);
                            },
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _taskCard(Map<String, dynamic> booking, ResponsiveUtils responsive) {
    final service = booking['service'] as Map<String, dynamic>?;
    final customer = booking['customer'] as Map<String, dynamic>?;
    final status = booking['status'] ?? 'pending';
    final title = service?['title'] ?? 'Unknown Service';
    final address = booking['address'] ?? 'N/A';
    final bookingTime = booking['bookingTime'] ?? 'N/A';
    final bookingDate = _formatDate(booking['bookingDate']);
    final customerName = customer?['name'] ?? booking['customerName'] ?? 'Unknown';
    final customerPhone = booking['phone'] ?? customer?['phone'] ?? 'N/A';
    final price = booking['total'] ?? service?['basePrice'] ?? 0;

    Color statusColor;
    String statusText;

    switch (status) {
      case 'completed':
        statusColor = Colors.green;
        statusText = 'COMPLETED';
        break;
      case 'in_progress':
        statusColor = Colors.orange;
        statusText = 'IN PROGRESS';
        break;
      case 'assigned':
        statusColor = Colors.blue;
        statusText = 'ASSIGNED';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'PENDING';
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
          // Header with service image and title
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  _getServiceImage(booking),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: responsive.spacing(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: responsive.responsiveFontSize(16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: responsive.spacing(4)),
                    Text(
                      booking['bookingId'] ?? '',
                      style: TextStyle(
                        fontSize: responsive.responsiveFontSize(12),
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.spacing(10),
                  vertical: responsive.spacing(4),
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: responsive.responsiveFontSize(10),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: responsive.spacing(16)),

          // Details
          Container(
            padding: EdgeInsets.all(responsive.spacing(12)),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _detailRow(Icons.person, "Customer", customerName, responsive),
                SizedBox(height: responsive.spacing(8)),
                _detailRow(Icons.phone, "Phone", customerPhone, responsive),
                SizedBox(height: responsive.spacing(8)),
                _detailRow(Icons.location_on, "Address", address, responsive),
                SizedBox(height: responsive.spacing(8)),
                _detailRow(Icons.calendar_today, "Date", bookingDate, responsive),
                SizedBox(height: responsive.spacing(8)),
                _detailRow(Icons.access_time, "Time", bookingTime, responsive),
              ],
            ),
          ),

          SizedBox(height: responsive.spacing(12)),

          // Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Payment:",
                style: TextStyle(
                  fontSize: responsive.responsiveFontSize(14),
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                "NPR $price",
                style: TextStyle(
                  fontSize: responsive.responsiveFontSize(16),
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),

          SizedBox(height: responsive.spacing(16)),

          // Action Buttons
          if (status == 'assigned')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _startTask(booking['_id']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: responsive.spacing(12)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: Text(
                  'Start Task',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.responsiveFontSize(14),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          if (status == 'in_progress')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _completeTask(booking['_id']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: responsive.spacing(12)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: Text(
                  'Mark Complete',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.responsiveFontSize(14),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, ResponsiveUtils responsive) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        SizedBox(width: responsive.spacing(8)),
        Text(
          "$label: ",
          style: TextStyle(
            fontSize: responsive.responsiveFontSize(13),
            color: Colors.grey.shade600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: responsive.responsiveFontSize(13),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- ACTIVITY BODY ----------------
  Widget _activityBody() {
    final responsive = context.responsive;

    // Calculate stats
    final totalCompleted = completedTasks.length;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadCompletedTasks,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                  "Your completed tasks",
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
                      child: _statBox("Completed", totalCompleted.toString(), Colors.green, responsive),
                    ),
                    SizedBox(width: responsive.spacing(12)),
                    Expanded(
                      child: _statBox("Active", assignedTasks.length.toString(), Colors.blue, responsive),
                    ),
                  ],
                ),

                SizedBox(height: responsive.spacing(25)),

                _isLoadingHistory
                    ? const Center(child: CircularProgressIndicator())
                    : completedTasks.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(responsive.spacing(40)),
                              child: Column(
                                children: [
                                  Icon(Icons.history, size: 60, color: Colors.grey.shade400),
                                  SizedBox(height: responsive.spacing(12)),
                                  Text(
                                    "No completed tasks yet",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: responsive.responsiveFontSize(16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: completedTasks.length,
                            itemBuilder: (context, index) {
                              final task = completedTasks[index];
                              return _activityCard(task, responsive);
                            },
                          ),
              ],
            ),
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

  Widget _activityCard(Map<String, dynamic> booking, ResponsiveUtils responsive) {
    final service = booking['service'] as Map<String, dynamic>?;
    final title = service?['title'] ?? 'Unknown Service';
    final completedDate = _formatDate(booking['completedAt'] ?? booking['updatedAt']);
    final price = booking['total'] ?? service?['basePrice'] ?? 0;

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
                  title,
                  style: TextStyle(
                    fontSize: responsive.responsiveFontSize(15),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: responsive.spacing(4)),
                Text(
                  completedDate,
                  style: TextStyle(
                    fontSize: responsive.responsiveFontSize(13),
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "NPR $price",
            style: TextStyle(
              fontSize: responsive.responsiveFontSize(14),
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
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
                  Icons.cleaning_services,
                  size: responsive.profileAvatarRadius * 1.2,
                  color: Colors.green.shade900,
                ),
              ),

              SizedBox(height: responsive.spacing(20)),

              Text(
                _cleanerName,
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

              SizedBox(height: responsive.spacing(20)),

              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _miniStat("Completed", completedTasks.length.toString(), Colors.green, responsive),
                  SizedBox(width: responsive.spacing(20)),
                  _miniStat("Active", assignedTasks.length.toString(), Colors.blue, responsive),
                ],
              ),

              SizedBox(height: responsive.spacing(30)),

              _infoRow(Icons.email, "Email", _cleanerEmail ?? "Not provided", responsive),
              SizedBox(height: responsive.spacing(12)),
              _infoRow(Icons.phone, "Phone", _cleanerPhone ?? "Not provided", responsive),
              SizedBox(height: responsive.spacing(12)),
              _infoRow(Icons.location_on, "Address", _cleanerAddress ?? "Not provided", responsive),

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
                onPressed: () async {
                  await ApiService.clearAllData();
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Loginpage()),
                    );
                  }
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

  Widget _miniStat(String label, String value, Color color, ResponsiveUtils responsive) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(responsive.spacing(12)),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: responsive.responsiveFontSize(20),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        SizedBox(height: responsive.spacing(6)),
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.responsiveFontSize(12),
            color: Colors.grey.shade600,
          ),
        ),
      ],
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
      BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
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
