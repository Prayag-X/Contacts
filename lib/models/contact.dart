import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  DocumentSnapshot? docRef;
  String? firstName;
  String? lastName;
  String? address;
  String? phone;
  String? email;
  String? profilePicLink;
  String? profilePicColor;

  Contact(this.docRef) {
    firstName = docRef?.get('first_name');
    lastName = docRef?.get('last_name');
    address = docRef?.get('address');
    phone = docRef?.get('phone');
    email = docRef?.get('email');
    profilePicLink = docRef?.get('profile_pic_link');
    profilePicColor = docRef?.get('profile_pic_color');
  }
}