import 'package:cafeteria/core/widgets/loading_widget.dart';
import 'package:cafeteria/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'meal_detail_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Today\'s Menu'), centerTitle: true),
      body: FutureBuilder<String?>(
        future: FirestoreService().users
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((doc) => doc['selectedCanteen'] as String?),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoadingWidget();
          final canteenId = snapshot.data!;

          return StreamBuilder<QuerySnapshot>(
            stream: FirestoreService().instance
                .collection('menus')
                .doc(canteenId)
                .collection(today)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LoadingWidget();

              final mealTypes = snapshot.data!.docs;
              return ListView.builder(
                itemCount: mealTypes.length,
                itemBuilder: (context, index) {
                  final mealDoc = mealTypes[index];
                  final mealType = mealDoc.id;

                  return ExpansionTile(
                    title: Text(
                      mealType.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: mealDoc.reference
                            .collection('foods')
                            .snapshots(),
                        builder: (context, foodSnapshot) {
                          if (!foodSnapshot.hasData)
                            return const Padding(
                              padding: EdgeInsets.all(8),
                              child: LoadingWidget(),
                            );
                          return Column(
                            children: foodSnapshot.data!.docs.map((foodDoc) {
                              final data =
                                  foodDoc.data() as Map<String, dynamic>;
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.orange[100],
                                  child: const Icon(Icons.restaurant_menu),
                                ),
                                title: Text(
                                  foodDoc.id,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  data['vegetables']?.join(', ') ?? 'No sides',
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MealDetailScreen(
                                      canteenId: canteenId,
                                      date: today,
                                      mealType: mealType,
                                      foodName: foodDoc.id,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Menu'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {},
      ),
    );
  }
}
