import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store/home.dart';
import 'package:store/self.dart';
import 'package:get/get.dart';

class ServiceDetailPage extends StatelessWidget {
  final String serviceId;

  const ServiceDetailPage({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    final serviceRef =
    FirebaseFirestore.instance.collection('services').doc(serviceId);

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: Text(
          serviceId.replaceAll('_', ' ').toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade50,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: serviceRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Service not found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Service Image
                if (data['image'] != null)
                  Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(data['image'],
                            fit: BoxFit.fill,
                                      height: 200),
                      ),
                    ),
                const SizedBox(height: 20),

                // Service Name
                Text(
                  data['name'] ?? '',
                  style: GoogleFonts.belanosima(fontSize: 28)
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  data['content'] ?? '',
                  style: GoogleFonts.mulish(fontSize: 16),
                ),
                const SizedBox(height: 10),

                // Availability
                Row(
                  children: [
                    const Text(
                      "Available: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Icon(
                      data['availability'] == true
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: data['availability'] == true
                          ? Colors.green
                          : Colors.red,
                    ),
                  ],
                ),
                const Divider(height: 30),

                // Prices Section
                 Text(
                  "Pricing Options",style: GoogleFonts.mulish(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),

                StreamBuilder<QuerySnapshot>(
                  stream: serviceRef.collection('prices').snapshots(),
                  builder: (context, priceSnap) {
                    if (priceSnap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!priceSnap.hasData ||
                        priceSnap.data!.docs.isEmpty) {
                      return const Text("No prices found.");
                    }

                    return Column(
                      children: priceSnap.data!.docs.map((doc) {
                        final priceData = doc.data() as Map<String, dynamic>;
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          child: ListTile(
                              title: Text(priceData['type'] ?? 'Unknown Type', style:
                               GoogleFonts.mulish(fontSize: 18, )
                                ,),
                              trailing: Text(
                                '₹${priceData['price'] ?? '-'}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16, fontWeight: FontWeight.bold
                                )
                                ),
                              ),
                        );
                      }).toList(),
                    );
                  },
                ),
                SizedBox(height: 30,),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Container(
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(onPressed: (){Get.to(Self(), transition: Transition.rightToLeftWithFade,
                  duration: Duration(milliseconds: 600),
                  );}, child: Text("Self Drop  &\n Pickup",
                    style: GoogleFonts.alegreya(fontSize: 14, color: Colors.black),
                  )),
                ),
                SizedBox(width: 8,),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    child: ElevatedButton(onPressed: (){Get.to(Home(), transition:
                    Transition.rightToLeft, duration: Duration(milliseconds: 600),
                    );}, child: Text("Home Pickup  &\n Drop",
                      style: GoogleFonts.alegreya(fontSize: 14, color: Colors.black),
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
