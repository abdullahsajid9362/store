import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:store/Signup.dart';
import 'package:store/Userprofilepage.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  bool isLogin = true;
  bool _obscuretext = true;
  String errorMessage ='No user Found';

  Future<void> _login() async{
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailcontroller.text.trim(), password: _passwordcontroller.text.trim(),);
      _emailcontroller.clear();
      _passwordcontroller.clear();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserProfilesPage()));
    }catch (e) {
      setState(() => errorMessage = e.toString() );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User details not valid, please SIGN UP!',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.purple.shade50,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("LOGIN", style: TextStyle(fontSize: 28, color: Colors.black),
            ),
            SizedBox(height: 50,),
            Padding(padding: EdgeInsets.symmetric(horizontal: 20),
        child:TextField(
          controller: _emailcontroller,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26, width: 3)
                ),
                labelText: 'Enter your username', labelStyle: TextStyle(
                fontStyle: FontStyle.italic
              ),
              ),
            ),),
            SizedBox(height: 10,),
            Padding(padding: EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _passwordcontroller,
              obscureText: _obscuretext,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26, width: 3),
                ),
                focusColor: Colors.red,
                labelText: 'Enter your Password', labelStyle: TextStyle(
                  fontStyle: FontStyle.italic,
              ),
                suffixIcon: IconButton(onPressed: (){
                  setState(() {
                    _obscuretext = !_obscuretext;
                  });
                }, icon: Icon(_obscuretext ? Icons.visibility_off: Icons.visibility),

                )
              ),
            ),),
            SizedBox(height: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("New Account ?", style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold
                ), ),
                TextButton(onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Signup()));
                }, child: Text("Press Here", style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue
                ),)),
              ],
            ),
            SizedBox(height: 20,),
            ElevatedButton(onPressed: _login, child: Text('LOG IN!')),
          ],
        ),
      );
  }
}
