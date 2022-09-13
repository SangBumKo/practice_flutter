import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:practice_flutter/screens/search_group_page/SearchGroupPage.dart';
import '../../models/UserModel.dart';
import '../create_group_page/CreateGroupPage.dart';
import 'package:practice_flutter/models/GroupModel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final isSelected = <bool>[false, false];
  final f = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Do You Like?'),
        backgroundColor: const Color(0xFF86D58E),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
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
    );
  }

  StreamBuilder viewGroupsStreamBuilder() {
    return StreamBuilder<QuerySnapshot>(
        stream: f.collection('GROUPS').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<GroupModel> _groupList = GroupModel(memberList: [])
                .dataListFromSnapshots(snapshot.data!.docs);
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
      isSelected: isSelected,
      onPressed: (index) {
        if (index == 0) {
          setState(() {
            isSelected[0] = true;
            isSelected[1] = false;
          });
          showModalBottomSheet<void>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              isScrollControlled: true,
              enableDrag: true,
              context: context,
              builder: (BuildContext context) {
                return Container(
                  height: _size.height * 0.7,
                  child: SearchGroupPage(),
                );
              });
        } else {
          setState(() {
            isSelected[1] = true;
            isSelected[0] = false;
          });
          showModalBottomSheet<void>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            isScrollControlled: true,
            enableDrag: true,
            context: context,
            builder: (BuildContext context) {
              return Container(
                  height: _size.height * 0.7,
                  child: Column(children: <Widget>[
                    Row(
                      children: [
                        Expanded(
                            child: Container(
                                child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                            '방 만들기!',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ))),
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: Colors.grey,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const CreateGroupPage()
                  ]));
            },
          );
        }
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
    showDialog(
        context: context,
        //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: Column(
              children: <Widget>[
                Text("정말 나가시겠습니까?"),
              ],
            ),
            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "리더의 경우 그룹을 나갈시 그룹이 사라집니다.",
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("예"),
                onPressed: () async {
                  DocumentSnapshot<Map<String, dynamic>> userDocument = await f
                      .collection('USERS')
                      .doc(_auth.currentUser!.uid)
                      .get();
                  UserModel user = UserModel.fromSnapshot(userDocument);
                  //Error
                  GroupModel group = GroupModel.fromSnapshot(await f
                      .collection('GROUPS')
                      .doc(user.joinedGroupName)
                      .get());
                  if (group.leader!.pk == user.pk) {
                    await f
                        .collection('GROUPS')
                        .doc(user.joinedGroupName)
                        .delete();
                    group.memberList.forEach((member) {
                      f
                          .collection('USERS')
                          .doc(member.pk)
                          .update({'joinedGroupName': ''});
                    });
                  }
                  else {
                    group.memberList = group.memberList.where((e) => e.pk != user.pk).toList();
                    await f
                        .collection('GROUPS')
                        .doc(user.joinedGroupName)
                        .update({'memberList':  group.memberList.map((e) => e.toJson())});
                    await f
                        .collection('USERS')
                        .doc(user.pk)
                        .update({'joinedGroupName': ''});
                  }
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text("아니요"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
