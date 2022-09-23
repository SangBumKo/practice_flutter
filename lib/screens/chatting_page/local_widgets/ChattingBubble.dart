import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_4.dart';
import 'package:get/get.dart';
import '../../../controllers/CurrentUserController.dart';
import '../../../models/ChattingModel.dart';

class ChattingBubble extends StatelessWidget {
  final ChattingModel chattingModel;
  CurrentUserController currentUserController =
  Get.put(CurrentUserController(), permanent: true);

  ChattingBubble({Key? key, required this.chattingModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMe = chattingModel.pk == currentUserController.user.value.pk!;
    return isMe
        ? getSenderView(
            ChatBubbleClipper4(type: BubbleType.sendBubble), context)
        : getReceiverView(
            ChatBubbleClipper4(type: BubbleType.receiverBubble), context);
  }

  getSenderView(CustomClipper clipper, BuildContext context) => ChatBubble(
        clipper: clipper,
        alignment: Alignment.topRight,
        margin: EdgeInsets.only(top: 20),
        backGroundColor: Colors.lightGreen,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Text(
            chattingModel.text,
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

  getReceiverView(CustomClipper clipper, BuildContext context) => ChatBubble(
        clipper: clipper,
        backGroundColor: Colors.grey,
        margin: EdgeInsets.only(top: 20),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Text(
            chattingModel.text,
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
}
