import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'responsive_utils.dart';
import 'login_page.dart';
import 'services/api_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  // Dashboard stats - now dynamic
  int totalUsers = 0;
  int totalCleaners = 0;
  int totalServices = 0;
  int activeBookings = 0;
  int completedBookings = 0;
  double totalRevenue = 0;

  // Dynamic data lists
  List<Map<String, dynamic>> bookings = [];
  List<Map<String, dynamic>> cleaners = [];

  // Loading states
  bool _isLoadingDashboard = true;
  bool _isLoadingBookings = true;
  bool _isLoadingCleaners = true;

  // Admin user data
  Map<String, dynamic>? _adminUser;

  // Service upload controllers
  final TextEditingController _featureController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;
  final picker = ImagePicker();
  bool _isUploading = false;
  String? _selectedCategory;

  // Services list state
  bool _showAddServiceForm = false;
  List<Map<String, dynamic>> _servicesList = [];
  bool _isLoadingServices = true;

  final List<Map<String, String>> _categories = [
    {'value': 'house-cleaning', 'label': 'House Cleaning'},
    {'value': 'carpet-cleaning', 'label': 'Carpet Cleaning'},
    {'value': 'window-cleaning', 'label': 'Window Cleaning'},
    {'value': 'sanitary-cleaning', 'label': 'Sanitary Cleaning'},
    {'value': 'house-painting', 'label': 'House Painting'},
    {'value': 'other', 'label': 'Other'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadDashboardStats(),
      _loadBookings(),
      _loadCleaners(),
      _loadAdminUser(),
      _loadServicesList(),
    ]);
  }

  Future<void> _loadServicesList() async {
    try {
      final services = await ApiService.getServices();
      setState(() {
        _servicesList = services.map((s) => Map<String, dynamic>.from(s)).toList();
        _isLoadingServices = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingServices = false;
      });
      _showError('Failed to load services: $e');
    }
  }

  Future<void> _loadDashboardStats() async {
    try {
      final stats = await ApiService.getDashboardStats();
      setState(() {
        totalUsers = stats['totalUsers'] ?? 0;
        totalCleaners = stats['totalCleaners'] ?? 0;
        totalServices = stats['totalServices'] ?? 0;
        activeBookings = stats['activeBookings'] ?? 0;
        completedBookings = stats['completedBookings'] ?? 0;
        totalRevenue = (stats['totalRevenue'] ?? 0).toDouble();
        _isLoadingDashboard = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingDashboard = false;
      });
      _showError('Failed to load dashboard stats: $e');
    }
  }

  Future<void> _loadBookings() async {
    try {
      final bookingsList = await ApiService.getAdminBookings();
      setState(() {
        bookings = bookingsList.map((b) => Map<String, dynamic>.from(b)).toList();
        _isLoadingBookings = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingBookings = false;
      });
      _showError('Failed to load bookings: $e');
    }
  }

  Future<void> _loadCleaners() async {
    try {
      final cleanersList = await ApiService.getCleaners();
      setState(() {
        cleaners = cleanersList.map((c) => Map<String, dynamic>.from(c)).toList();
        _isLoadingCleaners = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCleaners = false;
      });
      _showError('Failed to load cleaners: $e');
    }
  }

  Future<void> _loadAdminUser() async {
    try {
      final userData = await ApiService.getUserData();
      setState(() {
        _adminUser = userData;
      });
    } catch (e) {
      // Silently fail - user data might not be available
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

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadFeature() async {
    if (_featureController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final price = int.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      await ApiService.createService(
        title: _featureController.text,
        description: _descriptionController.text,
        category: _selectedCategory!,
        basePrice: price,
        image: _image?.path,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Service "${_featureController.text}" uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      _featureController.clear();
      _descriptionController.clear();
      _priceController.clear();
      setState(() {
        _image = null;
        _selectedCategory = null;
        _showAddServiceForm = false; // Go back to services list
      });

      // Refresh dashboard stats and services list
      _loadDashboardStats();
      _loadServicesList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _assignCleaner(String bookingId, String cleanerId) async {
    try {
      await ApiService.assignCleanerToBooking(bookingId, cleanerId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cleaner assigned successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh bookings and dashboard
      await _loadBookings();
      await _loadDashboardStats();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to assign cleaner: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _featureController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ---------------- DASHBOARD BODY ----------------
  Widget _dashboardBody() {
    final responsive = context.responsive;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await _loadDashboardStats();
          await _loadBookings();
        },
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
                          "Admin Dashboard",
                          style: TextStyle(
                            fontSize: responsive.responsiveFontSize(24),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: responsive.spacing(4)),
                        Text(
                          "Manage your cleaning service",
                          style: TextStyle(
                            fontSize: responsive.responsiveFontSize(14),
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh, size: responsive.responsiveFontSize(28)),
                      onPressed: () async {
                        setState(() {
                          _isLoadingDashboard = true;
                        });
                        await _loadDashboardStats();
                      },
                    ),
                  ],
                ),

                SizedBox(height: responsive.spacing(25)),

                // Stats Cards Grid
                _isLoadingDashboard
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: responsive.isMobile ? 2 : 4,
                        crossAxisSpacing: responsive.spacing(15),
                        mainAxisSpacing: responsive.spacing(15),
                        childAspectRatio: responsive.isMobile ? 1.3 : 1.5,
                        children: [
                          _statCard("Total Users", totalUsers.toString(), Icons.people, Colors.blue, responsive),
                          _statCard("Cleaners", totalCleaners.toString(), Icons.cleaning_services, Colors.green, responsive),
                          _statCard("Services", totalServices.toString(), Icons.home_repair_service, Colors.orange, responsive),
                          _statCard("Active Bookings", activeBookings.toString(), Icons.book_online, Colors.purple, responsive),
                        ],
                      ),

                SizedBox(height: responsive.spacing(20)),

                // Revenue Card
                if (!_isLoadingDashboard)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(responsive.spacing(16)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal, Colors.teal.shade300],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Revenue",
                              style: TextStyle(
                                fontSize: responsive.responsiveFontSize(14),
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            SizedBox(height: responsive.spacing(4)),
                            Text(
                              "NPR ${totalRevenue.toStringAsFixed(0)}",
                              style: TextStyle(
                                fontSize: responsive.responsiveFontSize(28),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Completed",
                              style: TextStyle(
                                fontSize: responsive.responsiveFontSize(12),
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            Text(
                              "$completedBookings bookings",
                              style: TextStyle(
                                fontSize: responsive.responsiveFontSize(16),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: responsive.spacing(30)),

                // Recent Bookings
                Text(
                  "Recent Bookings",
                  style: TextStyle(
                    fontSize: responsive.responsiveFontSize(18),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: responsive.spacing(15)),

                _isLoadingBookings
                    ? const Center(child: CircularProgressIndicator())
                    : bookings.isEmpty
                        ? Center(
                            child: Text(
                              "No bookings yet",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: responsive.responsiveFontSize(14),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: bookings.length > 5 ? 5 : bookings.length,
                            itemBuilder: (context, index) {
                              final booking = bookings[index];
                              return _recentBookingCard(booking, responsive);
                            },
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, String count, IconData icon, Color color, ResponsiveUtils responsive) {
    return GestureDetector(
      onTap: () async {
        // Show details when stat card is tapped
        if (title == "Total Users") {
          await _showUsersDialog(title);
        } else if (title == "Cleaners") {
          await _showUsersDialog(title);
        } else if (title == "Services") {
          await _showServicesDialog();
        } else if (title == "Active Bookings") {
          await _showActiveBookingsDialog();
        }
      },
      child: Container(
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
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: responsive.responsiveFontSize(32)),
            SizedBox(height: responsive.spacing(8)),
            Text(
              count,
              style: TextStyle(
                fontSize: responsive.responsiveFontSize(24),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: responsive.spacing(4)),
            Text(
              title,
              style: TextStyle(
                fontSize: responsive.responsiveFontSize(12),
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Show users/cleaners dialog
  Future<void> _showUsersDialog(String title) async {
    try {
      List<dynamic> usersList;
      if (title == "Total Users") {
        usersList = await ApiService.getUsers(role: 'customer');
      } else {
        usersList = await ApiService.getUsers(role: 'cleaner');
      }

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: usersList.isEmpty
                      ? const Center(child: Text("No users found"))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: usersList.length,
                          itemBuilder: (context, index) {
                            final user = usersList[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              title: Text(user['name'] ?? 'Unknown'),
                              subtitle: Text(user['email'] ?? 'No email'),
                              trailing: user['phone'] != null
                                  ? Text(
                                      user['phone'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    )
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      _showError('Failed to load users: $e');
    }
  }

  // Show services dialog
  Future<void> _showServicesDialog() async {
    print('DEBUG: _showServicesDialog called');
    try {
      print('DEBUG: Fetching services...');
      final servicesList = await ApiService.getServices();
      print('DEBUG: Services fetched: ${servicesList.length} items');

      if (!mounted) {
        print('DEBUG: Widget not mounted, returning');
        return;
      }

      print('DEBUG: Showing dialog...');
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Services",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: servicesList.isEmpty
                      ? const Center(child: Text("No services found"))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: servicesList.length,
                          itemBuilder: (context, index) {
                            final service = servicesList[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange.shade100,
                                child: Icon(
                                  Icons.home_repair_service,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                              title: Text(service['title'] ?? 'Unknown'),
                              subtitle: Text(service['category'] ?? 'No category'),
                              trailing: Text(
                                'NPR ${service['basePrice'] ?? 0}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      print('DEBUG: Error in _showServicesDialog: $e');
      _showError('Failed to load services: $e');
    }
  }

  // Show active bookings dialog
  Future<void> _showActiveBookingsDialog() async {
    print('DEBUG: _showActiveBookingsDialog called');
    try {
      print('DEBUG: Filtering active bookings from ${bookings.length} total bookings');
      final activeBookingsList = bookings.where((b) {
        final status = b['status'];
        return status == 'pending' || status == 'assigned' || status == 'in_progress';
      }).toList();
      print('DEBUG: Found ${activeBookingsList.length} active bookings');

      if (!mounted) {
        print('DEBUG: Widget not mounted, returning');
        return;
      }

      print('DEBUG: Showing active bookings dialog...');
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Active Bookings",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: activeBookingsList.isEmpty
                      ? const Center(child: Text("No active bookings"))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: activeBookingsList.length,
                          itemBuilder: (context, index) {
                            final booking = activeBookingsList[index];
                            final service = booking['service'] as Map<String, dynamic>?;
                            final customer = booking['customer'] as Map<String, dynamic>?;
                            final status = booking['status'] ?? 'pending';
                            
                            Color statusColor = status == 'assigned' || status == 'in_progress'
                                ? Colors.orange
                                : Colors.grey;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.purple.shade100,
                                child: Icon(
                                  Icons.book_online,
                                  color: Colors.purple.shade700,
                                ),
                              ),
                              title: Text(service?['title'] ?? 'Unknown Service'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Customer: ${customer?['name'] ?? 'Unknown'}'),
                                  Text(
                                    'ID: ${booking['bookingId'] ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: statusColor),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                              isThreeLine: true,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      print('DEBUG: Error in _showActiveBookingsDialog: $e');
      _showError('Failed to load active bookings: $e');
    }
  }

  Widget _recentBookingCard(Map<String, dynamic> booking, ResponsiveUtils responsive) {
    final service = booking['service'] as Map<String, dynamic>?;
    final customer = booking['customer'] as Map<String, dynamic>?;
    final status = booking['status'] ?? 'pending';

    Color statusColor;
    switch (status) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'in_progress':
      case 'assigned':
        statusColor = Colors.orange;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

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
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: responsive.spacing(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service?['title'] ?? 'Unknown Service',
                  style: TextStyle(
                    fontSize: responsive.responsiveFontSize(15),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: responsive.spacing(4)),
                Text(
                  "Customer: ${customer?['name'] ?? 'Unknown'}",
                  style: TextStyle(
                    fontSize: responsive.responsiveFontSize(13),
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: responsive.spacing(2)),
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
              horizontal: responsive.spacing(12),
              vertical: responsive.spacing(6),
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor),
            ),
            child: Text(
              status.toString().replaceAll('_', ' ').toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontSize: responsive.responsiveFontSize(11),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- SERVICES BODY ----------------
  Widget _servicesBody() {
    final responsive = context.responsive;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(responsive.spacing(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and Add Service button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (_showAddServiceForm)
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            setState(() {
                              _showAddServiceForm = false;
                            });
                          },
                        ),
                      Text(
                        _showAddServiceForm ? "Add New Service" : "Services List",
                        style: TextStyle(
                          fontSize: responsive.responsiveFontSize(22),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (!_showAddServiceForm)
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showAddServiceForm = true;
                        });
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Add Service",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: responsive.spacing(16)),

              // Show either services list or add service form
              if (!_showAddServiceForm) ...[
                // Services List
                _isLoadingServices
                    ? const Center(child: CircularProgressIndicator())
                    : _servicesList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: responsive.spacing(40)),
                                Icon(Icons.home_repair_service, size: 60, color: Colors.grey.shade400),
                                SizedBox(height: responsive.spacing(12)),
                                Text(
                                  "No services yet",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: responsive.responsiveFontSize(16),
                                  ),
                                ),
                                SizedBox(height: responsive.spacing(8)),
                                Text(
                                  "Click 'Add Service' to create your first service",
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: responsive.responsiveFontSize(14),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _servicesList.length,
                            itemBuilder: (context, index) {
                              final service = _servicesList[index];
                              return _serviceCard(service, responsive);
                            },
                          ),
              ] else ...[
                // Add Service Form
                Container(
                  padding: EdgeInsets.all(responsive.spacing(12)),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                      SizedBox(width: responsive.spacing(8)),
                      Expanded(
                        child: Text(
                          "Add new cleaning services to your platform. Fill in all details and upload a high-quality image.",
                          style: TextStyle(
                            fontSize: responsive.responsiveFontSize(12),
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: responsive.spacing(20)),

              Container(
                padding: EdgeInsets.all(responsive.spacing(20)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Name Field
                    Text(
                      "Service Name *",
                      style: TextStyle(
                        fontSize: responsive.responsiveFontSize(13),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: responsive.spacing(6)),
                    TextField(
                      controller: _featureController,
                      decoration: InputDecoration(
                        hintText: 'e.g., House Cleaning, Carpet Cleaning',
                        hintStyle: TextStyle(fontSize: responsive.responsiveFontSize(13)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.home_repair_service),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),

                    SizedBox(height: responsive.spacing(16)),

                    // Description Field
                    Text(
                      "Service Description *",
                      style: TextStyle(
                        fontSize: responsive.responsiveFontSize(13),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: responsive.spacing(6)),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Describe the service details, what\'s included, duration, etc.',
                        hintStyle: TextStyle(fontSize: responsive.responsiveFontSize(13)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.description),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),

                    SizedBox(height: responsive.spacing(16)),

                    // Price Field
                    Text(
                      "Price (NPR) *",
                      style: TextStyle(
                        fontSize: responsive.responsiveFontSize(13),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: responsive.spacing(6)),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'e.g., 1500',
                        hintStyle: TextStyle(fontSize: responsive.responsiveFontSize(13)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.attach_money),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),

                    SizedBox(height: responsive.spacing(16)),

                    // Category Field
                    Text(
                      "Category *",
                      style: TextStyle(
                        fontSize: responsive.responsiveFontSize(13),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: responsive.spacing(6)),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        hintText: 'Select a category',
                        hintStyle: TextStyle(fontSize: responsive.responsiveFontSize(13)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.category),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['value'],
                          child: Text(category['label']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),

                    SizedBox(height: responsive.spacing(20)),

                    // Image Upload Section
                    Text(
                      "Service Image (Optional)",
                      style: TextStyle(
                        fontSize: responsive.responsiveFontSize(14),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: responsive.spacing(6)),
                    Text(
                      "Upload a clear, high-quality image (recommended: 800x600px)",
                      style: TextStyle(
                        fontSize: responsive.responsiveFontSize(11),
                        color: Colors.grey.shade600,
                      ),
                    ),

                    SizedBox(height: responsive.spacing(12)),

                    if (_image != null)
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade300, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        ),
                      )
                    else
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400, width: 2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload, size: 60, color: Colors.grey.shade400),
                            SizedBox(height: responsive.spacing(8)),
                            Text(
                              'No image selected',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: responsive.responsiveFontSize(14),
                              ),
                            ),
                            SizedBox(height: responsive.spacing(4)),
                            Text(
                              'Click below to select an image',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: responsive.responsiveFontSize(12),
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: responsive.spacing(16)),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_library, color: Colors.white),
                            label: Text(
                              _image == null ? 'Select Image' : 'Change Image',
                              style: const TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(vertical: responsive.spacing(14)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: responsive.spacing(12)),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isUploading ? null : _uploadFeature,
                            icon: _isUploading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.upload, color: Colors.white),
                            label: Text(
                              _isUploading ? 'Uploading...' : 'Upload Service',
                              style: const TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isUploading ? Colors.grey : Colors.green,
                              padding: EdgeInsets.symmetric(vertical: responsive.spacing(14)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ], // End of else block for add service form
            ],
          ),
        ),
      ),
    );
  }

  // Service card widget for the services list
  Widget _serviceCard(Map<String, dynamic> service, ResponsiveUtils responsive) {
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
          // Service image or icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: service['image'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      service['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.home_repair_service,
                        color: Colors.orange.shade700,
                        size: 30,
                      ),
                    ),
                  )
                : Icon(
                    Icons.home_repair_service,
                    color: Colors.orange.shade700,
                    size: 30,
                  ),
          ),
          SizedBox(width: responsive.spacing(12)),
          // Service details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service['title'] ?? 'Unknown Service',
                  style: TextStyle(
                    fontSize: responsive.responsiveFontSize(15),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: responsive.spacing(4)),
                Text(
                  service['category'] ?? 'No category',
                  style: TextStyle(
                    fontSize: responsive.responsiveFontSize(12),
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Price
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.spacing(12),
              vertical: responsive.spacing(6),
            ),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'NPR ${service['basePrice'] ?? 0}',
              style: TextStyle(
                fontSize: responsive.responsiveFontSize(13),
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
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
                backgroundColor: Colors.blue.shade200,
                child: Icon(
                  Icons.admin_panel_settings,
                  size: responsive.profileAvatarRadius * 1.2,
                  color: Colors.blue.shade900,
                ),
              ),

              SizedBox(height: responsive.spacing(20)),

              Text(
                _adminUser?['name'] ?? "Admin User",
                style: TextStyle(
                    fontSize: responsive.responsiveFontSize(26),
                    fontWeight: FontWeight.bold),
              ),

              SizedBox(height: responsive.spacing(10)),

              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 16, vertical: responsive.spacing(6)),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade300),
                ),
                child: Text(
                  "Administrator",
                  style: TextStyle(
                      color: Colors.blue.shade900,
                      fontSize: responsive.responsiveFontSize(16),
                      fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(height: responsive.spacing(30)),

              _infoRow(Icons.email, "Email", _adminUser?['email'] ?? "admin@test.com", responsive),
              SizedBox(height: responsive.spacing(12)),
              _infoRow(Icons.phone, "Phone", _adminUser?['phone'] ?? "+977 9876543210", responsive),
              SizedBox(height: responsive.spacing(12)),
              _infoRow(Icons.location_on, "Address", _adminUser?['address'] ?? "Kathmandu, Nepal", responsive),

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
          Icon(icon, color: Colors.blue.shade900),
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

  // ---------------- BOOKINGS BODY ----------------
  Widget _bookingsBody() {
    final responsive = context.responsive;

    final pendingCount = bookings.where((b) => b['status'] == 'pending').length;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await _loadBookings();
          await _loadCleaners();
        },
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
                          "Customer Bookings",
                          style: TextStyle(
                            fontSize: responsive.responsiveFontSize(24),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: responsive.spacing(4)),
                        Text(
                          "Assign cleaners to customer bookings",
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
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "$pendingCount Pending",
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: responsive.responsiveFontSize(14),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: responsive.spacing(10)),

                // Instructions
                Container(
                  padding: EdgeInsets.all(responsive.spacing(12)),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                      SizedBox(width: responsive.spacing(8)),
                      Expanded(
                        child: Text(
                          "Review customer bookings and assign available cleaners to each task.",
                          style: TextStyle(
                            fontSize: responsive.responsiveFontSize(12),
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: responsive.spacing(20)),

                // Booking Cards
                _isLoadingBookings
                    ? const Center(child: CircularProgressIndicator())
                    : bookings.isEmpty
                        ? Center(
                            child: Column(
                              children: [
                                Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade400),
                                SizedBox(height: responsive.spacing(12)),
                                Text(
                                  "No bookings yet",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: responsive.responsiveFontSize(16),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: bookings.length,
                            itemBuilder: (context, index) {
                              final booking = bookings[index];
                              return _bookingCard(booking, responsive);
                            },
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bookingCard(Map<String, dynamic> booking, ResponsiveUtils responsive) {
    final service = booking['service'] as Map<String, dynamic>?;
    final customer = booking['customer'] as Map<String, dynamic>?;
    final cleaner = booking['cleaner'] as Map<String, dynamic>?;
    final status = booking['status'] ?? 'pending';

    Color statusColor = status == 'assigned' || status == 'in_progress' || status == 'completed'
        ? Colors.green
        : status == 'cancelled'
            ? Colors.red
            : Colors.orange;

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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.spacing(10),
                      vertical: responsive.spacing(6),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      booking['bookingId'] ?? 'N/A',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: responsive.responsiveFontSize(12),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
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
                  status.toString().replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: responsive.responsiveFontSize(11),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: responsive.spacing(12)),

          // Service Name
          Text(
            service?['title'] ?? 'Unknown Service',
            style: TextStyle(
              fontSize: responsive.responsiveFontSize(17),
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: responsive.spacing(12)),

          // Customer Info
          Row(
            children: [
              Icon(Icons.person, size: 16, color: Colors.grey.shade600),
              SizedBox(width: responsive.spacing(6)),
              Text(
                customer?['name'] ?? 'Unknown',
                style: TextStyle(
                  fontSize: responsive.responsiveFontSize(14),
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          SizedBox(height: responsive.spacing(6)),

          Row(
            children: [
              Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
              SizedBox(width: responsive.spacing(6)),
              Text(
                booking['phone'] ?? customer?['phone'] ?? 'N/A',
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
              Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
              SizedBox(width: responsive.spacing(6)),
              Expanded(
                child: Text(
                  booking['address'] ?? 'N/A',
                  style: TextStyle(
                    fontSize: responsive.responsiveFontSize(13),
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: responsive.spacing(12)),

          // Date & Time
          Container(
            padding: EdgeInsets.all(responsive.spacing(10)),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.blue.shade700),
                SizedBox(width: responsive.spacing(6)),
                Text(
                  booking['bookingDate'] ?? 'N/A',
                  style: TextStyle(
                    fontSize: responsive.responsiveFontSize(13),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: responsive.spacing(16)),
                Icon(Icons.access_time, size: 16, color: Colors.blue.shade700),
                SizedBox(width: responsive.spacing(6)),
                Text(
                  booking['bookingTime'] ?? 'N/A',
                  style: TextStyle(
                    fontSize: responsive.responsiveFontSize(13),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: responsive.spacing(16)),

          // Customer Notes/Message Section
          if (booking['notes'] != null && booking['notes'].toString().trim().isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(responsive.spacing(12)),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.message, size: 16, color: Colors.amber.shade700),
                      SizedBox(width: responsive.spacing(6)),
                      Text(
                        "Customer Message:",
                        style: TextStyle(
                          fontSize: responsive.responsiveFontSize(13),
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.spacing(8)),
                  Text(
                    booking['notes'],
                    style: TextStyle(
                      fontSize: responsive.responsiveFontSize(13),
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: responsive.spacing(16)),
          ],

          // Cleaner Assignment Section
          if (status == 'pending') ...[
            Text(
              "Assign Cleaner:",
              style: TextStyle(
                fontSize: responsive.responsiveFontSize(13),
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),

            SizedBox(height: responsive.spacing(8)),

            _isLoadingCleaners
                ? const Center(child: CircularProgressIndicator())
                : cleaners.isEmpty
                    ? Text(
                        "No cleaners available",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: responsive.responsiveFontSize(13),
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.symmetric(horizontal: responsive.spacing(12)),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: null,
                            hint: Text(
                              'Select a cleaner',
                              style: TextStyle(
                                fontSize: responsive.responsiveFontSize(13),
                                color: Colors.grey.shade600,
                              ),
                            ),
                            icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
                            items: cleaners.map((cleaner) {
                              return DropdownMenuItem<String>(
                                value: cleaner['_id'],
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.green.shade100,
                                      child: Icon(Icons.person, size: 14, color: Colors.green.shade700),
                                    ),
                                    SizedBox(width: responsive.spacing(8)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            cleaner['name'] ?? 'Unknown',
                                            style: TextStyle(fontSize: responsive.responsiveFontSize(13)),
                                          ),
                                          if (cleaner['rating'] != null)
                                            Row(
                                              children: [
                                                Icon(Icons.star, size: 12, color: Colors.amber),
                                                Text(
                                                  ' ${cleaner['rating']}',
                                                  style: TextStyle(
                                                    fontSize: responsive.responsiveFontSize(11),
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? cleanerId) {
                              if (cleanerId != null) {
                                _assignCleaner(booking['_id'], cleanerId);
                              }
                            },
                          ),
                        ),
                      ),
          ],

          if (cleaner != null) ...[
            SizedBox(height: responsive.spacing(12)),
            Container(
              padding: EdgeInsets.all(responsive.spacing(10)),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700, size: 18),
                  SizedBox(width: responsive.spacing(8)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Assigned to: ${cleaner['name'] ?? 'Unknown'}",
                          style: TextStyle(
                            color: Colors.green.shade900,
                            fontSize: responsive.responsiveFontSize(13),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (cleaner['phone'] != null)
                          Text(
                            cleaner['phone'],
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: responsive.responsiveFontSize(12),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------- MAIN UI ----------------
  @override
  Widget build(BuildContext context) {
    final List<BottomNavigationBarItem> navItems = const [
      BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
      BottomNavigationBarItem(icon: Icon(Icons.book_online), label: "Bookings"),
      BottomNavigationBarItem(icon: Icon(Icons.home_repair_service), label: "Services"),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
    ];

    final pages = [
      _dashboardBody(),
      _bookingsBody(),
      _servicesBody(),
      _profileBody(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: navItems,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
