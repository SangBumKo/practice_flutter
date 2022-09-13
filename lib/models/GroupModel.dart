import 'package:cloud_firestore/cloud_firestore.dart';
import 'UserModel.dart';

class GroupModel {
  String? name;
  int? capacity;
  UserModel? leader;
  List<UserModel> memberList = [];

  GroupModel(
      {this.name, this.capacity, this.leader, required this.memberList});


  GroupModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    capacity = json['capacity'];
    leader = UserModel.fromdynamic(json['leader']);
    memberList = (json['memberList'] as List).map((e) => UserModel.fromdynamic(e)).toList();
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

  List<GroupModel> dataListFromSnapshots(
      List<QueryDocumentSnapshot> queryDocumentSnapshots) {
    final List<GroupModel> groupList = [];
    queryDocumentSnapshots.forEach((queryDocumentSnapshot) {
      final Map<String, dynamic> documentInJson =
          queryDocumentSnapshot.data() as Map<String, dynamic>;
      groupList.add(GroupModel.fromJson(documentInJson));
    });
    return groupList;
  }

  bool isGroupFull(QueryDocumentSnapshot queryDocumentSnapshot){
    int capacity = queryDocumentSnapshot.get('capacity');
    List<dynamic> memberIdList = queryDocumentSnapshot.get('memberIdList');
    return capacity == memberIdList.length;
  }

  // List<GroupModel> getFilteredGroupListForSearchBar(
  //     QuerySnapshot querySnapshot) {
  //   return querySnapshot.docs.where((queryDocumentSnapshot) {
  //     String leaderId = queryDocumentSnapshot.get('leader');
  //     String userId = FirebaseAuth.instance.currentUser!.uid;
  //
  //     return (!isGroupFull(queryDocumentSnapshot) & UserModel().doesGenderMatches(leaderId, userId));
  //   }).map((element){
  //     final Map<String, dynamic> filteredJsonData = element.data() as Map<String, dynamic>;
  //     return GroupModel.fromJson(filteredJsonData);
  //   }).toList();
  // }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'capacity': capacity,
      'leader': leader!.toJson(),
      'memberList': memberList.map((e) => e.toJson()),
    };
  }
}
