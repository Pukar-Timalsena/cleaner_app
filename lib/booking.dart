import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'home.dart';

class BookingInfoPage extends StatefulWidget {
  final Map<String, dynamic> service;
  final String image;

  const BookingInfoPage({
    super.key,
    required this.service,
    required this.image,
  });

  @override
  State<BookingInfoPage> createState() => _BookingInfoPageState();
}

class _BookingInfoPageState extends State<BookingInfoPage> {
  int selectedDay = DateTime.now().day;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String selectedPaymentMethod = "Cash";
  bool _isBooking = false;

  // Controllers for user input
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // User data
  Map<String, dynamic>? _userData;

  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await ApiService.getUserData();
      setState(() {
        _userData = userData;
        if (userData != null) {
          _addressController.text = userData['address'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
        }
      });
    } catch (e) {
      // Silently fail
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate() {
    return "$selectedDay ${months[selectedMonth - 1].substring(0, 3)} $selectedYear";
  }

  String _formatTime() {
    final hour = selectedTime.hourOfPeriod == 0 ? 12 : selectedTime.hourOfPeriod;
    final minute = selectedTime.minute.toString().padLeft(2, '0');
    final period = selectedTime.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  int get _daysInMonth {
    return DateTime(selectedYear, selectedMonth + 1, 0).day;
  }

  int get _servicePrice {
    return widget.service['basePrice'] ?? 0;
  }

  Future<void> _confirmBooking() async {
    // Validate inputs
    if (_addressController.text.trim().isEmpty) {
      _showError('Please enter your address');
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showError('Please enter your phone number');
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      // Format the date for API
      final bookingDate = DateTime(selectedYear, selectedMonth, selectedDay);
      final formattedDate = bookingDate.toIso8601String().split('T')[0];

      await ApiService.createBooking(
        serviceId: widget.service['_id'],
        bookingDate: formattedDate,
        bookingTime: _formatTime(),
        location: _addressController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        paymentMethod: selectedPaymentMethod == 'Cash' ? 'cash' : 'digital_wallet',
        subtotal: _servicePrice,
        discount: 0,
        total: _servicePrice,
        notes: _notesController.text.trim(),
      );

      if (mounted) {
        _showBookingSuccessDialog(context);
      }
    } catch (e) {
      _showError('Failed to create booking: $e');
    } finally {
      setState(() {
        _isBooking = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final serviceTitle = widget.service['title'] ?? 'Unknown Service';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Booking Info",
          style: TextStyle(color: Colors.black),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------ CALENDAR ------------
              _buildCalendar(),

              const SizedBox(height: 20),

              // ------------ ENTER INFORMATION ------------
              const Text(
                "Enter Your Information",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              // Info box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    // Row Date + Time
                    Row(
                      children: [
                        Expanded(
                          child: _infoField("Date", _formatDate(), Icons.calendar_today),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: _selectTime,
                            child: _infoField("Time", _formatTime(), Icons.access_time),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Address Input
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Address *',
                        hintText: 'Enter your full address',
                        prefixIcon: const Icon(Icons.location_on, color: Colors.green),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Phone Input
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone *',
                        hintText: 'Enter your phone number',
                        prefixIcon: const Icon(Icons.phone, color: Colors.green),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Notes Input (Optional)
                    TextField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Special Notes (Optional)',
                        hintText: 'Any special instructions...',
                        prefixIcon: const Icon(Icons.note, color: Colors.green),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ------------ BILLING ------------
              const Text(
                "Billing & Total",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              // Billing box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            widget.image,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            serviceTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _priceRow("Subtotal", "NPR $_servicePrice"),
                    const SizedBox(height: 6),
                    _priceRow("Discount", "-"),

                    const Divider(color: Colors.white),

                    _priceRow(
                      "Total",
                      "NPR $_servicePrice",
                      bold: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ------------ PAYMENT METHOD ------------
              const Text(
                "Payment Method",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              // Payment Options
              Column(
                children: [
                  // Digital Wallet Option
                  _paymentOption(
                    title: "Digital Wallet",
                    subtitle: null,
                    icon: Icons.account_balance_wallet,
                    value: "Digital Wallet",
                  ),

                  const SizedBox(height: 12),

                  // Cash Option
                  _paymentOption(
                    title: "Pay at Your Door",
                    subtitle: "Cash",
                    icon: Icons.money,
                    value: "Cash",
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Confirm button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isBooking ? Colors.grey : Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isBooking ? null : _confirmBooking,
                  child: _isBooking
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          "Confirm Booking",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- PAYMENT OPTION WIDGET ----------------
  Widget _paymentOption({
    required String title,
    String? subtitle,
    required IconData icon,
    required String value,
  }) {
    final isSelected = selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.green : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: selectedPaymentMethod,
              onChanged: (v) {
                setState(() {
                  selectedPaymentMethod = v!;
                });
              },
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- BOOKING SUCCESS DIALOG ----------------
  void _showBookingSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Green checkmark circle
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 50,
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                const Text(
                  "Booking Successful!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                // Message
                const Text(
                  "You have successfully booked the service. You can track your booking in the Activity tab.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 24),

                // Back to Home Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Navigate back to home
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const Homepage()),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Back to Home",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------- CALENDAR UI ----------------
  Widget _buildCalendar() {
    return Column(
      children: [
        // Month Navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  if (selectedMonth == 1) {
                    selectedMonth = 12;
                    selectedYear--;
                  } else {
                    selectedMonth--;
                  }
                  if (selectedDay > _daysInMonth) {
                    selectedDay = _daysInMonth;
                  }
                });
              },
            ),
            Text(
              "${months[selectedMonth - 1]} $selectedYear",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  if (selectedMonth == 12) {
                    selectedMonth = 1;
                    selectedYear++;
                  } else {
                    selectedMonth++;
                  }
                  if (selectedDay > _daysInMonth) {
                    selectedDay = _daysInMonth;
                  }
                });
              },
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Day labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
              .map((day) => SizedBox(
                    width: 40,
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ))
              .toList(),
        ),

        const SizedBox(height: 8),

        // Calendar Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _daysInMonth + _firstDayOfMonth,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            if (index < _firstDayOfMonth) {
              return const SizedBox();
            }

            final day = index - _firstDayOfMonth + 1;
            final isSelected = day == selectedDay;
            final isPast = DateTime(selectedYear, selectedMonth, day)
                .isBefore(DateTime.now().subtract(const Duration(days: 1)));

            return GestureDetector(
              onTap: isPast
                  ? null
                  : () {
                      setState(() {
                        selectedDay = day;
                      });
                    },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.green
                      : isPast
                          ? Colors.grey.shade100
                          : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  "$day",
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isPast
                            ? Colors.grey.shade400
                            : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  int get _firstDayOfMonth {
    return DateTime(selectedYear, selectedMonth, 1).weekday % 7;
  }

  // ---------------- INFO FIELD CARD ----------------
  Widget _infoField(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- PRICE ROW ----------------
  Widget _priceRow(String title, String price, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        Text(
          price,
          style: TextStyle(
            color: Colors.white,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
