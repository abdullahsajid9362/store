import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  List<String> options = [];
  String? pickupCharge;
  bool isSwitched = false;
  bool isChecked = false;
  String? selectedValue;

  //controller
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();


  Future<void> addion() async {
    try {
      final doc =
      await FirebaseFirestore.instance.collection('config').doc('map').get();
      setState(() {
        pickupCharge = doc.data()?['add'] as String?;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchservices() async {
    try {
      final querySnapshot =
      await FirebaseFirestore.instance.collection('services').get();

      final fetchedOptions = querySnapshot.docs.map((doc) => doc.id).toList();

      setState(() {
        options = fetchedOptions;
      });
    } catch (e) {
      print('Error fetching list: $e');
    }
  }

  Future<void> submitDetails() async {
    if (selectedValue == null ||
        nameController.text.isEmpty ||
        addressController.text.isEmpty ||
        landmarkController.text.isEmpty ||
        phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select a service')),
      );
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('bookings').add({
        'service': selectedValue,
        'name': nameController.text.trim(),
        'pickup': addressController.text.trim(),
        'landmark': landmarkController.text.trim(),
        'phone': phoneController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Details submitted successfully')),
      );

      // Clear inputs after submission
      setState(() {
        selectedValue = null;
        isSwitched = false;
        isChecked = false;
      });
      nameController.clear();
      addressController.clear();
      landmarkController.clear();
      phoneController.clear();
    } catch (e) {
      print('Error submitting details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit details: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    addion();
    fetchservices();
  }
  @override
  void dispose() {
    // Dispose controllers when widget is disposed
    nameController.dispose();
    addressController.dispose();
    landmarkController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isSwitched ? Colors.green.shade100 : Colors.red.shade100,
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedPadding(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Card(
                  color: isSwitched ? Colors.green.shade50 : Colors.red.shade50,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                          color: isSwitched ? Colors.transparent : Colors.red)),
                  child: ListTile(
                    leading: Switch(
                        value: isSwitched,
                        onChanged: (bool value) {
                          setState(() {
                            isSwitched = value;
                          });
                        }),
                    title: Text(
                      pickupCharge != null
                          ? 'Additional charges of ₹$pickupCharge for pickup service'
                          : 'Loading additional pickup charges ',
                      style: GoogleFonts.sairaSemiCondensed(fontSize: 16),
                    ),
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                child: isSwitched
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 6),
                      child: SizedBox(
                        height: 50,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            hint: Text(
                              'Select Service',
                              style: GoogleFonts.genos(
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            items: options
                                .map((option) => DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            ))
                                .toList(),
                            value: selectedValue,
                            onChanged: (val) {
                              setState(() {
                                selectedValue = val;
                              });
                            },
                            buttonStyleData: ButtonStyleData(
                              padding: const EdgeInsets.symmetric(horizontal:18, vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(
                                  color: Colors.black,
                                ),
                                color: Colors.green.shade100,
                              ),
                              elevation: 2,
                            ),
                            iconStyleData: const IconStyleData(
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                              ),
                              iconSize: 14,
                              iconEnabledColor: Colors.black,
                              iconDisabledColor: Colors.grey,
                            ),
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 200,
                              width: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: Colors.green.shade50,
                              ),
                              offset: const Offset(10, 0),
                              scrollbarTheme: ScrollbarThemeData(
                                radius: const Radius.circular(4),
                                thickness: MaterialStateProperty.all<double>(6),
                                thumbVisibility: MaterialStateProperty.all<bool>(true),
                              ),
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 40,
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 6),
                      //Name text
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Enter your Name',
                          hintStyle: GoogleFonts.genos(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                          ),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          fillColor: Colors.blue.shade50,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 6),
                      //address text
                      child: TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          hintText: 'Enter your Pickup address',
                          hintStyle: GoogleFonts.genos(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                          ),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          fillColor: Colors.blue.shade50,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 6),
                      //landmark text
                      child: TextField(
                        controller: landmarkController,
                        decoration: InputDecoration(
                          hintText: 'Enter any Landmark',
                          hintStyle: GoogleFonts.genos(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                          ),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          fillColor: Colors.blue.shade50,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 6),
                      //phone number text
                      child: TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          hintText: 'Enter your Phone number',
                          hintStyle: GoogleFonts.genos(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                          ),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          fillColor: Colors.blue.shade50,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Checkbox(
                              value: isChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  isChecked = value ?? false;
                                });
                              }),
                        ),
                        const Text("Call me to take confirmation"),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ],
                )
                    : const SizedBox.shrink(),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                child: isChecked
                    ? Column(
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade50),
                        onPressed: () {submitDetails();},
                        child: Text(
                          "Submit details",
                          style: GoogleFonts.montserrat(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ))
                  ],
                )
                    : const SizedBox.shrink(),
              ),
              SizedBox(height: 20,),

            ],
          ),
        ),
      ),
    );
  }
}
