import 'package:flutter/material.dart';
import 'package:roomfind/providers/customer_hotel_provider.dart';
import 'package:provider/provider.dart';
import 'hotel_detail_page.dart';
import 'package:roomfind/login_screen/user_login.dart';
import 'package:roomfind/screens/customer/bookings_page.dart';
class CustomerHomePage extends StatefulWidget {
  final String phoneNumber;

  const CustomerHomePage({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  final _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerProvider = Provider.of<CustomerHotelProvider>(context, listen: false);
      customerProvider.fetchCustomerProfile(widget.phoneNumber);
      customerProvider.fetchAllHotels();
    });
  }

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const UserLogin(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hotelProvider = Provider.of<CustomerHotelProvider>(context);
    if (hotelProvider.customerName != null) {
      debugPrint("Building Home Page. Current customer name: ${hotelProvider.customerName}");
    }

    return Scaffold(
      appBar: AppBar(
        title: Consumer<CustomerHotelProvider>(
          builder: (context, hotelProvider, _) {
            return Text("Welcome, ${hotelProvider.customerName ?? 'Customer'}");
          },
        ),
        backgroundColor: Colors.green,

      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.green,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Consumer<CustomerHotelProvider>(
                    builder: (context, hotelProvider, _) {
                      return Text(
                        hotelProvider.customerName ?? 'Customer',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.phoneNumber,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                _showNameChangeDialog(context, hotelProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Past Bookings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookingsPage(showUpcoming: false),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Upcoming Bookings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookingsPage(showUpcoming: true),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Add navigation to settings page
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Add navigation to help page
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: "Enter City",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  onPressed: () {
                    final city = _cityController.text.trim();
                    if (city.isNotEmpty) {
                      hotelProvider.fetchHotelsByCity(city);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter a city name.")),
                      );
                    }
                  },
                  child: const Text("Search", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<CustomerHotelProvider>(
              builder: (context, hotelProvider, _) {
                return hotelProvider.hotels.isEmpty
                    ? const Center(
                  child: Text(
                    "No hotels found.",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  itemCount: hotelProvider.hotels.length,
                  itemBuilder: (context, index) {
                    final hotel = hotelProvider.hotels[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(hotel['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(hotel['address']),
                        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.green),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HotelDetailPage(hotelId: hotel['hotelId']),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showNameChangeDialog(BuildContext context, CustomerHotelProvider hotelProvider) {
    final _nameController = TextEditingController(text: hotelProvider.customerName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Change Name"),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Enter new name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final newName = _nameController.text.trim();
                if (newName.isNotEmpty) {
                  hotelProvider.updateCustomerName(widget.phoneNumber, newName);
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}