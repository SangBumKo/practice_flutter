import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel{
  String joinedGroupName = '';
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
        entranceYear = int.parse(json['entranceYear']),
        gender = json['gender'],
        email = json['email'];

  UserModel.fromJson(Map<String, dynamic> json) {
    pk = json['pk'];
    name = json['name'];
    password = json['password'];
    major = json['major'];
    entranceYear =  json['entranceYear'];
    gender = json['gender'];
    email = json['email'];
    joinedGroupName = json['joinedGroupName'];
  }

  UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data()!);

  Future<String> getGender(String userId) async{
    var userData = await FirebaseFirestore.instance.collection('USERS').doc(userId).get();
    return userData.get('gender');
  }

  bool doesGenderMatches(String leaderId, String userId){
    return UserModel().getGender(leaderId) == UserModel().getGender(userId);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'pk' : pk,
      'name': name,
      'password' : password,
      'major' : major,
      'entranceYear' : entranceYear,
      'gender' : gender,
      'email' : email,
      'joinedGroupName' : joinedGroupName,
    };
  }
}