import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firestore_search/firestore_search.dart';
import 'package:practice_flutter/models/GroupModel.dart';

import '../../models/UserModel.dart';

class SearchGroupPage extends StatefulWidget {
  const SearchGroupPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchGroupPageState();
}

class _SearchGroupPageState extends State<SearchGroupPage> {
  final f = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
                child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                '방 검색하기',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            )),
            IconButton(
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.grey,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        FirestoreSearchBar(
          tag: 'example',
        ),
        Expanded(
          //동성이랑, isFullx인 것들만 띄워주기
          child: FirestoreSearchResults.builder(
            tag: 'example',
            firestoreCollectionName: 'GROUPS',
            searchBy: 'name',
            dataListFromSnapshot:
                GroupModel(memberList: []).dataListFromSnapshot,
            builder: (context, snapshot) {
              if(snapshot.hasError){
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
              if (snapshot.hasData) {
                final List<GroupModel>? groupList = snapshot.data;
                if (groupList!.isEmpty) {
                  return const Center(
                    child: Text('검색결과가 없어요 ㅠㅠ'),
                  );
                }
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: groupList.length,
                    itemBuilder: (context, index) {
                      final GroupModel data = groupList[index];

                      return Container(
                        decoration: BoxDecoration(border: Border.all()),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 9,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${data.name}',
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 8.0, left: 8.0, right: 8.0),
                                    child: Text('${data.leader}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: OutlinedButton(
                                  //double check!
                                  child: const Text('Join!'),
                                  onPressed: () async {
                                    await f
                                        .collection('USERS')
                                        .doc(_auth.currentUser!.uid)
                                        .update({'joinedGroupName': data.name});
                                    GroupModel group = GroupModel.fromSnapshot(
                                        await f
                                            .collection('GROUPS')
                                            .doc(data.name)
                                            .get());
                                    UserModel user = UserModel.fromSnapshot(
                                      await f.collection('USERS').doc(_auth.currentUser!.uid).get()
                                    );
                                    group.memberList
                                        .add(user);
                                    await f
                                        .collection('GROUPS')
                                        .doc(data.name)
                                        .update({
                                      'memberList': group.memberList
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    });
              }

              if (snapshot.connectionState == ConnectionState.done) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text('결과없음'),
                  );
                }
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        )
      ],
    );
  }
}
