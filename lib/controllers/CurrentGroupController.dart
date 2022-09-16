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
    if(user.joinedGroupName != ''){
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await f.collection('GROUPS').doc(user.joinedGroupName).get();
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
}
