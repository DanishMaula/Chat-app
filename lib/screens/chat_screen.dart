import 'package:chat_app/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _fireStore = FirebaseFirestore.instance;

late User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'CHAT_SCREEN';
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final _auth = FirebaseAuth.instance;



  late String message;

  final _textController = TextEditingController();

  late String formattedDate;
  late DateTime now;

  void getCurrentUser(){
    try{
      final user = _auth.currentUser;
      if(user != null){
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch(e){}
  }

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.forum),
        title: Text('Chat'),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);

              }, icon: const Icon(Icons.close))],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: TextStyle(color: Colors.black),
                      onChanged: (value) {
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          now = DateTime.now();
                          formattedDate = DateFormat('kk:mm:ss').format(now);
                        });
                        _textController.clear();
                        _fireStore
                            .collection('messages')
                            .add({'text' : message, 'sender' : loggedInUser.email!, 'time' : formattedDate});
                        //for send some message
                      },
                      child: Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  const MessageStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _fireStore.collection('messages')
            .orderBy('time', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            return Center(
            child: CircularProgressIndicator(
            backgroundColor: Colors.white,
            ),
            );

    }
          final messages = snapshot.data!.docs;
          List<MessageBubble> messageBubbles = [];
          for(var message in messages ){
            final messageText = message['text'];
            final messageSender = message['sender'];

            final currentUserEmail = loggedInUser.email;

            final messageWidget = MessageBubble(sender: messageSender, text: messageText,
            isMe : currentUserEmail == messageSender);
            messageBubbles.add(messageWidget);
            }
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: ListView(
                children: messageBubbles,
              ),
            ),
          );
    }
    );

  }
}

class MessageBubble extends StatelessWidget {

  final String sender;
  final String text;
  final bool isMe;

  const MessageBubble({Key? key, required this.sender, required this.text, required this.isMe }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(sender,
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
          Material(
            borderRadius: BorderRadius.circular(30),
              // topLeft: isMe ? Radius.circular(30) : Radius.circular(0),
              // topRight: isMe? Radius.circular(0) : Radius.circular(30),
              // bottomRight: Radius.circular(30),
              // bottomLeft: Radius.circular(30)

            elevation: 5,
            color: isMe ? Colors.lightBlue : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                text,
                style: TextStyle(
                    color:
                    isMe ? Colors.white : Colors.black54,
                    fontSize: 15),),
            ),
          )
        ],
      ),
    );
  }
}



  
  
  


