import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'UserModel.dart';

class GroupModel {
  String? name;
  int? capacity;
  String? leader;
  List<dynamic> memberIdList = [];

  GroupModel(
      {this.name, this.capacity, this.leader, required this.memberIdList});

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

  List<GroupModel> getFilteredGroupListForSearchBar(
      QuerySnapshot querySnapshot) {
    List<GroupModel> _groupList = [];
    querySnapshot.docs.where((queryDocumentSnapshot) {
      final Map<String, dynamic> _queryDocumentJsonData =
          queryDocumentSnapshot.data() as Map<String, dynamic>;
      int _capacity = _queryDocumentJsonData['capacity'];
      List<String> _memberIdList = _queryDocumentJsonData['memberIdList'];
      bool _isFull = _capacity == _memberIdList.length;

      String _leader = memberIdList[0];
      String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
      Future<String> _genderOfLeader = UserModel().getGender(_leader);
      Future<String> _genderOfCurrentUser =
          UserModel().getGender(_currentUserId);
      bool _isGenderMatched = _genderOfLeader == _genderOfCurrentUser;
      return _isFull & _isGenderMatched;
    }).forEach((filteredDocument) {
      final Map<String, dynamic> _filteredDocumentJsonData =
          filteredDocument.data() as Map<String, dynamic>;
      _groupList.add(GroupModel.fromJson(_filteredDocumentJsonData));
    });
    return _groupList;
  }

  List<GroupModel> dataListFromSnapshots(
      List<QueryDocumentSnapshot> queryDocumentSnapshots) {
    final List<GroupModel> _groupList = [];
    queryDocumentSnapshots.forEach((queryDocumentSnapshot) {
      final Map<String, dynamic> _documentInJson =
          queryDocumentSnapshot.data() as Map<String, dynamic>;
      _groupList.add(GroupModel.fromJson(_documentInJson));
    });
    return _groupList;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'capacity': capacity,
      'leader': leader,
      'memberIdList': memberIdList,
    };
  }
}
