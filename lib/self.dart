import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:store/service_detail.dart';
import 'package:url_launcher/url_launcher.dart';

class Self extends StatefulWidget {
  const Self({super.key});

  @override
  State<Self> createState() => _SelfState();
}

class _SelfState extends State<Self> {
  String? call;
  String? url;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('config')
          .doc('map')
          .get();
      setState(() {
        call = doc.data()?['call'] as String?;
        url = doc.data()?['url'] as String?;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> launchMap() async {
    if (url != null && url!.isNotEmpty) {
      final uri = Uri.parse(url!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print('Could not launch $url');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location not available')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppBar(
            leading: IconButton(onPressed: (){
              Navigator.pop(context);
            }, icon: Icon(Icons.arrow_back_ios_rounded)),
            backgroundColor: Colors.green.shade100,
          ),
          SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
            child: Text(
              "Please Reach our Service Center",
              style: GoogleFonts.redRose(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 40),
          Container(
            width: 300,
            child: Column(
              children: [
                Text("Service Center address :", style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.bold),),
                SizedBox(height: 20,),
                Text(call != null ? '$call' : ''),
              ],
            ),
          ),
          SizedBox(height: 40,),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 60),
            child: Container(
              child: Column(
                children: [
                  Text("-- Slide below to visit our service store --", style: GoogleFonts.eduSaBeginner(
                      fontSize: 19
                  ),),SizedBox(height: 30,),
                  SlideAction(
                      text: 'Slide to Navigate', textStyle: GoogleFonts.saira(fontSize: 16),
                      innerColor: Colors.white,
                      outerColor: Colors.purple.shade50,
                      onSubmit: launchMap,
                      sliderButtonIcon: CircleAvatar(
                        radius: 10,
                        child: Image.asset('assets/maps.png', fit: BoxFit.contain,),
                      )
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
