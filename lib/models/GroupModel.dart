import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  String? name;
  int? capacity;
  String? leader;
  List<dynamic> memberIdList = [];

  GroupModel({this.name, this.capacity, this.leader, required this.memberIdList});

  GroupModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    capacity = json['capacity'];
    leader = json['leader'];
    memberIdList = json['memberIdList'];
  }

  GroupModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data()!);

  GroupModel.fromQuerySnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data());

  List<GroupModel> dataListFromSnapshot(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((snapshot) {
      final Map<String, dynamic> json = snapshot.data() as Map<String, dynamic>;
      return GroupModel.fromJson(json);
    }).toList();
  }

  List<GroupModel> dataListFromSnapshots(List<QueryDocumentSnapshot> queryDocumentSnapshots){
    final List<GroupModel>_groupList = [];
    queryDocumentSnapshots.forEach((queryDocumentSnapshot) {
      final Map<String, dynamic> _documentInJson = queryDocumentSnapshot.data() as Map<String, dynamic>;
      _groupList.add(GroupModel.fromJson(_documentInJson));
  });
  return _groupList;
  }


  //filter 만들기
  // List<GroupModel> groupListFromSnapshotForSearchGroupPage(QuerySnapshot querySnapshot){
  //   List<GroupModel> _groupList = [];
  //   querySnapshot.docs.where((queryDocumentSnapshot){
  //     final Map<String, dynamic> queryDocumentJsonData = queryDocumentSnapshot.data() as Map<String, dynamic>;
  //     int _capacity = queryDocumentJsonData['capacity'];
  //     List<String> memberIdList = queryDocumentJsonData['memberIdList'];
  //     String _leader = memberIdList[0];
  //
  //     bool isFull = _capacity == memberIdList.length;
  //     return isFull;
  //   }).forEach((element) { })
  // }


  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'capacity': capacity,
      'leader': leader,
      'memberIdList': memberIdList,
    };
  }
}
