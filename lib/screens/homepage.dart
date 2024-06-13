import 'package:chat_messenger/screens/chatpage.dart';
import 'package:chat_messenger/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String sendername = "";
  //instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //signout user
  Future<void> signout() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.signOut();
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        shadowColor: Colors.black,
        backgroundColor: const Color.fromARGB(255, 78, 87, 78),
        foregroundColor: Colors.white,
        
       
        title: Padding(
          padding: const EdgeInsets.only(left: 0, top: 05,right: 100),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 50,
                width: 40,
                child: ClipRRect(
                   borderRadius: BorderRadius.circular(15),
                  child: Image.asset('assets/img/chat.gif'),
                ),
              ),
              const Text("Chats",style: TextStyle(fontSize: 25),)
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: signout,
          ),
        ],
      ),
      body: _buidlUserList(),
    );
  }

  //build a list of user for the current logged in user

  Widget _buidlUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("users").snapshots(),
      builder: (context, snapshot) {
        return snapshot.hasError
            ? const Center(
                child: Text("Error on getting data"),
              )
            : snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: snapshot.data!.docs
                        .map<Widget>((doc) => _buidlUserListItem(doc))
                        .toList(),
                  );
      },
    );
  }

//buidl individual list item
  Widget _buidlUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    if (_auth.currentUser!.uid == data["uid"]) {
      sendername = data["name"];
    }

    print(sendername);

    //display all user except current user
    if (_auth.currentUser!.uid != data["uid"]) {
      return Column(
        children: [
          ListTile(
            leading: const Icon(
              Icons.account_circle,
              size: 40,
            ),
            title: Text(
              data["name"],
              style: const TextStyle(fontSize: 18),
            ),
            onTap: () {
              // pass the clicked user's uid to the chat page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    senderName: sendername,
                    recieverName: data["name"],
                    recieverUserID: data["uid"],
                  ),
                ),
              );
            },
          ),
          const Divider(),
        ],
      );
    } else {
      return Container();
    }
  }
}
