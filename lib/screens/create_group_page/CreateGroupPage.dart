import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:practice_flutter/models/GroupModel.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../controllers/CurrentUserController.dart';
import '../../models/UserModel.dart';
import '../../controllers/CurrentGroupController.dart';
import 'package:uuid/uuid.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({Key? key}) : super(key: key);

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final f = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final uuid = Uuid();
  CurrentUserController currentUserController = Get.put(CurrentUserController(), permanent: true);
  CurrentGroupController currentGroupController = Get.put(CurrentGroupController(), permanent: true);

  final _formKey = GlobalKey<FormState>();
  final List<String>_capacityList = ['1', '2', '3', '4'];
  final TextEditingController _capacityInputController = TextEditingController();
  final _groupNameTextEditController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: TextFormField(
              controller: _groupNameTextEditController,
              validator: (value) {
                if (value!.isEmpty) {
                  return '방 이름을 입력하세요';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: '방 이름을 입력해주세요..',
                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),
                enabledBorder: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    )),
                focusedBorder: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    )),
                filled: true,
              ),
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          CustomDropdown(
            hintText: '최대 인원을 선택해주세요!',
            items: _capacityList,
            controller: _capacityInputController,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              child: const Text('생성'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Get.snackbar('그룹 생성완료!', '이제 다른 그룹을 찾아보세요!', snackPosition: SnackPosition.BOTTOM);
                  createGroup();
                } else {
                  Get.snackbar('그룹을 만들지 못했어요ㅠㅠ', '방이름을 다시 입력해주세요!');
                }
                Get.back(closeOverlays: true);
              },
              // 버튼에 텍스트 부여
            ),
          ),
        ],
      ),
    );
  }

  Future createGroup() async {
    final userDocument = await f.collection('USERS').doc(_auth.currentUser!.uid).get();
    final user = UserModel.fromSnapshot(userDocument);

    GroupModel newGroup =  GroupModel(
        gk: uuid.v1(),
        name: _groupNameTextEditController.text,
        capacity: int.parse(_capacityInputController.text),
        leader: user,
        memberList: [user]);

    user.joinedGroupGk = newGroup.gk!;
    await f.collection('USERS').doc(user.pk).update({'joinedGroupGk' : user.joinedGroupGk});
    await f.collection('GROUPS').doc(newGroup.gk!).set(newGroup.toJson());

    //firebase update error
    currentGroupController.updateCurrentGroup(newGroup);
    currentUserController.updateJoinedGroupGk(newGroup.gk!);
  }
}
