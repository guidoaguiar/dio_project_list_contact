import 'package:dio_project_list_contact/models/contact_model.dart';
import 'package:dio_project_list_contact/repositories/back4app_contacts_repository.dart';
import 'package:dio_project_list_contact/repositories/storage_repository.dart';
import 'package:get/get.dart';

class ContactListController extends GetxController {
  var listContacts = <ContactModel>[].obs;
  var isLoadingListContacts = false.obs;
  var isLoadingSave = false.obs;
  var isFormUpdateContactEdited = false.obs;

  Future<bool> saveContact(ContactModel contact) async {
    try {
      isLoadingSave.value = true;
      var objectId = await Back4appContactsRepository().saveContact(contact);

      if (objectId != null) {
        if (contact.photoPath != null) {
          await ContactStorage().saveContactPhotoPath(
            objectId,
            contact.photoPath!,
          );
        }

        return true;
      }

      return false;
    } catch (e) {
      printError(info: e.toString());
      return false;
    } finally {
      isLoadingSave.value = false;
    }
  }

  Future<bool> updateContact(ContactModel contact) async {
    try {
      isLoadingSave.value = true;
      bool success = await Back4appContactsRepository().updateContact(contact);

      if (success) {
        if (contact.photoPath != null) {
          await ContactStorage().saveContactPhotoPath(
            contact.objectId!,
            contact.photoPath!,
          );
        }

        listContacts.removeWhere(
          (contactOld) => contactOld.objectId == contact.objectId!,
        );

        listContacts.add(contact);

        listContacts.refresh();

        return true;
      }

      return false;
    } catch (e) {
      printError(info: e.toString());
      return false;
    } finally {
      isLoadingSave.value = false;
    }
  }

  Future<void> deleteContact(ContactModel contact) async {
    try {
      await Back4appContactsRepository().delete(contact);

      listContacts.removeWhere(
        (contactOld) => contactOld.objectId == contact.objectId,
      );
      listContacts.refresh();
    } catch (e) {
      printError(info: e.toString());
    }
  }
}
