import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ChattingModel.dart';
import 'CurrentUserController.dart';

class CurrentChattingPageController extends GetxService {
  CurrentUserController currentUserController =
      Get.put(CurrentUserController(), permanent: true);
  late CollectionReference collectionRef;
  final chattingList = Rx<List<ChattingModel>>([]);

  @override
  void onInit() {
    super.onInit();
  }

  void updateCollectionRef(String subCollectionPath){
    collectionRef = FirebaseFirestore.instance
        .collection('CHATTING_ROOMS').doc('MATCHED').
    collection(subCollectionPath);
  }

  Stream<QuerySnapshot> getSnapshot() {
    return collectionRef
        .limit(1)
        .orderBy('uploadTime', descending: true)
        .snapshots();
  }

  Future<void> load() async {
    var now = DateTime.now().millisecondsSinceEpoch;
    var result = await collectionRef
        .where('uploadTime', isGreaterThan: now)
        .orderBy('uploadTime', descending: true)
        .get();
    var l = result.docs
        .map((e) => ChattingModel.fromJson(e.data() as Map<String, dynamic>))
        .toList();
    chattingList.value.addAll(l);
  }
  Future<void> send(String text) async {
    int now = DateTime.now().millisecondsSinceEpoch;
    await collectionRef.doc(now.toString()).set(ChattingModel(
            currentUserController.user.value.pk!,
            currentUserController.user.value.name!,
            text,
            now)
        .toJson());
  }

  void addOne(ChattingModel model) {
    chattingList.value.insert(0, model);
  }
}
