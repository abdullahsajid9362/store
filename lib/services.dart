import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:store/service_detail.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class ServiceListPage extends StatefulWidget {
  const ServiceListPage({super.key});

  @override
  State<ServiceListPage> createState() => _ServiceListPageState();
}

class _ServiceListPageState extends State<ServiceListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final ScrollController _scrollController = ScrollController();
  bool isCollapsed = false;
  double _containerOpacity = 0.0;

  Future<String> getslogan()async{
    try{
      DocumentSnapshot doc = await _firestore.collection('config').doc('map').get();
      if (doc.exists){
        final data = doc.data() as Map<String, dynamic>;
        return data['slogan'] ?? 'No Slogan';
      }else {
        return 'No Slogan Found';
      }
    }catch (e) {
      print("Error fetching slogan: $e");
      return 'Error loading slogan';
    }
  }

  // Fetch all services from Firestore
  Future<List<QueryDocumentSnapshot>> getAllServices() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('services').get();
      return snapshot.docs;
    } catch (e) {
      print("Error fetching services: $e");
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), (){
      setState(() {
        _containerOpacity = 1.0;
      });
    });

  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([getAllServices(), getslogan()]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No services available."));
          }

          final services = snapshot.data![0] as List<QueryDocumentSnapshot>;
          final slogan = snapshot.data![1] as String;

          return CustomScrollView(

            slivers: [
              SliverAppBar(
                title: Text("SERVICES", style: GoogleFonts.alegreya(fontSize: 24),),
                centerTitle: true,
                expandedHeight: 100,
                backgroundColor: Colors.blue.shade50,
                pinned: false,
                floating: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: AnimatedOpacity(
                      opacity: _containerOpacity,
                      duration: Duration(seconds: 1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green.shade50
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(slogan, style: GoogleFonts.jost(),),
                        ),
                      ),
                    )
                  )
                ),

              ),
              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final service =
                      services[index].data() as Map<String, dynamic>;
                      final serviceId = services[index].id;

                      return GestureDetector(
                        onTap: () {
                          Get.to(
                            ServiceDetailPage(serviceId: serviceId),
                            transition: Transition.rightToLeftWithFade,
                            duration: const Duration(milliseconds: 400),
                          );
                        },

                          child: Container(
                            height: 360,
                            width: 280,
                            decoration: const BoxDecoration(
                              color: Colors.white12,
                            ),
                            child: Card(
                              color: Colors.white70,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: service['image'] != null
                                          ? Image.network(
                                        service['image'],
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                          : Image.asset(
                                        'assets/oil.png',
                                        height: 150,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      service['name'] ?? 'No Name',
                                      style: GoogleFonts.jost(fontSize: 22),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      service['description'] ?? '',
                                      style: GoogleFonts.mulish(fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Text(
                                          "Available: ",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Icon(
                                          service['availability'] == true
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color: service['availability'] == true
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        const Spacer(),
                                        const Text(
                                          "Tap for details →",
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );

                    },
                    childCount: services.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
