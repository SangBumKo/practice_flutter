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
  final TextEditingController _genderInputController = TextEditingController();
  final TextEditingController _majorInputController = TextEditingController();
  final TextEditingController _entranceYearInputController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF86D58E),
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
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(children: <Widget>[
                    SizedBox(height: 15.0),
                    //닉네임
                    Container(
                        child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nicknameController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return '닉네임을 입력하세요';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: '닉네임을 입력해주세요..',
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
                        SizedBox(width: 5.0),
                        OutlinedButton(
                          child: Text('중복확인'),
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green,
                              minimumSize: Size(70, 40),
                              side: BorderSide(
                                color: Colors.green,
                                width: 1.0,
                              )),
                        )
                      ],
                    )),
                    //이메일
                    Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              controller: _emailController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return '학교이메일을 입력하세요';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: '학교이메일을 입력해주세요..',
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
                          const SizedBox(width: 5.0),
                          OutlinedButton(
                            child: const Text('인증하기'),
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.green,
                                minimumSize: const Size(70, 40),
                                side: const BorderSide(
                                  color: Colors.green,
                                  width: 1.0,
                                )),
                          )
                        ],
                      ),
                    ),
                    TextFormField(
                      controller: _passwordController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return '비밀번호를 입력하세요';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: '비밀번호를 입력해주세요..',
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
                    const SizedBox(height: 15.0),
                    //학과
                    CustomDropdown.search(
                      hintText: '학과를 선택해주세요!',
                      items: _majorList,
                      controller: _majorInputController,
                    ),
                    const SizedBox(height: 15.0),
                    //성별
                    CustomDropdown(
                      hintText: '성별을 선택해주세요!',
                      items: _genderList,
                      controller: _genderInputController,
                    ),
                    const SizedBox(height: 15.0),
                    //학번
                    CustomDropdown(
                      hintText: '학번을 선택해주세요!',
                      items: _entranceYearList,
                      controller: _entranceYearInputController,
                    ),
                    const SizedBox(height: 15.0),
                    OutlinedButton(
                      child: Text('회원가입'),
                      onPressed: () async {
                        await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                                email: _emailController.text,
                                password: _passwordController.text);
                        await FirebaseFirestore.instance
                            .collection('USERS')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .set(UserModel(
                              pk: FirebaseAuth.instance.currentUser!.uid,
                              name: _nicknameController.text,
                              password: _passwordController.text,
                              major: _majorInputController.text,
                              entranceYear:
                                  int.parse(_entranceYearInputController.text),
                              gender: _genderInputController.text,
                              email: _emailController.text,
                              joinedGroupName: '',
                            ).toJson());
                      },
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          minimumSize: const Size(70, 40),
                          side: const BorderSide(
                            color: Colors.green,
                            width: 1.0,
                          )),
                    ),
                  ]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
