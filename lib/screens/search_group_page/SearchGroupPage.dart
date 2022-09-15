import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firestore_search/firestore_search.dart';
import 'package:practice_flutter/models/GroupModel.dart';
import 'package:get/get.dart';
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
        FirestoreSearchBar(
          tag: 'example',
        ),
        FirestoreSearchResults.builder(
          tag: 'example',
          firestoreCollectionName: 'GROUPS',
          searchBy: 'name',
          dataListFromSnapshot: GroupModel(memberList: []).dataListFromSnapshot,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
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
                  itemBuilder: (listViewContext, index) {
                    final GroupModel group = groupList[index];
                    final String currentUserId =
                        FirebaseAuth.instance.currentUser!.uid;
                    return FutureBuilder<bool>(
                        future:
                            group.isGenderSameWithCurrentUser(currentUserId),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data! &&
                                group.memberList.length < group.capacity!) {
                              return Container(
                                decoration: BoxDecoration(border: Border.all()),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 7,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              '${group.name}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8.0,
                                                left: 8.0,
                                                right: 8.0),
                                            child: Text('${group.leader!.name}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: OutlinedButton(
                                          //double check!
                                          child: const Text('Join!'),
                                          onPressed: () async {
                                            UserModel user =
                                                UserModel.fromSnapshot(await f
                                                    .collection('USERS')
                                                    .doc(_auth.currentUser!.uid)
                                                    .get());
                                            user.joinedGroupName = group.name!;
                                            await f
                                                .collection('USERS')
                                                .doc(user.pk)
                                                .update({
                                              'joinedGroupName':
                                                  user.joinedGroupName
                                            });
                                            group.memberList.add(user);
                                            await f
                                                .collection('GROUPS')
                                                .doc(group.name)
                                                .update({
                                              'memberList': group.memberList
                                                  .map((e) => e.toJson())
                                                  .toList()
                                            });
                                            Get.back(closeOverlays: true);
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return const SizedBox(height: 0);
                            }
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        });
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
      ],
    );
  }
}
