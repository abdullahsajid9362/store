import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfilesPage extends StatefulWidget {
  @override
  _UserProfilesPageState createState() => _UserProfilesPageState();
}

class _UserProfilesPageState extends State<UserProfilesPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');

  // Add a new user
  Future<void> addUser(String name, String email, int age) async {
    await usersCollection.add({
      'name': name,
      'email': email,
      'age': age,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _nameController.clear();
    _emailController.clear();
    _ageController.clear();
  }

  // Update a user
  Future<void> updateUser(String id, String name, String email, int age) async {
    await usersCollection.doc(id).update({
      'name': name,
      'email': email,
      'age': age,
    });
  }

  // Delete a user
  Future<void> deleteUser(String id) async {
    await usersCollection.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Profiles')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Age'),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        final name = _nameController.text;
                        final email = _emailController.text;
                        final age = int.tryParse(_ageController.text) ?? 0;
                        addUser(name, email, age);
                      },
                      child: Text('Add User'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: usersCollection.orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final users = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      title: Text(user['name']),
                      subtitle: Text('${user['email']} | Age: ${user['age']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _nameController.text = user['name'];
                              _emailController.text = user['email'];
                              _ageController.text = user['age'].toString();
                              // Optionally call updateUser after editing
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => deleteUser(user.id),
                          ),
                        ],
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
}
