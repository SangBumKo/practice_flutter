import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel{
  String joinedGroupGk = '';
  String? pk;
  String? name;
  String? password;
  String? major;
  int? entranceYear;
  String? gender;
  String? email;

  UserModel({this.pk, this.password, this.name, this.major, this.entranceYear, this.gender, this.email});
  UserModel.fromdynamic(dynamic json)
      : pk = json['pk'],
        name = json['name'],
        password = json['password'],
        major = json['major'],
        entranceYear = json['entranceYear'],
        gender = json['gender'],
        email = json['email'],
        joinedGroupGk = json['joinedGroupGk'];

  UserModel.fromJson(Map<String, dynamic> json) {
    pk = json['pk'];
    name = json['name'];
    password = json['password'];
    major = json['major'];
    entranceYear =  json['entranceYear'];
    gender = json['gender'];
    email = json['email'];
    joinedGroupGk = json['joinedGroupGk'];
  }
  UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data()!);
  
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'pk' : pk,
      'name': name,
      'password' : password,
      'major' : major,
      'entranceYear' : entranceYear,
      'gender' : gender,
      'email' : email,
      'joinedGroupGk' : joinedGroupGk,
    };
  }
}