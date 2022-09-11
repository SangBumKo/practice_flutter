class UserModel{
  //auto
  String? pk;
  String? joinedGroupName;

  //input
  String? name;
  String? major;
  String? entranceYear;
  String? gender;
  String? email;

  UserModel({this.pk, this.name, this.major, this.entranceYear, this.gender});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'pk' : pk,
      'name': name,
      'major' : major,
      'entranceYear' : entranceYear,
      'gender' : gender,
    };
  }
}