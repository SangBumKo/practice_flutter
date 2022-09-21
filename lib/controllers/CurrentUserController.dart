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
  void updateJoinedGroupGk(String groupGk){
    _user.value.joinedGroupGk = groupGk;
  }
}
