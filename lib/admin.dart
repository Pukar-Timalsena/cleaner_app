import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'responsive_utils.dart';
import 'login_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
  int totalUsers = 125;
  int totalCleaners = 34;
  int totalServices = 12;
  int activeBookings = 48;

  List<Map<String, dynamic>> tasks = [
    {"title": "Clean Lobby", "status": "Ongoing", "cleaner": "John Doe", "time": "2 hours ago"},
    {"title": "Clean Room 101", "status": "Completed", "cleaner": "Jane Smith", "time": "5 hours ago"},
    {"title": "Carpet Cleaning", "status": "Pending", "cleaner": "Mike Johnson", "time": "1 day ago"},
    {"title": "Window Cleaning", "status": "Ongoing", "cleaner": "Sarah Williams", "time": "3 hours ago"},
  ];

  // Bookings from customers
  List<Map<String, dynamic>> bookings = [
    {
      "id": "BK001",
      "service": "House Cleaning",
      "customer": "John Smith",
      "phone": "+977 9812345678",
      "address": "Kathmandu, Thamel",
      "date": "2024-11-22",
      "time": "10:00 AM",
      "status": "Pending",
      "assignedCleaner": null,
    },
    {
      "id": "BK002",
      "service": "Carpet Cleaning",
      "customer": "Sarah Johnson",
      "phone": "+977 9823456789",
      "address": "Lalitpur, Jawalakhel",
      "date": "2024-11-22",
      "time": "2:00 PM",
      "status": "Pending",
      "assignedCleaner": null,
    },
    {
      "id": "BK003",
      "service": "Window Cleaning",
      "customer": "Mike Davis",
      "phone": "+977 9834567890",
      "address": "Bhaktapur, Durbar Square",
      "date": "2024-11-23",
      "time": "11:00 AM",
      "status": "Assigned",
      "assignedCleaner": "Jane Cleaner",
    },
  ];

  // Available cleaners
  List<String> availableCleaners = [
    "Jane Cleaner",
    "John Doe",
    "Mike Johnson",
    "Sarah Williams",
    "Tom Brown",
  ];

  final TextEditingController _featureController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _uploadFeature() {
    if (_featureController.text.isNotEmpty && 
        _descriptionController.text.isNotEmpty && 
        _priceController.text.isNotEmpty && 
        _image != null) {
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
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select an image'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _assignCleaner(int bookingIndex, String? cleaner) {
    if (cleaner != null) {
      setState(() {
        bookings[bookingIndex]['assignedCleaner'] = cleaner;
        bookings[bookingIndex]['status'] = 'Assigned';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task assigned to $cleaner successfully!'),
          backgroundColor: Colors.green,
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
                  Icon(Icons.notifications_outlined, size: responsive.responsiveFontSize(28)),
                ],
              ),

              SizedBox(height: responsive.spacing(25)),

              // Stats Cards Grid
              GridView.count(
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
                  _statCard("Bookings", activeBookings.toString(), Icons.book_online, Colors.purple, responsive),
                ],
              ),

              SizedBox(height: responsive.spacing(30)),

              // Recent Tasks
              Text(
                "Recent Tasks",
                style: TextStyle(
                  fontSize: responsive.responsiveFontSize(18),
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: responsive.spacing(15)),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return _taskCard(task, responsive);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, String count, IconData icon, Color color, ResponsiveUtils responsive) {
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
    );
  }

  Widget _taskCard(Map<String, dynamic> task, ResponsiveUtils responsive) {
    Color statusColor;
    switch (task['status']) {
      case 'Completed':
        statusColor = Colors.green;
        break;
      case 'Ongoing':
        statusColor = Colors.orange;
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
                  task['title'],
                  style: TextStyle(
                    fontSize: responsive.responsiveFontSize(15),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: responsive.spacing(4)),
                Text(
                  "Assigned to: ${task['cleaner']}",
                  style: TextStyle(
                    fontSize: responsive.responsiveFontSize(13),
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: responsive.spacing(2)),
                Text(
                  task['time'],
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
              task['status'],
              style: TextStyle(
                color: statusColor,
                fontSize: responsive.responsiveFontSize(12),
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
              Text(
                "Upload New Service",
                style: TextStyle(
                  fontSize: responsive.responsiveFontSize(22),
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: responsive.spacing(8)),

              // Detailed Instructions
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

                    SizedBox(height: responsive.spacing(20)),

                    // Image Upload Section
                    Text(
                      "Service Image *",
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
                            onPressed: _uploadFeature,
                            icon: const Icon(Icons.upload, color: Colors.white),
                            label: const Text('Upload Service', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
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
            ],
          ),
        ),
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
                "Admin User",
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

              _infoRow(Icons.email, "Email", "admin@test.com", responsive),
              SizedBox(height: responsive.spacing(12)),
              _infoRow(Icons.phone, "Phone", "+977 9876543210", responsive),
              SizedBox(height: responsive.spacing(12)),
              _infoRow(Icons.location_on, "Address", "Kathmandu, Nepal", responsive),

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
                      "${bookings.where((b) => b['status'] == 'Pending').length} Pending",
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
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return _bookingCard(booking, index, responsive);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bookingCard(Map<String, dynamic> booking, int index, ResponsiveUtils responsive) {
    Color statusColor = booking['status'] == 'Assigned' ? Colors.green : Colors.orange;

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
                      booking['id'],
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
                  booking['status'],
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
            booking['service'],
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
                booking['customer'],
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
                booking['phone'],
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
                  booking['address'],
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
                  booking['date'],
                  style: TextStyle(
                    fontSize: responsive.responsiveFontSize(13),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: responsive.spacing(16)),
                Icon(Icons.access_time, size: 16, color: Colors.blue.shade700),
                SizedBox(width: responsive.spacing(6)),
                Text(
                  booking['time'],
                  style: TextStyle(
                    fontSize: responsive.responsiveFontSize(13),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: responsive.spacing(16)),

          // Cleaner Assignment Section
          Text(
            "Assign Cleaner:",
            style: TextStyle(
              fontSize: responsive.responsiveFontSize(13),
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),

          SizedBox(height: responsive.spacing(8)),

          Container(
            padding: EdgeInsets.symmetric(horizontal: responsive.spacing(12)),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: booking['assignedCleaner'],
                hint: Text(
                  'Select a cleaner',
                  style: TextStyle(
                    fontSize: responsive.responsiveFontSize(13),
                    color: Colors.grey.shade600,
                  ),
                ),
                icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
                items: availableCleaners.map((String cleaner) {
                  return DropdownMenuItem<String>(
                    value: cleaner,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.green.shade100,
                          child: Icon(Icons.person, size: 14, color: Colors.green.shade700),
                        ),
                        SizedBox(width: responsive.spacing(8)),
                        Text(
                          cleaner,
                          style: TextStyle(fontSize: responsive.responsiveFontSize(13)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  _assignCleaner(index, newValue);
                },
              ),
            ),
          ),

          if (booking['assignedCleaner'] != null) ...[
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
                  Text(
                    "Assigned to: ${booking['assignedCleaner']}",
                    style: TextStyle(
                      color: Colors.green.shade900,
                      fontSize: responsive.responsiveFontSize(13),
                      fontWeight: FontWeight.w600,
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
