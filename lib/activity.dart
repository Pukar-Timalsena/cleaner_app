import 'package:flutter/material.dart';
import 'responsive_utils.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  int selectedTab = 1; // 0 = Ongoing, 1 = Completed, 2 = Cancelled

  // --- Dummy data for each tab ---
  final ongoingList = [
    {"title": "Kitchen Cleaning", "date": "1 September, 2025", "price": "NPR 2000"},
    {"title": "Carpet Cleaning", "date": "2 September, 2025", "price": "NPR 1500"},
  ];

  final completedList = [
    {"title": "Drapery Cleaning", "date": "1 September, 2025", "price": "NPR 1000"},
    {"title": "Carpet Cleaning", "date": "1 September, 2025", "price": "NPR 1500"},
    {"title": "House Cleaning", "date": "1 September, 2025", "price": "NPR 3000"},
    {"title": "Carpet Cleaning", "date": "1 September, 2025", "price": "NPR 1500"},
  ];

  final cancelledList = [
    {"title": "Painting Service", "date": "29 August, 2025", "price": "NPR 2500"},
  ];

  // Choose correct list
  List<Map<String, String>> get currentList {
    switch (selectedTab) {
      case 0:
        return ongoingList;
      case 1:
        return completedList;
      case 2:
      default:
        return cancelledList;
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Activity",
          style: TextStyle(
            fontSize: responsive.responsiveFontSize(20, tabletSize: 22, desktopSize: 24),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
                    buildTabButton("Ongoing", 0, responsive),
                    buildTabButton("Completed", 1, responsive),
                    buildTabButton("Canceled", 2, responsive),
                  ],
                ),
              ),

              SizedBox(height: responsive.spacing(15)),

              // ----------- LIST VIEW ------------
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
                  itemCount: currentList.length,
                  itemBuilder: (context, index) {
                    final item = currentList[index];
                    return activityTile(item, responsive);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tab Button Widget
  Widget buildTabButton(String text, int index, ResponsiveUtils responsive) {
    bool isActive = selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.spacing(18),
          vertical: responsive.spacing(10),
        ),
        decoration: BoxDecoration(
          color: isActive ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: isActive ? [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: responsive.responsiveFontSize(14, tabletSize: 15, desktopSize: 16),
          ),
        ),
      ),
    );
  }

  // Service Tile Widget
  Widget activityTile(Map<String, String> item, ResponsiveUtils responsive) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: responsive.avatarRadius,
            backgroundImage: const AssetImage("assets/cleaning.jpg"), // change image
          ),
          title: Text(
            item["title"]!,
            style: TextStyle(
              fontSize: responsive.responsiveFontSize(16, tabletSize: 17, desktopSize: 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            item["date"]!,
            style: TextStyle(fontSize: responsive.responsiveFontSize(13, tabletSize: 14, desktopSize: 15)),
          ),
          trailing: Text(
            item["price"]!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: responsive.responsiveFontSize(14, tabletSize: 15, desktopSize: 16),
            ),
          ),
        ),
        Divider(color: Colors.grey.shade300)
      ],
    );
  }
}
