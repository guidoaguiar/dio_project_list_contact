class Back4AppContactsModel {
  List<ContactModel>? results;

  Back4AppContactsModel({this.results});

  Back4AppContactsModel.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <ContactModel>[];
      json['results'].forEach((contact) {
        results!.add(ContactModel.fromJson(contact));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (results != null) {
      data['results'] = results!.map((contact) => contact.toJson()).toList();
    }
    return data;
  }
}

class ContactModel {
  String? objectId;
  String? createdAt;
  String? updatedAt;
  String? name;
  String? phone;
  String? photoPath;

  ContactModel(
      {this.objectId,
      this.createdAt,
      this.updatedAt,
      this.name,
      this.phone,
      this.photoPath});

  ContactModel.fromJson(Map<String, dynamic> json) {
    objectId = json['objectId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    name = json['name'] ?? '';
    phone = json['phone'] ?? '';
    photoPath = json['photo_path'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['objectId'] = objectId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['name'] = name;
    data['phone'] = phone;
    data['photo_path'] = photoPath;

    return data;
  }

  ContactModel.copyWithChanges({
    required ContactModel originalContact,
    String? name,
    String? phone,
    String? photoPath,
  }) {
    objectId = originalContact.objectId;
    createdAt = originalContact.createdAt;
    updatedAt = originalContact.updatedAt;
    this.name = name ?? originalContact.name;
    this.phone = phone ?? originalContact.phone;
    this.photoPath = photoPath ?? originalContact.photoPath;
  }
}
