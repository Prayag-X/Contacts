import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../../constants/text_styles.dart';
import '../../firebase/database.dart';
import '../../providers/data_provider.dart';
import '../../utils/extensions.dart';
import '../../constants/constants.dart';
import '../../constants/themes.dart';
import '../../models/contact.dart';
import '../../providers/settings_provider.dart';
import 'widgets/contact_card.dart';

class ContactsPage extends ConsumerStatefulWidget {
  const ContactsPage({super.key});

  @override
  ConsumerState createState() => _ContactsPageState();
}

class _ContactsPageState extends ConsumerState<ContactsPage> {
  Database database = Database();
  String prevChar = '';
  int prevListLength = 0;

  @override
  Widget build(BuildContext context) {
    Themes themes = ref.watch(themesProvider);
    return StreamBuilder(
        stream: database.streamContacts(ref),
        builder: (context, contacts) {
          if (contacts.connectionState == ConnectionState.waiting) {
            return Center(
                child: SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(
                      color: themes.oppositeColor,
                    )));
          } else {
            List<Contact>? contactsData = contacts.data;
            Future.delayed(Duration.zero).then((x) async {
              ref.read(contactsCountProvider.notifier).state =
                  contactsData != null ? contactsData.length : 0;
            });
            if (contactsData == null || contactsData.isEmpty) {
              return Center(
                child: Text(
                  translate('homepage.no_contacts'),
                  style: textStyleNormal.copyWith(
                      fontSize: 15, color: themes.oppositeColor),
                ),
              );
            }
            prevChar = '';
            List<bool> showLetter = [];
            for (Contact contact in contactsData) {
              if (prevChar != contact.firstName![0].toUpperCase()) {
                prevChar = contact.firstName![0].toUpperCase();
                showLetter.add(true);
              } else {
                showLetter.add(false);
              }
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: AnimationLimiter(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  itemCount: contactsData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: Const.animationDuration,
                      child: SlideAnimation(
                        horizontalOffset: -50.0,
                        child: FadeInAnimation(
                          child: ContactDecider(
                            showLetter: showLetter[index],
                            contact: contactsData[index],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }
        });
  }
}

class ContactDecider extends ConsumerWidget {
  const ContactDecider({
    super.key,
    required this.showLetter,
    required this.contact,
  });
  final bool showLetter;
  final Contact contact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String search = ref.watch(searchProvider);
    String name = '${contact.firstName!} ${contact.lastName ?? ''}';
    if (search.toLowerCase() ==
        name.substring(0, min(search.length, name.length)).toLowerCase()) {
      return ContactCard(
          contact: contact,
          showLetter: search.isEmpty ? showLetter : false,
          matched: search.length);
    }
    if (search.toLowerCase() ==
        contact.phone!
            .substring(0, min(search.length, contact.phone!.length))
            .toLowerCase()) {
      return ContactCard(
        contact: contact,
        showLetter: search.isEmpty ? showLetter : false,
        matched: search.length,
        matchedPhone: true,
      );
    }
    return 0.ph;
  }
}
