import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  ChatMessages({super.key});

  final _currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages...'),
          );
        }
        if (chatSnapshot.hasError) {
          return const Center(
            child: Text('Something goes wrong'),
          );
        }
        final loadedMessages = chatSnapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) {
            final chatMessage = loadedMessages[index].data();
            final nextMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;

            final currentMessageUserId = chatMessage['userId'];
            final nextMessageUserId =
                nextMessage != null ? nextMessage['userId'] : null;
            final nextUserIdIsSame = currentMessageUserId == nextMessageUserId;
            if (nextUserIdIsSame) {
              return MessageBubble.next(
                message: chatMessage['text'],
                isMe: _currentUser.uid == currentMessageUserId,
              );
            }
            return MessageBubble.first(
              userImage: chatMessage['userImage'],
              username: chatMessage['username'],
              message: chatMessage['text'],
              isMe: _currentUser.uid == currentMessageUserId,
            );
          },
        );
      },
    );
  }
}
