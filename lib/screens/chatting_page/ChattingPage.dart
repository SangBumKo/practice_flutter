import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/CurrentChattingPageController.dart';
import '../../models/ChattingModel.dart';
import 'local_widgets/ChattingBubble.dart';

class ChattingPage extends StatefulWidget {
  @override
  _ChattingPageState createState() => _ChattingPageState();
}

///들어온 순간 exitCount setting done
class _ChattingPageState extends State<ChattingPage> {
  final TextEditingController _controller = TextEditingController();
  StreamSubscription? _streamSubscription;
  CurrentChattingPageController currentChattingPageController = Get.put(CurrentChattingPageController(), permanent: true);
  bool firstLoad = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await currentChattingPageController.load();

      _streamSubscription = currentChattingPageController.getSnapshot().listen((event) {
        if(firstLoad) {
          firstLoad = false;
          return;
        }
        currentChattingPageController.addOne(ChattingModel.fromJson(event.docs[0].data() as Map<String, dynamic>));
      });

      setState(() {
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _loading ? Scaffold(body: Center(child: CircularProgressIndicator())) :
    Scaffold(
      appBar: AppBar(
        title: Text('Do You Like'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => (ListView(
              reverse: true,
              children: currentChattingPageController.chattingList.value.map((e) => ChattingBubble(chattingModel: e)).toList(),
            ))),
          ),
          SizedBox(height: Get.size.height * 0.02,),
          Divider(
            thickness: 1.5,
            height: 1.5,
            color: Colors.grey[300],
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.grey, spreadRadius: 1),
              ],
            ),
            constraints: BoxConstraints(
                maxHeight: Get.size.height * .5),
            margin:
            EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(fontSize: 27),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '텍스트 입력',
                          hintStyle: TextStyle(color: Colors.grey[400])),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    var text = _controller.text;
                    _controller.text = '';
                    currentChattingPageController.send(text);
                    FocusScope.of(context).unfocus();
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                    child: Icon(
                      Icons.send,
                      size: 33,
                      color: Colors.lightGreen,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}