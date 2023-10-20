// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:dio_project_list_contact/models/contact_model.dart';
import 'package:dio_project_list_contact/pages/contact_edit/contact_edit_page.dart';
import 'package:dio_project_list_contact/pages/contact_list/contact_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContactCardAdapter extends StatelessWidget {
  final ContactModel contact;

  ContactCardAdapter({super.key, required this.contact});

  final contactListController = Get.put(ContactListController());

  @override
  Widget build(BuildContext context) {
    File image = File('');

    if (contact.photoPath != null) {
      image = File(contact.photoPath!);
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: contact.photoPath != null ? FileImage(image) : null,
          child: contact.photoPath == null ? const Icon(Icons.person) : null,
        ),
        title: Text(contact.name!),
        subtitle: Text(contact.phone!),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactEditPage(
                      contact: contact,
                    ),
                  ),
                );
              },
              color: Colors.blue,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Confirmar exclusão?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await contactListController.deleteContact(contact);

                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Excluir',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
