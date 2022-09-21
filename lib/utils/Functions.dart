import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../controllers/CurrentGroupController.dart';
import '../controllers/CurrentUserController.dart';
import '../models/GroupModel.dart';
import '../models/UserModel.dart';


CurrentUserController currentUserController =
Get.put(CurrentUserController(), permanent: true);
CurrentGroupController currentGroupController =
Get.put(CurrentGroupController(), permanent: true);

final f = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

Future<void> joinGroup(GroupModel group) async {
  UserModel user = UserModel.fromSnapshot(
      await f.collection('USERS').doc(_auth.currentUser!.uid).get());

  user.joinedGroupGk = group.gk!;

  await f
      .collection('USERS')
      .doc(user.pk)
      .update({'joinedGroupGk': user.joinedGroupGk});

  group.memberList.add(user);

  await f.collection('GROUPS').doc(group.gk).update(
      {'memberList': group.memberList.map((e) => e.toJson()).toList()});

  currentGroupController.updateCurrentGroup(group);
  currentUserController.updateJoinedGroupGk(user.joinedGroupGk);
  Get.back(closeOverlays: true);
}