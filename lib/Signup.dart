import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:store/login.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  final TextEditingController _usernamecontroller = TextEditingController();
  String errormessage = 'Failed';

  Future<void> _signup() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailcontroller.text.trim(), password: _passwordcontroller.text.trim());
      _emailcontroller.clear();
      _passwordcontroller.clear();
      _usernamecontroller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User signed up successfully')));
    }catch (e) {
      setState(() => errormessage = e.toString()

      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("PLEASE SIGN UP", style: TextStyle(fontSize: 26, color: Colors.black,
            fontWeight: FontWeight.bold
            ),),
            SizedBox(height: 50,),
            Padding(padding: EdgeInsets.symmetric(horizontal: 20),
              child:TextField(
                controller: _emailcontroller,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26, width: 3)
                  ),
                  labelText: 'Enter your userid', labelStyle: TextStyle(
                    fontStyle: FontStyle.italic
                ),
                ),
              ),),
            SizedBox(height: 16,),
            Padding(padding: EdgeInsets.symmetric(horizontal: 20),
              child:TextField(
                controller: _passwordcontroller,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26, width: 3)
                  ),
                  labelText: 'Enter your Password', labelStyle: TextStyle(
                    fontStyle: FontStyle.italic
                ),
                ),
              ),),
            SizedBox(height: 10,),
            Padding(padding: EdgeInsets.symmetric(horizontal: 20),
              child:TextField(
                controller: _usernamecontroller,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26, width: 3)
                  ),
                  labelText: 'Enter your Username', labelStyle: TextStyle(
                    fontStyle: FontStyle.italic
                ),
                ),
              ),),
            SizedBox(height: 20,),
            ElevatedButton(onPressed: (_signup), child: Text('SIGN UP')),
            SizedBox(height: 20,),
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
            }, child: Text("BACK TO LOGIN"))
          ],
        ),
      );
  }
}
