import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:practice_flutter/controllers/CurrentUserController.dart';
import 'package:practice_flutter/screens/chatting_page/ChattingPage.dart';
import 'package:practice_flutter/screens/search_group_page/SearchGroupPage.dart';
import '../../controllers/CurrentChattingPageController.dart';
import '../../controllers/CurrentGroupController.dart';
import '../../models/UserModel.dart';
import '../../utils/Functions.dart';
import '../create_group_page/CreateGroupPage.dart';
import 'package:practice_flutter/models/GroupModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final f = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _isSelected = [false, false];
  late Timer _timer;
  bool _loading = true;
  int _currentNavBarIndex = 0;
  final CurrentUserController currentUserController =
      Get.put(CurrentUserController());
  final CurrentGroupController currentGroupController =
      Get.put(CurrentGroupController());
  final CurrentChattingPageController currentChattingPageController =
      Get.put(CurrentChattingPageController(), permanent: true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await firstUpdateController();
      verifyEmail();
      setState(() {
        _loading = false;
      });
      if (currentUserController.user.value.chattingRoomKey != null) {
        currentChattingPageController.fixCollectionRef(
            currentUserController.user.value.chattingRoomKey!);
        // DocumentSnapshot exitCountDocumentSnapshot = await currentChattingPageController.collectionRef.doc('exitCount').get();
        //
        // currentChattingPageController.updateExitCount(newExitCount);
        Get.to(() => ChattingPage());
      }
    });
  }

  Future firstUpdateController() async {
    //User
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await f.collection('USERS').doc(_auth.currentUser!.uid).get();
    currentUserController.user(UserModel.fromSnapshot(documentSnapshot));
    //Group
    if (currentUserController.user.value.joinedGroupGk != '') {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await f
          .collection('GROUPS')
          .doc(currentUserController.user.value.joinedGroupGk)
          .get();
      currentGroupController
          .updateCurrentGroup(GroupModel.fromSnapshot(documentSnapshot));
    }
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
  //HomePage 구조
  Widget build(BuildContext context) {
    return _loading
        ? Scaffold(body: Center(child: CircularProgressIndicator()))
        : getScaffoldByGroupState();
  }

  Widget getScaffoldByGroupState() {
    return Obx((){
      return currentGroupController.group.value.gk == null
          ? outOfGroup()
          : inGroup();
    });
  }

  Scaffold outOfGroup() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Do You Like'),
      ),
      body: Stack(children: [
        SizedBox.expand(),
        viewGroupsList(userJoinedGroup: false),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: searchOrCreateGroupButton(),
          ),
        ),
      ]),
    );
  }

  Scaffold inGroup() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Do You Like'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text('그룹 나가기'),
              onPressed: () => exitCheckDialog(),
            ),
          )
        ],
      ),
      body: (_currentNavBarIndex < 3)
          ? Stack(children: [
              SizedBox.expand(),
              viewGroupsList(userJoinedGroup: true),
            ])
          : Container(),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentNavBarIndex,
        onTap: (i) => setState(() => _currentNavBarIndex = i),
        items: [
          /// Home
          SalomonBottomBarItem(
            icon: Icon(Icons.search),
            title: Text("Match Group"),
            selectedColor: Colors.purple,
          ),

          /// Likes
          SalomonBottomBarItem(
            icon: Icon(Icons.favorite_border),
            title: Text("Likes Sent"),
            selectedColor: Colors.pink,
          ),

          /// Search
          SalomonBottomBarItem(
            icon: Icon(Icons.favorite),
            title: Text("Likes Got"),
            selectedColor: Colors.orange,
          ),

          /// Profile
          SalomonBottomBarItem(
            icon: Icon(Icons.person),
            title: Text("Group Profile"),
            selectedColor: Colors.teal,
          ),
        ],
      ),
    );
  }

  //Body에 들어갈 위젯
  StreamBuilder viewGroupsList({required bool userJoinedGroup}) {
    return StreamBuilder<QuerySnapshot>(
        stream: f.collection('GROUPS').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<GroupModel> unfilteredGroupList =
                GroupModel(memberList: [])
                    .dataListFromSnapshots(snapshot.data!.docs);
            final filteredGroupList =
                filterGroupList(unfilteredGroupList, userJoinedGroup);
            if (filteredGroupList.isEmpty)
              return Center(child: Text('조건에 맞는 그룹이 없어요 ㅠㅠ'));

            return GridView.builder(
                itemCount: filteredGroupList.length,
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final GroupModel group = filteredGroupList[index];
                  return createCard(group);
                });
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  GestureDetector createCard(GroupModel group) {
    return GestureDetector(
      onLongPress: () => getCustomDialog(
          group, currentUserController.user.value.joinedGroupGk != ''),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name!,
                      style: TextStyle(
                          color: group.isFreezed
                              ? Colors.black
                              : Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Expanded(
                    child: Text(group.leader!.name!,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                          color: group.isFreezed
                              ? Colors.black
                              : Colors.black,
                        )),
                  ),
                ],
              ),
            ),
            group.isFreezed ?
            Positioned(
              bottom : 10,
              right: 10,
              child: Text('FREEZE',
                  style: TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold))) : SizedBox(height: 0, width: 0,),
          ],
        ),
      ),
    );
  }

  ToggleButtons searchOrCreateGroupButton() {
    var _size = Get.size;
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
        openBottomSheet(index == 0 ? 'search' : 'create', _size);
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

  //다이얼로그 & 바텀시트
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
    UserModel currentUser = currentUserController.user.value;
    GroupModel currentGroup = currentGroupController.group.value;

    if (currentGroup.leader!.pk == currentUser.pk) {
      await currentGroupController.clearLikesBeforeBomb();
      await f.collection('GROUPS').doc(currentUser.joinedGroupGk).delete();
      currentGroup.memberList.forEach((member) {
        f.collection('USERS').doc(member.pk).update({'joinedGroupGk': ''});
      });
    } else {
      List<UserModel> newMemberList = currentGroup.memberList
          .where((member) => member.pk != currentUser.pk)
          .toList();
      currentGroupController.updateCurrentGroupMemberList(newMemberList);
      await f.collection('GROUPS').doc(currentGroup.gk).update({
        'memberList': currentGroup.memberList.map((e) => e.toJson()).toList()
      });
      await f
          .collection('USERS')
          .doc(currentUser.pk)
          .update({'joinedGroupGk': ''});
    }
    currentGroupController.updateCurrentGroup(GroupModel(memberList: []));
    currentUserController.updateJoinedGroupGk('');
    Get.back();
  }

  void openBottomSheet(String goal, Size size) {
    Map<String, Widget> showWidgetData = {
      'search': SearchGroupPage(),
      'create': CreateGroupPage()
    };
    Map<String, String> showTextData = {'search': '방 찾기!', 'create': '방 만들기!'};
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
                  showTextData[goal]!,
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
          showWidgetData[goal]!,
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

  void getCustomDialog(GroupModel group, bool userJoinedGroup) {
    final bool isLeader = userJoinedGroup ? currentGroupController.group.value.leader!.pk ==
        currentUserController.user.value.pk : false;
    // final bool isCurrentGroupFull =
    //     currentGroupController.group.value.memberList.length ==
    //         currentGroupController.group.value.capacity;
    // final bool isTargetGroupFull = group.memberList.length == group.capacity;
    if (!userJoinedGroup) {
      Get.defaultDialog(
        title: group.name!,
        content: Column(
          children: [
            Text('최대 인원 : ${group.capacity!.toString()}'),
            Text('방장 : ${group.leader!.name!}'),
            Text('전공 : ${group.leader!.major!}'),
            Text('학번 : ${group.leader!.entranceYear.toString()}'),
          ],
        ),
        confirm: OutlinedButton(
          child: Text('Join!'),
          onPressed: () => joinGroup(group),
        ),
      );
    }

    ///sendLike Button
    else if (_currentNavBarIndex == 0) {
      Get.defaultDialog(
        title: group.name!,
        content: Column(
          children: [
            Text('최대 인원 : ${group.capacity!.toString()}'),
            Text('방장 : ${group.leader!.name!}'),
            Text('전공 : ${group.leader!.major!}'),
            Text('학번 : ${group.leader!.entranceYear.toString()}'),
          ],
        ),
        confirm: OutlinedButton(
          child: Text('Like!'),
          onPressed: () {
            currentGroupController.sendLike(group);
            Get.back();
          },
        ),
      );
    }

    ///cancel Button
    else if (_currentNavBarIndex == 1) {
      Get.defaultDialog(
        title: group.name!,
        content: Column(
          children: [
            Text('최대 인원 : ${group.capacity!.toString()}'),
            Text('방장 : ${group.leader!.name!}'),
            Text('전공 : ${group.leader!.major!}'),
            Text('학번 : ${group.leader!.entranceYear.toString()}'),
          ],
        ),
        confirm: OutlinedButton(
          child: Text('Cancel!'),
          onPressed: () {
            currentGroupController.cancelLike(group);
            Get.back();
          },
        ),
      );
    } else {
      Get.defaultDialog(
        title: group.name!,
        content: Column(
          children: [
            Text('최대 인원 : ${group.capacity!.toString()}'),
            Text('방장 : ${group.leader!.name!}'),
            Text('전공 : ${group.leader!.major!}'),
            Text('학번 : ${group.leader!.entranceYear.toString()}'),
          ],
        ),
        confirm: Visibility(
          visible: isLeader,

          ///내가 isNotFull이어도 accept x / 상대가 isNotFull이어도 accept x
          child: group.isFreezed
              ? OutlinedButton(
                  child: Text('Freezed Or isNotFull!'),
                  onPressed: () {},
                )
              : OutlinedButton(
                  child: Text('Accept!'),
                  onPressed: () async {
                    await currentGroupController.acceptLike(group);
                  },
                ),
        ),
        cancel: OutlinedButton(
          child: Text('Deny!'),
          onPressed: () {
            currentGroupController.denyLike(group);
            Get.back();
          },
        ),
      );
    }
  }

  //그룹 필터
  List<GroupModel> filterGroupList(
      List<GroupModel> unfilteredGroupList, bool userJoinedGroup) {
    final UserModel currentUser = currentUserController.user.value;
    final GroupModel currentGroup = currentGroupController.group.value;

    if (!userJoinedGroup) {
      return unfilteredGroupList.where((group) {
        final bool isGenderSame = group.leader!.gender == currentUser.gender!;
        final bool isFull = group.memberList.length == group.capacity!;
        return (isGenderSame && !isFull);
      }).toList();
    }
    //match -> likes sent & likes got 제외하고 넣어야 함
    else if (_currentNavBarIndex == 0) {
      return unfilteredGroupList.where((group) {
        final bool isGenderSame = group.leader!.gender == currentUser.gender!;
        final bool isFull = group.memberList.length == group.capacity!;
        final bool? isCapacitySame = group.capacity == currentGroup.capacity;
        final bool isLikeSent = currentGroup.likesSent.contains(group.gk);
        final bool isLikeGot = currentGroup.likesGot.contains(group.gk);
        return (!isGenderSame &&
            isFull &&
            isCapacitySame! &&
            !isLikeSent &&
            !isLikeGot);
      }).toList();
    }
    //likes sent
    else if (_currentNavBarIndex == 1) {
      return unfilteredGroupList.where((group) {
        return currentGroup.likesSent.contains(group.gk);
      }).toList();
    }
    //likes got
    else {
      return unfilteredGroupList.where((group) {
        return currentGroup.likesGot.contains(group.gk);
      }).toList();
    }
  }
}
