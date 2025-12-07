import 'package:flutter/material.dart';
import 'activity.dart';
import 'responsive_utils.dart';
import 'feature_details.dart';
import 'login_page.dart';
import 'services/api_service.dart';
import 'messages_page.dart';

class Homepage extends StatefulWidget {
  final String? userName;
  final String? userEmail;
  final String? userAddress;
  final String? userPhone;
  final String? userType;

  const Homepage({
    super.key,
    this.userName,
    this.userEmail,
    this.userAddress,
    this.userPhone,
    this.userType,
  });

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentIndex = 0;

  // Dynamic services list
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> filteredServices = [];
  bool _isLoadingServices = true;

  // Search controller
  final TextEditingController _searchController = TextEditingController();

  // Bookings list
  List<Map<String, dynamic>> bookings = [];
  bool _isLoadingBookings = true;

  // User data from storage
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadServices(),
      _loadUserData(),
      _loadBookings(),
    ]);
  }

  Future<void> _loadServices() async {
    try {
      // Seed services first if needed
      await ApiService.seedServices();

      final servicesList = await ApiService.getServices();
      setState(() {
        services = servicesList.map((s) => Map<String, dynamic>.from(s)).toList();
        filteredServices = services;
        _isLoadingServices = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingServices = false;
      });
      _showError('Failed to load services: $e');
    }
  }

  void _filterServices(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredServices = services;
      } else {
        filteredServices = services.where((service) {
          final title = (service['title'] ?? '').toString().toLowerCase();
          final category = (service['category'] ?? '').toString().toLowerCase();
          final location = (service['location'] ?? '').toString().toLowerCase();
          final searchQuery = query.toLowerCase();
          return title.contains(searchQuery) ||
              category.contains(searchQuery) ||
              location.contains(searchQuery);
        }).toList();
      }
    });
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await ApiService.getUserData();
      setState(() {
        _userData = userData;
      });
    } catch (e) {
      // Silently fail - will use widget parameters
    }
  }

  Future<void> _loadBookings() async {
    try {
      final bookingsList = await ApiService.getCustomerBookings();
      setState(() {
        bookings = bookingsList.map((b) => Map<String, dynamic>.from(b)).toList();
        _isLoadingBookings = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingBookings = false;
      });
      // Silently fail - user might not have any bookings
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

  // Get user name from storage or widget parameter
  String get _userName => _userData?['name'] ?? widget.userName ?? "Guest User";
  String? get _userEmail => _userData?['email'] ?? widget.userEmail;
  String? get _userPhone => _userData?['phone'] ?? widget.userPhone;
  String? get _userAddress => _userData?['address'] ?? widget.userAddress;
  String get _userType => _userData?['role']?.toString().toUpperCase() ?? widget.userType ?? "Customer";

  // Get image for service
  String _getServiceImage(Map<String, dynamic> service) {
    final category = service['category'] ?? '';
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

  // ---------------- HOME BODY ----------------
  Widget _homeBody() {
    final responsive = context.responsive;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadServices,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------- TOP BAR ----------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showProfileDialog(context);
                          },
                          child: CircleAvatar(
                            radius: responsive.avatarRadius,
                            backgroundColor: Colors.green.shade200,
                            child: Icon(
                              Icons.person,
                              size: responsive.avatarRadius - 4,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ),
                        SizedBox(width: responsive.spacing(10)),
                        Text(
                          _userName,
                          style: TextStyle(
                            fontSize: responsive.responsiveFontSize(16, tabletSize: 18, desktopSize: 20),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.message_outlined, size: responsive.responsiveFontSize(24)),
                          onPressed: () => _openAdminMessaging(),
                          tooltip: 'Message Admin',
                        ),
                        Icon(Icons.notifications_none, size: responsive.responsiveFontSize(28)),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: responsive.spacing(15)),

                // ---------------- SEARCH BAR ----------------
                Container(
                  height: responsive.searchBarHeight,
                  padding: EdgeInsets.symmetric(horizontal: responsive.spacing(12)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: responsive.spacing(10)),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _filterServices,
                          decoration: InputDecoration(
                            hintText: "Search the services",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: responsive.responsiveFontSize(14),
                            ),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontSize: responsive.responsiveFontSize(14),
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            _filterServices('');
                          },
                          child: Icon(Icons.close, color: Colors.grey),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: responsive.spacing(20)),

                // ---------------- OUR SERVICES ----------------
                Text(
                  "Our Services",
                  style: TextStyle(
                    fontSize: responsive.responsiveFontSize(18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: responsive.spacing(12)),

                SizedBox(
                  height: responsive.spacing(90),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      serviceIcon("assets/icon1.png", "House Keeping"),
                      serviceIcon("assets/icon4.png", "Vacuum Service"),
                      serviceIcon("assets/icons2.png", "Painting"),
                      serviceIcon("assets/icon3.png", "Sanitary Service"),
                      Column(
                        children: [
                          CircleAvatar(
                            radius: responsive.avatarRadius,
                            backgroundColor: Colors.black12,
                            child: const Icon(Icons.more_horiz),
                          ),
                          SizedBox(height: responsive.spacing(6)),
                          Text("See more",
                              style: TextStyle(fontSize: responsive.responsiveFontSize(12))),
                        ],
                      )
                    ],
                  ),
                ),

                SizedBox(height: responsive.spacing(20)),

                // ---------------- MY BOOKINGS ----------------
                // Show ongoing bookings section
                Builder(
                  builder: (context) {
                    // Filter for ongoing bookings only (in_progress or assigned)
                    final ongoingBookings = bookings.where((b) {
                      final status = b['status'];
                      return status == 'in_progress' || status == 'assigned';
                    }).take(2).toList();

                    if (ongoingBookings.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Ongoing Bookings",
                              style: TextStyle(
                                fontSize: responsive.responsiveFontSize(18),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() => _currentIndex = 1); // Navigate to Activity tab
                              },
                              child: Text(
                                "View All",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: responsive.responsiveFontSize(14),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: responsive.spacing(12)),

                        // Ongoing Bookings List (show max 2)
                        _isLoadingBookings
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: ongoingBookings.length,
                                itemBuilder: (context, index) {
                                  final booking = ongoingBookings[index];
                                  return _bookingCard(booking, responsive);
                                },
                              ),

                        SizedBox(height: responsive.spacing(20)),
                      ],
                    );
                  },
                ),

                Text(
                  "Featured Services",
                  style: TextStyle(
                    fontSize: responsive.responsiveFontSize(18),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: responsive.spacing(10)),

                // ---------------- FEATURED CARDS GRID ----------------
                _isLoadingServices
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : services.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  Text(
                                    "No services available",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: responsive.responsiveFontSize(16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : filteredServices.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(40),
                                  child: Column(
                                    children: [
                                      Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
                                      const SizedBox(height: 12),
                                      Text(
                                        "No services found",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: responsive.responsiveFontSize(16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredServices.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: responsive.getGridCrossAxisCount(),
                                  mainAxisExtent: responsive.isMobile ? 260 : 280,
                                  crossAxisSpacing: responsive.spacing(15),
                                  mainAxisSpacing: responsive.spacing(15),
                                ),
                                itemBuilder: (context, index) {
                                  final service = filteredServices[index];
                                  return serviceCard(
                                    service: service,
                                    image: _getServiceImage(service),
                                  );
                                },
                              ),

                SizedBox(height: responsive.spacing(20)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- SERVICE ICON ----------------
  Widget serviceIcon(String image, String title) {
    final responsive = context.responsive;

    return Padding(
      padding: EdgeInsets.only(right: responsive.spacing(20)),
      child: Column(
        children: [
          CircleAvatar(
            radius: responsive.avatarRadius,
            backgroundColor: Colors.black12,
            child: Image.asset(image, width: responsive.avatarRadius * 1.1),
          ),
          SizedBox(height: responsive.spacing(6)),
          Text(
            title,
            style: TextStyle(fontSize: responsive.responsiveFontSize(12)),
          ),
        ],
      ),
    );
  }

  // ---------------- SERVICE CARD ----------------
  Widget serviceCard({
    required Map<String, dynamic> service,
    required String image,
  }) {
    final responsive = context.responsive;
    final title = service['title'] ?? 'Unknown Service';
    final location = service['location'] ?? 'Kathmandu';
    final rating = (service['rating'] ?? 0).toDouble();
    final reviews = service['reviewCount'] ?? 0;
    final price = service['basePrice'] ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetailCard(
              service: service,
              image: image,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: responsive.cardElevation * 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                image,
                height: responsive.isMobile ? 130 : 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            SizedBox(height: responsive.spacing(8)),

            Row(
              children: [
                SizedBox(width: responsive.spacing(8)),
                Icon(Icons.star, color: Colors.orange),
                Text(" $rating ($reviews)",
                    style: TextStyle(fontSize: responsive.responsiveFontSize(12))),
              ],
            ),

            SizedBox(height: responsive.spacing(6)),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsive.spacing(8)),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: responsive.responsiveFontSize(15),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            SizedBox(height: responsive.spacing(5)),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsive.spacing(8)),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey),
                  Text(location,
                      style: TextStyle(fontSize: responsive.responsiveFontSize(12))),
                ],
              ),
            ),

            const Spacer(),

            Padding(
              padding: EdgeInsets.all(responsive.spacing(10)),
              child: Text(
                "Npr $price",
                style: TextStyle(
                  fontSize: responsive.responsiveFontSize(16),
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- BOOKING CARD ----------------
  Widget _bookingCard(Map<String, dynamic> booking, ResponsiveUtils responsive) {
    final service = booking['service'] as Map<String, dynamic>?;
    final title = service?['title'] ?? 'Unknown Service';
    final price = booking['total'] ?? service?['basePrice'] ?? 0;
    final dateString = booking['bookingDate'];
    final status = booking['status'] ?? 'pending';
    final cleaner = booking['cleaner'] as Map<String, dynamic>?;

    Color statusColor;
    switch (status) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        break;
      case 'assigned':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    // Get image based on service category
    String getServiceImage() {
      final category = service?['category'] ?? '';
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

    // Format date
    String formatDate(String? dateString) {
      if (dateString == null) return 'N/A';
      try {
        final date = DateTime.parse(dateString);
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${date.day} ${months[date.month - 1]}, ${date.year}';
      } catch (e) {
        return dateString;
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: responsive.spacing(12)),
      padding: EdgeInsets.all(responsive.spacing(12)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Service Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  getServiceImage(),
                  width: responsive.spacing(60),
                  height: responsive.spacing(60),
                  fit: BoxFit.cover,
                ),
              ),

              SizedBox(width: responsive.spacing(12)),

              // Service Details
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
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                        SizedBox(width: responsive.spacing(4)),
                        Text(
                          formatDate(dateString),
                          style: TextStyle(
                            fontSize: responsive.responsiveFontSize(12),
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    if (booking['bookingTime'] != null) ...[
                      SizedBox(height: responsive.spacing(2)),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                          SizedBox(width: responsive.spacing(4)),
                          Text(
                            booking['bookingTime'],
                            style: TextStyle(
                              fontSize: responsive.responsiveFontSize(12),
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Price and Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "NPR $price",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: responsive.responsiveFontSize(14),
                      color: Colors.green.shade700,
                    ),
                  ),
                  SizedBox(height: responsive.spacing(4)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.spacing(8),
                      vertical: responsive.spacing(3),
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
                        fontSize: responsive.responsiveFontSize(10),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Cleaner info and message button (if assigned)
          if (cleaner != null) ...[
            SizedBox(height: responsive.spacing(10)),
            Container(
              padding: EdgeInsets.all(responsive.spacing(10)),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.blue.shade700),
                      SizedBox(width: responsive.spacing(6)),
                      Expanded(
                        child: Text(
                          "Cleaner: ${cleaner['name'] ?? 'Assigned'}",
                          style: TextStyle(
                            fontSize: responsive.responsiveFontSize(12),
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (cleaner['phone'] != null) ...[
                        Icon(Icons.phone, size: 14, color: Colors.blue.shade700),
                        SizedBox(width: responsive.spacing(4)),
                        Text(
                          cleaner['phone'],
                          style: TextStyle(
                            fontSize: responsive.responsiveFontSize(11),
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: responsive.spacing(8)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: responsive.spacing(8)),
                      ),
                      onPressed: () => _showMessageDialog(booking, cleaner),
                      icon: const Icon(Icons.message, size: 16, color: Colors.white),
                      label: Text(
                        "Message Cleaner",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: responsive.responsiveFontSize(13),
                        ),
                      ),
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

  // ---------------- MESSAGE DIALOG ----------------
  void _showMessageDialog(Map<String, dynamic> booking, Map<String, dynamic> cleaner) {
    // Navigate to full messaging page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagesPage(
          bookingId: booking['bookingId'] ?? booking['_id'],
          recipientId: cleaner['_id'] ?? '',
          recipientName: cleaner['name'] ?? 'Cleaner',
          recipientType: 'cleaner',
          bookingDetails: booking,
        ),
      ),
    );
  }

  // ---------------- PROFILE DIALOG ----------------
  void _showProfileDialog(BuildContext context) {
    final responsive = context.responsive;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(responsive.spacing(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: responsive.profileAvatarRadius,
                backgroundColor: Colors.green.shade200,
                child: Icon(
                  Icons.person,
                  size: responsive.profileAvatarRadius - 10,
                  color: Colors.green.shade900,
                ),
              ),

              SizedBox(height: responsive.spacing(16)),

              Text(
                _userName,
                style: TextStyle(
                    fontSize: responsive.responsiveFontSize(22),
                    fontWeight: FontWeight.bold),
              ),

              SizedBox(height: responsive.spacing(6)),

              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 12, vertical: responsive.spacing(4)),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Text(
                  _userType,
                  style: TextStyle(
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(height: responsive.spacing(20)),

              _infoRow(Icons.email, "Email", _userEmail),
              SizedBox(height: responsive.spacing(12)),
              _infoRow(Icons.phone, "Phone", _userPhone),
              SizedBox(height: responsive.spacing(12)),
              _infoRow(Icons.location_on, "Address", _userAddress),

              SizedBox(height: responsive.spacing(24)),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: responsive.spacing(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Close", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String? value) {
    final responsive = context.responsive;

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
              Text(value ?? "Not provided",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  // ---------------- ADMIN MESSAGING ----------------
  void _openAdminMessaging() async {
    try {
      // Get admin user ID - you might need to fetch this from API
      // For now, using a placeholder
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessagesPage(
            recipientId: 'admin',
            recipientName: 'Admin Support',
            recipientType: 'admin',
          ),
        ),
      );
    } catch (e) {
      _showError('Failed to open admin messaging: $e');
    }
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
                _userName,
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
                  _userType,
                  style: TextStyle(
                      color: Colors.green.shade900,
                      fontSize: responsive.responsiveFontSize(16),
                      fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(height: responsive.spacing(30)),

              _infoRow(Icons.email, "Email", _userEmail),
              SizedBox(height: responsive.spacing(12)),
              _infoRow(Icons.phone, "Phone", _userPhone),
              SizedBox(height: responsive.spacing(12)),
              _infoRow(Icons.location_on, "Address", _userAddress),

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

  // ---------------- MAIN UI ----------------
  @override
  Widget build(BuildContext context) {
    final List<BottomNavigationBarItem> navItems = const [
      BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
      BottomNavigationBarItem(icon: Icon(Icons.access_time), label: "Activity"),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
    ];

    final pages = [
      _homeBody(),
      const ActivityPage(),
      _profileBody(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: navItems,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
