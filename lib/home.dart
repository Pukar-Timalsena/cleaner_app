import 'package:flutter/material.dart';
import 'activity.dart';
import 'responsive_utils.dart';
import 'feature_details.dart';
import 'login_page.dart';
import 'services/api_service.dart';

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

  @override
  void initState() {
    super.initState();
    // Seed services if collection is empty
    ApiService.seedServices();
  }

  // Featured services list
  final List<Map<String, dynamic>> featuredList = [
    {
      "image": "assets/cleaning.jpg",
      "title": "House Cleaning",
      "location": "Kathmandu",
      "rating": 4.4,
      "reviews": 10,
      "price": 1500,
    },
    {
      "image": "assets/house.jpg",
      "title": "House Painting",
      "location": "Kathmandu",
      "rating": 4.4,
      "reviews": 10,
      "price": 1500,
    },
    {
      "image": "assets/carpet.jpg",
      "title": "Carpet Cleaning",
      "location": "Kathmandu",
      "rating": 4.4,
      "reviews": 10,
      "price": 1500,
    },
    {
      "image": "assets/drapery.jpg",
      "title": "Sanitary Cleaning",
      "location": "Kathmandu",
      "rating": 4.4,
      "reviews": 10,
      "price": 1500,
    },
  ];

  // ---------------- HOME BODY ----------------
  Widget _homeBody() {
    final responsive = context.responsive;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding:
          EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
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
                        widget.userName ?? "Guest User",
                        style: TextStyle(
                          fontSize: responsive.responsiveFontSize(16,
                              tabletSize: 18, desktopSize: 20),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.notifications_none,
                      size: responsive.responsiveFontSize(28)),
                ],
              ),

              SizedBox(height: responsive.spacing(15)),

              // ---------------- SEARCH BAR ----------------
              Container(
                height: responsive.searchBarHeight,
                padding:
                EdgeInsets.symmetric(horizontal: responsive.spacing(12)),
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
                      child: Text(
                        "Search the services",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: responsive.responsiveFontSize(14),
                        ),
                      ),
                    ),
                    Icon(Icons.filter_list),
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
                            style: TextStyle(
                                fontSize:
                                responsive.responsiveFontSize(12))),
                      ],
                    )
                  ],
                ),
              ),

              SizedBox(height: responsive.spacing(20)),

              Text(
                "Featured Services",
                style: TextStyle(
                  fontSize: responsive.responsiveFontSize(18),
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: responsive.spacing(10)),

              // ---------------- FEATURED CARDS GRID ----------------
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: featuredList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: responsive.getGridCrossAxisCount(),
                  mainAxisExtent: responsive.isMobile ? 260 : 280,
                  crossAxisSpacing: responsive.spacing(15),
                  mainAxisSpacing: responsive.spacing(15),
                ),
                itemBuilder: (context, index) {
                  final item = featuredList[index];
                  return serviceCard(
                    image: item["image"],
                    title: item["title"],
                    location: item["location"],
                    price: "Npr ${item['price']}",
                    rating: item["rating"],
                    reviews: item["reviews"],
                  );
                },
              ),
            ],
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
    required String image,
    required String title,
    required String location,
    required String price,
    required double rating,
    required int reviews,
  }) {
    final responsive = context.responsive;

    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ServiceDetailCard()));
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
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
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
                    style: TextStyle(
                        fontSize: responsive.responsiveFontSize(12))),
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
              ),
            ),

            SizedBox(height: responsive.spacing(5)),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsive.spacing(8)),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey),
                  Text(location,
                      style: TextStyle(
                          fontSize: responsive.responsiveFontSize(12))),
                ],
              ),
            ),

            const Spacer(),

            Padding(
              padding: EdgeInsets.all(responsive.spacing(10)),
              child: Text(
                price,
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

  // ---------------- PROFILE DIALOG ----------------
  void _showProfileDialog(BuildContext context) {
    final responsive = context.responsive;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                widget.userName ?? "Guest User",
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
                  widget.userType ?? "Customer",
                  style: TextStyle(
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(height: responsive.spacing(20)),

              _infoRow(Icons.email, "Email", widget.userEmail),
              SizedBox(height: responsive.spacing(12)),
              _infoRow(Icons.phone, "Phone", widget.userPhone),
              SizedBox(height: responsive.spacing(12)),
              _infoRow(Icons.location_on, "Address", widget.userAddress),

              SizedBox(height: responsive.spacing(24)),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(
                      vertical: responsive.spacing(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Close",
                    style: TextStyle(color: Colors.white)),
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
                widget.userName ?? "Guest User",
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
                  widget.userType ?? "Customer",
                  style: TextStyle(
                      color: Colors.green.shade900,
                      fontSize: responsive.responsiveFontSize(16),
                      fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(height: responsive.spacing(30)),

              _infoRow(Icons.email, "Email", widget.userEmail),
              SizedBox(height: responsive.spacing(12)),
              _infoRow(Icons.phone, "Phone", widget.userPhone),
              SizedBox(height: responsive.spacing(12)),
              _infoRow(Icons.location_on, "Address", widget.userAddress),

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
                  // Navigate back to login page
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

  // ---------------- MAIN UI ----------------
  @override
  Widget build(BuildContext context) {
    final List<BottomNavigationBarItem> navItems = const [
      BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
      BottomNavigationBarItem(icon: Icon(Icons.access_time), label: "Activity"),
      BottomNavigationBarItem(icon: Icon(Icons.book_online), label: "Booking"),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
    ];

    final pages = [
      _homeBody(),
      const ActivityPage(),
      const Center(child: Text("Booking")),
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
