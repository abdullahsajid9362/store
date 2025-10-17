import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfilesPage extends StatefulWidget {
  @override
  _UserProfilesPageState createState() => _UserProfilesPageState();
}

class _UserProfilesPageState extends State<UserProfilesPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String errorMessage = 'Failed';

  // Reference to users collection
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');

  Future<void> _signout() async{
    try{
      await FirebaseAuth.instance.signOut();
    }catch (e) {
      setState(() => errorMessage = e.toString());
    }
  }
  // Add
  Future<void> saveUser(String name, String email, int age) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // not logged in

    await usersCollection.doc(user.uid).set({
      'name': name,
      'email': email,
      'age': age,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // merge keeps existing data if updating

    _nameController.clear();
    _emailController.clear();
    _ageController.clear();
  }

  //  Delete
  Future<void> deleteUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await usersCollection.doc(user.uid).delete();
  }
  String extractUsername(String email) {
    return email.split('@')[0];
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("HI  !", style: TextStyle(fontSize: 18,
              fontWeight: FontWeight.bold,
              ),),
              Text(
                user != null ? extractUsername(user.email!) : 'UserProfile',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26, width: 1),
                    borderRadius: BorderRadius.circular(2)
                  )
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12, width: 1),
                    borderRadius: BorderRadius.circular(2),
                  )
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Age',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26, width: 1),
                  )
                  ),
                ),
                SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                child:
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        final name = _nameController.text;
                        final email = _emailController.text;
                        final age = int.tryParse(_ageController.text) ?? 0;
                        saveUser(name, email, age);
                      },
                      child: Text('Save/Update'),
                    ),
                    SizedBox(width: 12,),
                    ElevatedButton(
                      onPressed: deleteUser,
                      child: Text('Delete'),
                    ),
                    SizedBox(width: 16,),
                    ElevatedButton(onPressed: (_signout), child: Text('SIGN OUT'))
                  ],
                ),
                ),
              ],
            ),
          ),
          Expanded(
            child: user == null
                ? Center(child: Text("Not logged in"))
                : StreamBuilder<DocumentSnapshot>(
              stream: usersCollection.doc(user.uid).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: Text('No data'));

                final userData =
                snapshot.data!.data() as Map<String, dynamic>?;

                if (userData == null) return Center(child: Text("No profile"));

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.shade50,
                  ),
                  title: Text(userData['name'], style: TextStyle(
                    fontSize: 23, fontWeight: FontWeight.bold
                  ),),
                  subtitle: Text(
                      '${userData['email']} | Age: ${userData['age']}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
