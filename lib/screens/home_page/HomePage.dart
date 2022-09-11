import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:practice_flutter/screens/search_group_page/SearchGroupPage.dart';
import '../create_group_page/CreateGroupPage.dart';
import 'package:practice_flutter/models/GroupModel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final isSelected = <bool>[false, false];
  final f = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Do You Like?'),
        backgroundColor: Color(0xFF86D58E),
      ),
      body: Stack(
        children: [
          viewGroupsStreamBuilder(),
          Positioned(
            child: searchOrCreateGroupButton(),
            bottom: 20,
            right: 20,
          ),
        ],
      ),
    );
  }

  StreamBuilder viewGroupsStreamBuilder() {
    return StreamBuilder<QuerySnapshot>(
        stream: f.collection('GROUPS').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //List<GroupModel>을 담고
            final List<GroupModel> _groupList = GroupModel(memberIdList: [])
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
                              child: Text(_group.leader!,
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
}
