import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:practice_flutter/utils/Functions.dart';
import 'package:uuid/uuid.dart';
import '../models/GroupModel.dart';
import '../models/UserModel.dart';
import '../screens/chatting_page/ChattingPage.dart';
import 'CurrentChattingPageController.dart';
import 'CurrentUserController.dart';

class CurrentGroupController extends GetxService {
  final f = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final uuid = Uuid();
  CurrentUserController currentUserController =
      Get.put(CurrentUserController(), permanent: true);
  CurrentChattingPageController currentChattingPageController =
  Get.put(CurrentChattingPageController(), permanent: true);

  final Rx<GroupModel> _group = GroupModel(memberList: []).obs;

  Rx<GroupModel> get group => _group;

  @override
  void onInit() async {
    super.onInit();
  }

  void updateCurrentGroup(GroupModel currentGroup) {
    _group(currentGroup);
  }

  void updateCurrentGroupMemberList(List<UserModel> memberList) {
    _group.value.memberList = memberList;
  }

  void freezeGroups(GroupModel targetGroup) {
    targetGroup.isFreezed = true;
    _group.value.isFreezed = true;
    f
        .collection('GROUPS')
        .doc(_group.value.gk)
        .update({'isFreezed': _group.value.isFreezed});
    f
        .collection('GROUPS')
        .doc(targetGroup.gk)
        .update({'isFreezed': targetGroup.isFreezed});
  }

  void unfreezeGroups(GroupModel targetGroup) {
    targetGroup.isFreezed = false;
    _group.value.isFreezed = false;
    f
        .collection('GROUPS')
        .doc(_group.value.gk)
        .update({'isFreezed': _group.value.isFreezed});
    f
        .collection('GROUPS')
        .doc(targetGroup.gk)
        .update({'isFreezed': targetGroup.isFreezed});
  }

  void sendLike(GroupModel targetGroup) {
    _group.value.likesSent.add(targetGroup.gk!);
    targetGroup.likesGot.add(_group.value.gk!);
    f
        .collection('GROUPS')
        .doc(_group.value.gk)
        .update({'likesSent': _group.value.likesSent});
    f
        .collection('GROUPS')
        .doc(targetGroup.gk)
        .update({'likesGot': targetGroup.likesGot});
  }

  void cancelLike(GroupModel targetGroup) {
    _group.value.likesSent.remove(targetGroup.gk!);
    targetGroup.likesGot.remove(_group.value.gk!);

    f
        .collection('GROUPS')
        .doc(_group.value.gk)
        .update({'likesSent': _group.value.likesSent});
    f
        .collection('GROUPS')
        .doc(targetGroup.gk)
        .update({'likesGot': targetGroup.likesGot});
  }

  Future<void> acceptLike(GroupModel targetGroup) async {
    try {
      _group.value.likesGot.remove(targetGroup.gk);
      targetGroup.likesSent.remove(_group.value.gk);
      await f
          .collection('GROUPS')
          .doc(_group.value.gk)
          .update({'likesGot': _group.value.likesGot});
      await f
          .collection('GROUPS')
          .doc(targetGroup.gk)
          .update({'likesSent': targetGroup.likesSent});
      //db에 업로드하기
      String chattingRoomKey = uuid.v1();
      currentUserController.user.value.chattingRoomKey = chattingRoomKey;
      _group.value.memberList.forEach((member) async {
        member.chattingRoomKey = chattingRoomKey;
        if (member.pk == _group.value.leader!.pk) _group.value.leader = member;
        await f
            .collection('USERS')
            .doc(member.pk)
            .update({'chattingRoomKey': chattingRoomKey});
      });
      targetGroup.memberList.forEach((member) async {
        member.chattingRoomKey = chattingRoomKey;
        if (member.pk == targetGroup.leader!.pk) targetGroup.leader = member;
        await f
            .collection('USERS')
            .doc(member.pk)
            .update({'chattingRoomKey': chattingRoomKey});
      });

      await f.collection('GROUPS').doc(_group.value.gk).update({
        'memberList':
            _group.value.memberList.map((member) => member.toJson()).toList()
      });
      await f
          .collection('GROUPS')
          .doc(_group.value.gk)
          .update({'leader': _group.value.leader!.toJson()});
      await f.collection('GROUPS').doc(targetGroup.gk).update({
        'memberList':
            targetGroup.memberList.map((member) => member.toJson()).toList()
      });
      await f
          .collection('GROUPS')
          .doc(targetGroup.gk)
          .update({'leader': targetGroup.leader!.toJson()});

      freezeGroups(targetGroup);
      Get.back();
      Get.to(() => ChattingPage());
      currentChattingPageController.updateCollectionRef(chattingRoomKey);
    } catch (e) {
      Get.snackbar('Error!', '${e.toString()}오류가 발생했어요');
    }
  }

  void denyLike(GroupModel targetGroup) {
    _group.value.likesGot.remove(targetGroup.gk!);
    targetGroup.likesSent.remove(_group.value.gk!);

    f
        .collection('GROUPS')
        .doc(_group.value.gk)
        .update({'likesGot': _group.value.likesGot});
    f
        .collection('GROUPS')
        .doc(targetGroup.gk)
        .update({'likesSent': targetGroup.likesSent});
  }

  Future<void> clearLikesBeforeBomb() async {
    //if(isLeader) => currentGroupController.clearLikesBeforeBomb -> exitGroup
    //1. 내가 보낸 모든 좋아요 cancel
    _group.value.likesSent.forEach((gk) async {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await f.collection('GROUPS').doc(gk).get();
      GroupModel targetGroup = GroupModel.fromSnapshot(documentSnapshot);
      cancelLike(targetGroup);
    });
    //2. 내가 받은 모든 좋아요 deny
    _group.value.likesGot.forEach((gk) async {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await f.collection('GROUPS').doc(gk).get();
      GroupModel targetGroup = GroupModel.fromSnapshot(documentSnapshot);
      denyLike(targetGroup);
    });
    //3. 그룹 폭파시키기
  }
}
