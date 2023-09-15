import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts/models/contact.dart';
import 'package:contacts/providers/data_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/constants.dart';
import '../constants/images.dart';

class Database {
  final collectionUsers = FirebaseFirestore.instance.collection('Users');

  registerUser(
    WidgetRef ref,
    String firstName,
    String lastName,
    String address,
    String phone,
    String profilePicColor,
    bool profilePicLinkPresent,
  ) async {
    await collectionUsers.doc(ref.read(uidProvider).trim()).set({
      'first_name': firstName,
      'last_name': lastName,
      'address': address,
      'phone': phone,
      'profile_pic_color': profilePicColor,
      'profile_pic_link': profilePicLinkPresent
          ? Const.imageLocation(ref.read(uidProvider), Images.profileDefaultUrlName)
          : '',
      'email': ref.read(emailProvider),
    });
  }

  addContact(
    WidgetRef ref,
    String docID,
    String firstName,
    String lastName,
    String address,
    String phone,
    String email,
    bool profilePicLinkPresent,
    String profilePicColor,
  ) async {
    await collectionUsers
        .doc(ref.read(uidProvider).trim())
        .collection('Contacts')
        .doc(docID)
        .set({
      'first_name': firstName,
      'last_name': lastName,
      'address': address,
      'phone': phone,
      'email': email,
      'profile_pic_link': profilePicLinkPresent
          ? Const.imageLocation(ref.read(uidProvider), docID)
          : '',
      'profile_pic_color': profilePicColor,
    });
  }

  modifyContact(
    WidgetRef ref,
    DocumentSnapshot documentSnapshot,
    String firstName,
    String lastName,
    String address,
    String phone,
    String email,
    String profilePicLink,
  ) async {
    await collectionUsers
        .doc(ref.read(uidProvider).trim())
        .collection('Contacts')
        .doc(documentSnapshot.reference.id)
        .update({
      'first_name': firstName,
      'last_name': lastName,
      'address': address,
      'phone': phone,
      'email': email,
      'profile_pic_link': profilePicLink,
    });
  }

  modifyUser(
      WidgetRef ref,
      String firstName,
      String lastName,
      String address,
      String phone,
      String email,
      String profilePicLink,
      ) async {
    await collectionUsers
        .doc(ref.read(uidProvider).trim())
        .update({
      'first_name': firstName,
      'last_name': lastName,
      'address': address,
      'phone': phone,
      'email': email,
      'profile_pic_link': profilePicLink,
    });
  }

  deleteContact(DocumentSnapshot doc) async {
    await doc.reference.delete();
  }

  List<Contact> _contactSnap(QuerySnapshot snapshot) =>
      snapshot.docs.map((doc) => Contact(doc)).toList();

  Stream<List<Contact>> streamContacts(WidgetRef ref) => collectionUsers
      .doc(ref.read(uidProvider).trim())
      .collection('Contacts')
      .orderBy('first_name')
      .snapshots(includeMetadataChanges: true)
      .map(_contactSnap);

  Contact _userSnap(DocumentSnapshot snapshot) => Contact(
        snapshot,
      );

  Stream<Contact> streamUser(WidgetRef ref) => collectionUsers
      .doc(ref.read(uidProvider).trim())
      .snapshots(includeMetadataChanges: true)
      .map(_userSnap);
}
