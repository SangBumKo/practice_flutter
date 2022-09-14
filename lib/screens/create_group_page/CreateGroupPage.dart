import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:practice_flutter/models/GroupModel.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/UserModel.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({Key? key}) : super(key: key);

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final f = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
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
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('방 생성완료!')));
                  createGroup();
                } else {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('다시 시도해주세요')));
                }
                Navigator.pop(context);
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
    user.joinedGroupName = _groupNameTextEditController.text;
    await f.collection('USERS').doc(user.pk).update({'joinedGroupName' : user.joinedGroupName});
    await f.collection('GROUPS').doc(_groupNameTextEditController.text).set(
        GroupModel(
            name: _groupNameTextEditController.text,
            capacity: int.parse(_capacityInputController.text),
            leader: user,
            memberList: [user]).toJson());
  }

  Widget groupNameCheckButton(String str) {
    return ElevatedButton(
      child: const Text('중복확인'),
      onPressed: () {
        isGroupNameOccupied(str);
      },
    );
  }

  Future<bool> isGroupNameOccupied(String str) async {
    var _groupName =
    await f.collection('GROUPS').where('name', isEqualTo: str).get();
    if (_groupName.size > 0) return true;
    return false;
  }
}
