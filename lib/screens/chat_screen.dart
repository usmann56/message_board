import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String boardName;
  final String boardId;

  const ChatScreen({super.key, required this.boardName, required this.boardId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final user = _auth.currentUser!;
    final uid = user.uid;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final userName = userDoc.data()?['firstName'] ?? "Unknown";

    await FirebaseFirestore.instance
        .collection('messageBoards')
        .doc(widget.boardId)
        .collection('messages')
        .add({
          'text': _messageController.text.trim(),
          'senderId': user.uid,
          'senderName': userName,
          'timestamp': FieldValue.serverTimestamp(),
        });

    _messageController.clear();
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return "Today";
    }

    final yesterday = now.subtract(Duration(days: 1));
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return "Yesterday";
    }

    return DateFormat("MMM dd").format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.boardName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messageBoards')
                  .doc(widget.boardId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == _auth.currentUser!.uid;

                    Timestamp? ts = msg['timestamp'];
                    DateTime messageTime = (ts != null)
                        ? ts.toDate().toLocal()
                        : DateTime.now();

                    bool showDateHeader = false;
                    if (index == 0) {
                      showDateHeader = true;
                    } else {
                      Timestamp? prevTs = messages[index - 1]['timestamp'];
                      DateTime prevDate = (prevTs != null)
                          ? prevTs.toDate().toLocal()
                          : DateTime.now();

                      if (prevDate.day != messageTime.day ||
                          prevDate.month != messageTime.month ||
                          prevDate.year != messageTime.year) {
                        showDateHeader = true;
                      }
                    }

                    bool showSenderName = false;
                    if (!isMe) {
                      if (index == 0) {
                        showSenderName = true;
                      } else {
                        final prevMsg = messages[index - 1];
                        if (prevMsg['senderId'] != msg['senderId']) {
                          showSenderName = true;
                        }
                      }
                    }

                    return Column(
                      children: [
                        if (showDateHeader)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              formatDate(messageTime),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (showSenderName)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    msg['senderName'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),

                              Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.symmetric(vertical: 3),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? Colors.green[300]
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        msg['text'],
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      DateFormat('HH:mm').format(messageTime),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: "Message",
                          border: InputBorder.none,
                        ),
                        minLines: 1,
                        maxLines: 6,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.green,
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
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
