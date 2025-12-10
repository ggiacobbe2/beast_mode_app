import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadJournalImage({
    required String uid,
    required File file,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = file.path.split('/').last;
    final ref = _storage
        .ref()
        .child('journalPhotos')
        .child(uid)
        .child('$timestamp-$fileName');

    final uploadTask = await ref.putFile(file);
    return uploadTask.ref.getDownloadURL();
  }

  Future<String> uploadFeedImage({
    required String uid,
    required File file,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = file.path.split('/').last;
    final ref = _storage
        .ref()
        .child('feed')
        .child(uid)
        .child('$timestamp-$fileName');

    final uploadTask = await ref.putFile(file);
    return uploadTask.ref.getDownloadURL();
  }

  Future<String> uploadProfileImage({
    required String uid,
    required File file,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = file.path.split('/').last;
    final ref = _storage
        .ref()
        .child('profile')
        .child(uid)
        .child('$timestamp-$fileName');

    final uploadTask = await ref.putFile(file);
    return uploadTask.ref.getDownloadURL();
  }
}
