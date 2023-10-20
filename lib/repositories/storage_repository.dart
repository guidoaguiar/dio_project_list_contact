import 'package:get_storage/get_storage.dart';

class ContactStorage {
  final storage = GetStorage();

  Future<void> saveContactPhotoPath(
    String contactId,
    String localPhotoPath,
  ) async {
    await storage.write('contact_$contactId', localPhotoPath);
  }

  String? getContactPhotoPath(String contactId) {
    return storage.read('contact_$contactId');
  }
}
