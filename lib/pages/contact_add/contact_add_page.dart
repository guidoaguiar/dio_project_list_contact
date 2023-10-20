// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:dio_project_list_contact/models/contact_model.dart';
import 'package:dio_project_list_contact/pages/contact_list/contact_list_controller.dart';
import 'package:dio_project_list_contact/repositories/back4app_contacts_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ContactAddPage extends StatefulWidget {
  const ContactAddPage({super.key});

  @override
  ContactAddPageState createState() => ContactAddPageState();
}

class ContactAddPageState extends State<ContactAddPage> {
  File? _selectedImage;
  final _formKey = GlobalKey<FormState>();
  final _imageCropper = ImageCropper();
  final controllerName = TextEditingController();
  final controllerPhone = TextEditingController();
  final contactListController = ContactListController();

  Future<void> _showImageSourceModal() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tirar Foto'),
              onTap: () async {
                Navigator.of(context).pop();
                final pickedFile = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                );
                _handleImageSelection(pickedFile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Escolher da Galeria'),
              onTap: () async {
                Navigator.of(context).pop();
                final pickedFile = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                _handleImageSelection(pickedFile);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleImageSelection(XFile? pickedFile) async {
    if (pickedFile != null) {
      final croppedImage = await _imageCropper.cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 100,
        maxHeight: 512,
        maxWidth: 512,
      );

      if (croppedImage != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final localPath = appDir.path;
        final fileName =
            'contact_image_${DateTime.now().millisecondsSinceEpoch}.png';
        final localFile = File('$localPath/$fileName');

        final croppedFile = File(croppedImage.path);
        await croppedFile.copy(localFile.path);

        setState(() {
          _selectedImage = localFile;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inserir Contato'.toUpperCase(),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Obx(
        () => Center(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: _showImageSourceModal,
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : null,
                        child: _selectedImage == null
                            ? const Icon(Icons.camera_alt, size: 60)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: controllerName,
                      decoration: InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira um nome válido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Telefone',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      keyboardType: TextInputType.phone,
                      controller: controllerPhone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira um telefone válido.';
                        }
                        return null;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        TelefoneInputFormatter(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Visibility(
                      visible: contactListController.isLoadingSave.value,
                      replacement: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            var contact = ContactModel(
                              name: controllerName.text,
                              phone: controllerPhone.text,
                              photoPath: _selectedImage?.path,
                            );

                            bool success = await contactListController
                                .saveContact(contact);

                            if (success) {
                              Get.snackbar(
                                'Sucesso',
                                'Contato salvo com sucesso',
                                backgroundColor: Colors.green,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              Back4appContactsRepository().getListContact(1);

                              Navigator.pop(context);
                            } else {
                              Get.snackbar(
                                'Erro',
                                'Erro ao salvar contato',
                                backgroundColor: Colors.red,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Salvar Contato',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      child: const CircularProgressIndicator(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
