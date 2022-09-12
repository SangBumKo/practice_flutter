import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel{
  //auto
  String? pk;
  String? joinedGroupName;

  //input
  String? name;
  String? password;
  String? major;
  int? entranceYear;
  String? gender;
  String? email;

  UserModel({this.pk, this.password, this.name, this.major, this.entranceYear, this.gender, this.email, this.joinedGroupName});

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
    var _userData = await FirebaseFirestore.instance.collection('USERS').doc(userId).get();
    UserModel _user = UserModel.fromSnapshot(_userData);
    return _user.gender!;
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