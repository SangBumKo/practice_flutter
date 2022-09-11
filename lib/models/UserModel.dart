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