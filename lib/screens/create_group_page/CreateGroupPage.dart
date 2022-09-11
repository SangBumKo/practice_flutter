import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:practice_flutter/models/GroupModel.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({Key? key}) : super(key: key);

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final f = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _capacityList = [1, 2, 3, 4];
  int _selectedValue = 1;
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
          DropdownButton<int>(
              value: _selectedValue,
              items: _capacityList
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.toString()),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedValue = value!;
                });
              }),
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
    await f.collection('GROUPS').doc(_groupNameTextEditController.text).set(
        GroupModel(
            name: _groupNameTextEditController.text,
            capacity: _selectedValue,
            leader: '1000',
            memberIdList: ['1000']).toJson());
  }

  Widget groupNameCheckButton(String str) {
    return ElevatedButton(
      child: const Text('중복확인'),
      onPressed: () {
        isGroupNameOccupied(str);
      },
    );
  }

  //이걸 그냥 중복확인 버튼에 심자
  Future<bool> isGroupNameOccupied(String str) async {
    var _groupName =
        await f.collection('GROUPS').where('name', isEqualTo: str).get();
    if (_groupName.size > 0) return true;
    return false;
  }
}
