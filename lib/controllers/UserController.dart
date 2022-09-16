import 'package:get/get.dart';
import '../models/UserModel.dart';

class CurrentUserController extends GetxService{
  final Rx<UserModel> _user = UserModel().obs;
  Rx<UserModel> get user => _user;
  void updateCurrentUser(UserModel currentUser){
    _user(currentUser);
  }
}
