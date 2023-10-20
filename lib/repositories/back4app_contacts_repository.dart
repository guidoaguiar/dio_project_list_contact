import 'package:dio/dio.dart';
import 'package:dio_project_list_contact/models/contact_model.dart';
import 'package:dio_project_list_contact/pages/contact_list/contact_list_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

class Back4appContactsRepository {
  var contactListController = Get.put(ContactListController());
  var dio = Dio();

  Back4appContactsRepository() {
    dio.options.headers['X-Parse-Application-Id'] = dotenv.get('APP_ID');
    dio.options.headers['X-Parse-REST-API-Key'] = dotenv.get('REST_API_KEY');
    dio.options.headers['content-type'] = 'application/json';
    dio.options.baseUrl = 'https://parseapi.back4app.com/classes';
  }

  Future<void> getListContact(int page) async {
    try {
      contactListController.isLoadingListContacts.value = true;
      int skip = (page - 1) * 10;

      var response = await dio.get(
        '/contacts',
        queryParameters: {
          'limit': 10,
          'skip': skip,
        },
      );

      if (response.data != null) {
        contactListController.listContacts.clear();

        contactListController.listContacts.addAll(
          Back4AppContactsModel.fromJson(response.data).results!,
        );
      }
    } catch (e) {
      contactListController.listContacts.clear();
      printError(info: e.toString());
    } finally {
      contactListController.isLoadingListContacts.value = false;
    }
  }

  Future<String?> saveContact(ContactModel contact) async {
    try {
      var response = await dio.post(
        '/contacts',
        data: contact,
      );

      if (response.statusCode == 201) {
        return response.data['objectId'];
      }
    } catch (e) {
      printError(info: e.toString());
      return null;
    }
    return null;
  }

  Future<bool> updateContact(ContactModel contact) async {
    try {
      var response = await dio.put(
        '/contacts/${contact.objectId}',
        data: contact,
      );

      if (response.statusCode == 200) return true;

      return false;
    } catch (e) {
      printError(info: e.toString());

      return false;
    }
  }

  Future<void> delete(ContactModel contact) async {
    try {
      await dio.delete('/contacts/${contact.objectId}');
    } catch (e) {
      printError(info: e.toString());
    }
  }
}
