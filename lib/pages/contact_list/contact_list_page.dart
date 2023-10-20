import 'package:dio_project_list_contact/models/contact_model.dart';
import 'package:dio_project_list_contact/pages/contact_add/contact_add_page.dart';
import 'package:dio_project_list_contact/pages/contact_list/adapters/contact_card_adapter.dart';
import 'package:dio_project_list_contact/pages/contact_list/contact_list_controller.dart';
import 'package:dio_project_list_contact/repositories/back4app_contacts_repository.dart';
import 'package:dio_project_list_contact/repositories/storage_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  final contactListController = Get.put(ContactListController());
  final ContactStorage contactStorage = ContactStorage();

  ScrollController scrollController = ScrollController();
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    Back4appContactsRepository().getListContact(currentPage);

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        currentPage++;
        Back4appContactsRepository().getListContact(currentPage);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    contactListController.listContacts.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista de Contatos'.toUpperCase(),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Obx(
        () => Visibility(
          visible: contactListController.isLoadingListContacts.value,
          replacement: Visibility(
            visible: contactListController.listContacts.isNotEmpty,
            replacement: const Center(
              child: Text('Sem contatos na lista'),
            ),
            child: ListView.builder(
              itemCount: contactListController.listContacts.length,
              itemBuilder: (context, index) {
                final contact = contactListController.listContacts[index];
                final localPhotoPath = contactStorage.getContactPhotoPath(
                  contact.objectId!,
                );

                return ContactCardAdapter(
                  contact: ContactModel(
                    objectId: contact.objectId,
                    name: contact.name,
                    phone: contact.phone,
                    photoPath: localPhotoPath ?? contact.photoPath,
                  ),
                );
              },
            ),
          ),
          child: const Center(
            child: Visibility(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ContactAddPage(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.add_call,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
