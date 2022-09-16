import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:practice_flutter/controllers/UserController.dart';
import 'package:practice_flutter/screens/search_group_page/SearchGroupPage.dart';
import '../../models/UserModel.dart';
import '../create_group_page/CreateGroupPage.dart';
import 'package:practice_flutter/models/GroupModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _isSelected = <bool>[false, false];
  final f = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => verifyEmail());
  }

  Future verifyEmail() async {
    if (!_auth.currentUser!.emailVerified) {
      await Get.defaultDialog(
        titlePadding: EdgeInsets.all(20),
        title: '이메일 인증을 안하셨네요!',
        middleText: '전송 버튼을 누른 후 전송된 이메일의 링크를 눌러주세요!',
        barrierDismissible: false,
        contentPadding: EdgeInsets.all(20),
        confirm: AnimatedButton(
          onPress: () {
            _auth.currentUser!.sendEmailVerification();
            _timer = Timer.periodic(Duration(seconds: 3), (timer) async {
              await FirebaseAuth.instance.currentUser?.reload();
              final user = _auth.currentUser;
              //if (user?.emailVerified ?? false)
              if (user!.emailVerified == true) {
                timer.cancel();
                Get.back();
              }
            });
          },
          height: 35,
          width: 100,
          text: '전송',
          isReverse: true,
          textStyle: TextStyle(color: Colors.black),
          selectedTextColor: Colors.black,
          transitionType: TransitionType.LEFT_TO_RIGHT,
          selectedBackgroundColor: Colors.lightGreen,
          backgroundColor: Colors.white,
          borderColor: Colors.grey,
          borderRadius: 50,
          borderWidth: 2,
        ),
      );
      Get.snackbar('이메일 인증완료', '이제 마음껏 어플을 사용해보세요!',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    CurrentUserController currentUserController = Get.put(CurrentUserController(), permanent: true);
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text("Do You Like? ${currentUserController.user.value.gender}")),
        backgroundColor: const Color(0xFF86D58E),
      ),
      body: Stack(children: [
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: f.collection('USERS').doc(_auth.currentUser!.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              bool isJoinedGroup = snapshot.data!.get('joinedGroupName') != '';
              if (isJoinedGroup) {
                return Center(
                    child: OutlinedButton(
                  child: const Text('그룹 나가기'),
                  onPressed: () => exitCheckDialog(),
                ));
              }
              return Stack(children: [
                viewGroupsStreamBuilder(),
                Positioned(
                  child: searchOrCreateGroupButton(),
                  bottom: 20,
                  right: 20,
                )
              ]);
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ]),
    );
  }

  StreamBuilder viewGroupsStreamBuilder() {
    return StreamBuilder<QuerySnapshot>(
        stream: f.collection('GROUPS').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<GroupModel> _groupList = GroupModel(memberList: [])
                .dataListFromSnapshots(snapshot.data!.docs);
            //final String genderOfCurrentUser = currentUserController.
            return GridView.builder(
                itemCount: _groupList.length,
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final GroupModel _group = _groupList[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_group.name!,
                              style: const TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold)),
                          const SizedBox(
                            height: 16.0,
                          ),
                          Expanded(
                              child: Text(_group.leader!.name!,
                                  overflow: TextOverflow.fade)),
                        ],
                      ),
                    ),
                  );
                });
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  ToggleButtons searchOrCreateGroupButton() {
    var _size = MediaQuery.of(context).size;
    return ToggleButtons(
      color: Colors.black.withOpacity(0.60),
      selectedColor: Color(0xFF86D58E),
      selectedBorderColor: Color(0xFF86D58E),
      fillColor: Color(0xFF86D58E).withOpacity(0.08),
      splashColor: Color(0xFF86D58E).withOpacity(0.12),
      hoverColor: Color(0xFF86D58E).withOpacity(0.04),
      borderRadius: BorderRadius.circular(4.0),
      constraints: BoxConstraints(minHeight: 36.0),
      isSelected: _isSelected,
      onPressed: (index) {
        if (index == 0) {
          setState(() {
            _isSelected[0] = true;
            _isSelected[1] = false;
          });
        } else {
          setState(() {
            _isSelected[0] = false;
            _isSelected[1] = true;
          });
        }
        openBottomSheet(index, _size);
      },
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('그룹 찾기'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('그룹 만들기'),
        ),
      ],
    );
  }

  void exitCheckDialog() {
    Get.defaultDialog(
      title: '정말 나가시겠습니까?',
      middleText: '리더가 그룹을 나갈 경우 그룹이 사라집니다.',
      barrierDismissible: false,
      contentPadding: EdgeInsets.all(20),
      textConfirm: '예',
      onConfirm: () => exitGroup(),
      confirmTextColor: Colors.black,
      textCancel: '아니오',
      cancelTextColor: Colors.black,
    );
  }

  Future<void> exitGroup() async {
    DocumentSnapshot<Map<String, dynamic>> userDocument =
        await f.collection('USERS').doc(_auth.currentUser!.uid).get();
    UserModel user = UserModel.fromSnapshot(userDocument);
    GroupModel group = GroupModel.fromSnapshot(
        await f.collection('GROUPS').doc(user.joinedGroupName).get());

    if (group.leader!.pk == user.pk) {
      await f.collection('GROUPS').doc(user.joinedGroupName).delete();
      group.memberList.forEach((member) {
        f.collection('USERS').doc(member.pk).update({'joinedGroupName': ''});
      });
    } else {
      group.memberList =
          group.memberList.where((member) => member.pk != user.pk).toList();
      await f.collection('GROUPS').doc(user.joinedGroupName).update(
          {'memberList': group.memberList.map((e) => e.toJson()).toList()});
      await f.collection('USERS').doc(user.pk).update({'joinedGroupName': ''});
    }
    Get.back();
  }

  void openBottomSheet(int index, Size size) {
    Get.bottomSheet(
      SizedBox(
        height: size.height * 0.8,
        child: Column(children: <Widget>[
          Row(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  index == 0 ? '방 찾기!' : '방 만들기!',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              )),
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.grey,
                ),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          index == 0 ? const SearchGroupPage() : const CreateGroupPage(),
        ]),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }
}
