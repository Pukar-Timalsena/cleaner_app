import 'package:flutter/material.dart';
import 'responsive_utils.dart';
import 'services/api_service.dart';
import 'messages_page.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  int selectedTab = 0; // 0 = Ongoing, 1 = Completed, 2 = Cancelled

  // Dynamic booking lists
  List<Map<String, dynamic>> allBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bookingsList = await ApiService.getCustomerBookings();
      setState(() {
        allBookings = bookingsList.map((b) => Map<String, dynamic>.from(b)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to load bookings: $e');
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

  // Filter bookings by status
  List<Map<String, dynamic>> get ongoingList {
    return allBookings.where((b) {
      final status = b['status'];
      return status == 'pending' || status == 'assigned' || status == 'in_progress';
    }).toList();
  }

  List<Map<String, dynamic>> get completedList {
    return allBookings.where((b) => b['status'] == 'completed').toList();
  }

  List<Map<String, dynamic>> get cancelledList {
    return allBookings.where((b) => b['status'] == 'cancelled').toList();
  }

  // Choose correct list based on selected tab
  List<Map<String, dynamic>> get currentList {
    switch (selectedTab) {
      case 0:
        return ongoingList;
      case 1:
        return completedList;
      case 2:
        return cancelledList;
      default:
        return ongoingList;
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    try {
      await ApiService.cancelBooking(bookingId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _loadBookings();
    } catch (e) {
      _showError('Failed to cancel booking: $e');
    }
  }

  void _showCancelConfirmation(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text('Are you sure you want to cancel this booking for "${booking['service']?['title'] ?? 'Unknown Service'}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _cancelBooking(booking['_id']);
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "My Bookings",
          style: TextStyle(
            fontSize: responsive.responsiveFontSize(20, tabletSize: 22, desktopSize: 24),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBookings,
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
          child: Column(
            children: [
              SizedBox(height: responsive.spacing(10)),

              // ----------- 3 BUTTON TAB BAR -------------
              Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildTabButton("Ongoing", 0, ongoingList.length, responsive),
                    buildTabButton("Completed", 1, completedList.length, responsive),
                    buildTabButton("Canceled", 2, cancelledList.length, responsive),
                  ],
                ),
              ),

              SizedBox(height: responsive.spacing(15)),

              // ----------- LIST VIEW ------------
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _loadBookings,
                        child: currentList.isEmpty
                            ? ListView(
                                children: [
                                  SizedBox(height: responsive.spacing(60)),
                                  Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.inbox_outlined,
                                          size: 60,
                                          color: Colors.grey.shade400,
                                        ),
                                        SizedBox(height: responsive.spacing(12)),
                                        Text(
                                          selectedTab == 0
                                              ? "No ongoing bookings"
                                              : selectedTab == 1
                                                  ? "No completed bookings"
                                                  : "No cancelled bookings",
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: responsive.responsiveFontSize(16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
                                itemCount: currentList.length,
                                itemBuilder: (context, index) {
                                  final booking = currentList[index];
                                  return activityTile(booking, responsive);
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tab Button Widget
  Widget buildTabButton(String text, int index, int count, ResponsiveUtils responsive) {
    bool isActive = selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.spacing(14),
          vertical: responsive.spacing(10),
        ),
        decoration: BoxDecoration(
          color: isActive ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: responsive.responsiveFontSize(13, tabletSize: 14, desktopSize: 15),
              ),
            ),
            if (count > 0) ...[
              SizedBox(width: responsive.spacing(6)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.spacing(6),
                  vertical: responsive.spacing(2),
                ),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white.withOpacity(0.3) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey.shade700,
                    fontSize: responsive.responsiveFontSize(11),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Service Tile Widget
  Widget activityTile(Map<String, dynamic> booking, ResponsiveUtils responsive) {
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
                  _getServiceImage(booking),
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
                        fontSize: responsive.responsiveFontSize(15, tabletSize: 16, desktopSize: 17),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: responsive.spacing(4)),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                        SizedBox(width: responsive.spacing(4)),
                        Text(
                          _formatDate(dateString),
                          style: TextStyle(
                            fontSize: responsive.responsiveFontSize(12, tabletSize: 13, desktopSize: 14),
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
                              fontSize: responsive.responsiveFontSize(12, tabletSize: 13, desktopSize: 14),
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "NPR $price",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: responsive.responsiveFontSize(14, tabletSize: 15, desktopSize: 16),
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

          // Cleaner info (if assigned)
          if (cleaner != null) ...[
            SizedBox(height: responsive.spacing(10)),
            Container(
              padding: EdgeInsets.all(responsive.spacing(8)),
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
                      Text(
                        "Cleaner: ${cleaner['name'] ?? 'Assigned'}",
                        style: TextStyle(
                          fontSize: responsive.responsiveFontSize(12),
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (cleaner['phone'] != null) ...[
                        const Spacer(),
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
                      onPressed: () {
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
                      },
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

          // Cancel button for pending/assigned bookings
          if (status == 'pending' || status == 'assigned') ...[
            SizedBox(height: responsive.spacing(10)),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: EdgeInsets.symmetric(vertical: responsive.spacing(8)),
                ),
                onPressed: () => _showCancelConfirmation(booking),
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: Text(
                  "Cancel Booking",
                  style: TextStyle(fontSize: responsive.responsiveFontSize(13)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
