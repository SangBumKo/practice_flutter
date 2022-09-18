import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CurrentUserController extends GetxService{
  final f = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final Rx<UserModel> _user = UserModel().obs;
  Rx<UserModel> get user => _user;

  @override
  void onInit() async{
    super.onInit();
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await f.collection('USERS').doc(auth.currentUser!.uid).get();
    updateCurrentUser(UserModel.fromSnapshot(documentSnapshot));
    print('user init');
  }

  void updateCurrentUser(UserModel currentUser){
    _user(currentUser);
  }
  void updateJoinedGroupName(String groupName){
    _user.value.joinedGroupName = groupName;
  }

  Future<bool> sendLike(bool isLiked) async{
    /// send your request here
    /// 여기에 라이크 보내는 함수를 작성해야겠구만
    final bool success= 1==1;
    //await sendRequest();

    /// if failed, you can do nothing
    return success? !isLiked:isLiked;
  }
}
