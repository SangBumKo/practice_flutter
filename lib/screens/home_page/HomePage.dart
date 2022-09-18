import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:practice_flutter/controllers/CurrentUserController.dart';
import 'package:practice_flutter/screens/search_group_page/SearchGroupPage.dart';
import '../../controllers/CurrentGroupController.dart';
import '../../models/UserModel.dart';
import '../create_group_page/CreateGroupPage.dart';
import 'package:practice_flutter/models/GroupModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:like_button/like_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CurrentUserController currentUserController =
      Get.put(CurrentUserController(), permanent: true);
  CurrentGroupController currentGroupController =
      Get.put(CurrentGroupController(), permanent: true);

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
    return Obx(() => currentGroupController.group.value.name == null
        ? outOfGroup()
        : inGroup());
  }

  Scaffold outOfGroup() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Do You Like? ${currentUserController.user.value.joinedGroupName}"),
        backgroundColor: const Color(0xFF86D58E),
      ),
      body: Stack(
        children: [
          SizedBox.expand(),
          viewMatchableGroupsList(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: searchOrCreateGroupButton(),
            ),
          ),
        ]
      ),
    );
  }

  Scaffold inGroup() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Do You Like?"),
        backgroundColor: const Color(0xFF86D58E),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom( backgroundColor: Colors.white),
              child: const Text('그룹 나가기'),
              onPressed: () => exitCheckDialog(),
            ),
          )
        ],
      ),
      body: Stack(
          children: [
            SizedBox.expand(),
            viewMatchableGroupsList(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  color: Colors.red,
                  icon: Icon(Icons.heart_broken),
                  onPressed: () => openBottomSheet('likes', Get.size),
                ),
              ),
            ),
          ]
      ),
    );
  }

  StreamBuilder viewMatchableGroupsList(){
    final UserModel currentUser = currentUserController.user.value;
    final GroupModel currentGroup =
    currentGroupController.group.value;
    return StreamBuilder<QuerySnapshot>(
        stream: f.collection('GROUPS').snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            final List<GroupModel> unfilteredGroupList =
            GroupModel(memberList: [])
                .dataListFromSnapshots(snapshot.data!.docs);
            final List<GroupModel> filteredGroupList =
            unfilteredGroupList.where((group) {
              final bool isGenderSame =
                  group.leader!.gender == currentUser.gender!;
              final bool isFull = group.memberList.length == group.capacity!;
              //그룹에 들어가지 않으면 currentGorup.capacity == null임 그때 접근해서 null Error발생했던 것
              final bool? isCapacitySame = group.capacity ==
                  currentGroup.capacity;
              final bool userJoinedGroup = currentUser.joinedGroupName != '';
              if(userJoinedGroup) return (!isGenderSame && isFull && isCapacitySame!);
              return (isGenderSame && !isFull);
            }).toList();
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
        }
    );
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
  GestureDetector createCard(GroupModel group){
    return GestureDetector(
      onLongPress: () => Get.defaultDialog(
        title : group.name!,
        middleText: group.leader!.name!,
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name!,
                      style: const TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Expanded(
                      child: Text(group.leader!.name!,
                          overflow: TextOverflow.fade)),
                ],
              ),
            ),
            //그룹에 들어갔을 떄만 띄워주기
            currentUserController.user.value.joinedGroupName != '' ?
            Positioned(
              bottom: 10,
              right: 10,
              child: LikeButton(
                onTap: currentUserController.sendLike,
              ),
            ) : SizedBox(),
          ],
        ),
      ),
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

  Future<void> exitGroup() async{
    UserModel currentUser = currentUserController.user.value;
    GroupModel currentGroup = currentGroupController.group.value;
    print('${currentGroupController.group.value.name}');
    print('${currentGroup.leader!.pk}');
    print('${currentUser.pk}');
    print('${currentUser.joinedGroupName}');

    if (currentGroup.leader!.pk == currentUser.pk) {
      await f.collection('GROUPS').doc(currentUser.joinedGroupName).delete();
      currentGroup.memberList.forEach((member) {
        f.collection('USERS').doc(member.pk).update({'joinedGroupName': ''});
      });
    } else {
      List<UserModel> newMemberList = currentGroup.memberList.where((member) => member.pk != currentUser.pk).toList();
      currentGroupController.updateCurrentGroupMemberList(newMemberList);
      await f.collection('GROUPS').doc(currentGroup.name).update(
          {'memberList': currentGroup.memberList.map((e) => e.toJson()).toList()});
      await f.collection('USERS').doc(currentUser.pk).update({'joinedGroupName': ''});
    }
    currentGroupController.updateCurrentGroup(GroupModel(memberList: []));
    currentUserController.updateJoinedGroupName('');
    Get.back();
  }

  void openBottomSheet(String goal, Size size) {
    Map<String, Widget>showWidgetData = {'search': SearchGroupPage(), 'create': CreateGroupPage(), 'likes': Container()};
    Map<String, String>showTextData = {'search' : '방 찾기!', 'create' : '방 만들기!', 'likes' : '받은 하트'};
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
}
