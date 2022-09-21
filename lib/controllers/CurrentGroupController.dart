import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/GroupModel.dart';
import '../models/UserModel.dart';

class CurrentGroupController extends GetxService{
  final f = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final Rx<GroupModel> _group = GroupModel(memberList: []).obs;
  Rx<GroupModel> get group => _group;

  @override
  void onInit() async{
    super.onInit();
    String userId = auth.currentUser!.uid;
    UserModel user = UserModel.fromSnapshot( await f.collection('USERS').doc(userId).get());

    if(user.joinedGroupGk != ''){
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await f.collection('GROUPS').doc(user.joinedGroupGk).get();
      updateCurrentGroup(GroupModel.fromSnapshot(documentSnapshot));
    }
    print('group init');
  }

  void updateCurrentGroup(GroupModel currentGroup){
    _group(currentGroup);
  }
  void updateCurrentGroupMemberList(List<UserModel> memberList){
    _group.value.memberList = memberList;
  }

  void freezeGroups(GroupModel targetGroup){
    targetGroup.isFreezed = true;
    _group.value.isFreezed = true;
    f.collection('GROUPS').doc(_group.value.gk).update({'isFreezed' : _group.value.isFreezed});
    f.collection('GROUPS').doc(targetGroup.gk).update({'isFreezed' : targetGroup.isFreezed});
  }

  void unfreezeGroups(GroupModel targetGroup){
    targetGroup.isFreezed = false;
    _group.value.isFreezed = false;
    f.collection('GROUPS').doc(_group.value.gk).update({'isFreezed' : _group.value.isFreezed});
    f.collection('GROUPS').doc(targetGroup.gk).update({'isFreezed' : targetGroup.isFreezed});
  }

  void sendLike(GroupModel targetGroup){
    _group.value.likesSent.add(targetGroup.gk!);
    targetGroup.likesGot.add(_group.value.gk!);
    f.collection('GROUPS').doc(_group.value.gk).update({'likesSent' : _group.value.likesSent});
    f.collection('GROUPS').doc(targetGroup.gk).update({'likesGot' : targetGroup.likesGot});
  }

  void cancelLike(GroupModel targetGroup){
    _group.value.likesSent.remove(targetGroup.gk!);
    targetGroup.likesGot.remove(_group.value.gk!);

    f.collection('GROUPS').doc(_group.value.gk).update({'likesSent' : _group.value.likesSent});
    f.collection('GROUPS').doc(targetGroup.gk).update({'likesGot' : targetGroup.likesGot});
  }

  void acceptLike(GroupModel targetGroup){
    //createChattingRoom
  }

  void denyLike(GroupModel targetGroup){
    _group.value.likesGot.remove(targetGroup.gk!);
    targetGroup.likesSent.remove(_group.value.gk!);

    f.collection('GROUPS').doc(_group.value.gk).update({'likesGot' : _group.value.likesGot});
    f.collection('GROUPS').doc(targetGroup.gk).update({'likesSent' : targetGroup.likesSent});
  }

  Future<void> clearLikesBeforeBomb() async{
    //if(isLeader) => currentGroupController.clearLikesBeforeBomb -> exitGroup
    //1. 내가 보낸 모든 좋아요 cancel
    _group.value.likesSent.forEach(
        (gk)async{
          DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await f.collection('GROUPS').doc(gk).get();
          GroupModel targetGroup = GroupModel.fromSnapshot(documentSnapshot);
          cancelLike(targetGroup);
        }
    );
    //2. 내가 받은 모든 좋아요 deny
    _group.value.likesGot.forEach(
            (gk)async{
          DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await f.collection('GROUPS').doc(gk).get();
          GroupModel targetGroup = GroupModel.fromSnapshot(documentSnapshot);
          denyLike(targetGroup);
        }
    );
    //3. 그룹 폭파시키기
  }
}
