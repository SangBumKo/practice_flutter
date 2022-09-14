import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/UserModel.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final List<String> _genderList = ['남자', '여자'];
  final List<String> _majorList = ['컴퓨터공학과', 'IT융합공학과', '유아교육과'];
  final List<String> _entranceYearList = [
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
  ];
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final TextEditingController _entranceYearController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입!'),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Form(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(children: <Widget>[
                    const SizedBox(height: 15.0),
                    Row(
                      children: [
                        Expanded(
                          child: createCustomTextFormField(
                            controller: _nicknameController,
                            guideText: '닉네임을 입력하세요',
                          ),
                        ),
                        const SizedBox(width: 5.0),
                        createCustomOutlinedButton(
                            childText: '중복확인', onPressed: () {}),
                      ],
                    ),
                    const SizedBox(height: 15.0),
                    Row(
                      children: [
                        Expanded(
                          child: createCustomTextFormField(
                              controller: _emailController,
                              guideText: '학교이메일을 입력하세요',
                              keyboardType: TextInputType.emailAddress),
                        ),
                        const SizedBox(width: 5.0),
                        createCustomOutlinedButton(
                            childText: '인증하기', onPressed: () {}),
                      ],
                    ),
                    const SizedBox(height: 15.0),
                    createCustomTextFormField(
                        controller: _passwordController,
                        guideText: '비밀번호를 입력하세요',
                        keyboardType: TextInputType.visiblePassword),
                    const SizedBox(height: 15.0),
                    createCustomDropdown(
                        hintText: '학과를 선택해주세요!',
                        items: _majorList,
                        controller: _majorController,
                        isSearchable: true),
                    const SizedBox(height: 15.0),
                    createCustomDropdown(
                        hintText: '성별을 선택해주세요!',
                        items: _genderList,
                        controller: _genderController,
                        isSearchable: false),
                    const SizedBox(height: 15.0),
                    createCustomDropdown(
                        hintText: '학번을 선택해주세요!',
                        items: _entranceYearList,
                        controller: _entranceYearController,
                        isSearchable: false),
                    const SizedBox(height: 15.0),
                    createCustomOutlinedButton(
                        childText: '회원가입', onPressed: createUserAndUserData),
                  ]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  CustomDropdown createCustomDropdown(
      {required String hintText,
      required List<String> items,
      required TextEditingController controller,
      required bool isSearchable}) {
    if (isSearchable) {
      return CustomDropdown.search(
          hintText: hintText, items: items, controller: controller);
    }
    return CustomDropdown(
        hintText: hintText, items: items, controller: controller);
  }

  TextFormField createCustomTextFormField(
      {required TextEditingController controller,
      required String guideText,
      TextInputType? keyboardType}) {
    return TextFormField(
      keyboardType: keyboardType,
      controller: controller,
      validator: (value) {
        if (value!.isEmpty) {
          return guideText;
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: guideText,
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
    );
  }

  OutlinedButton createCustomOutlinedButton(
      {required String childText, VoidCallback? onPressed}) {
    return OutlinedButton(
      child: Text(childText),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
          foregroundColor: Colors.green,
          minimumSize: const Size(70, 40),
          side: const BorderSide(
            color: Colors.green,
            width: 1.0,
          )),
    );
  }

  void createUserAndUserData() async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text, password: _passwordController.text);
    await FirebaseFirestore.instance
        .collection('USERS')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set(UserModel(
          pk: FirebaseAuth.instance.currentUser!.uid,
          name: _nicknameController.text,
          password: _passwordController.text,
          major: _majorController.text,
          entranceYear: int.parse(_entranceYearController.text),
          gender: _genderController.text,
          email: _emailController.text,
        ).toJson());
  }
}
