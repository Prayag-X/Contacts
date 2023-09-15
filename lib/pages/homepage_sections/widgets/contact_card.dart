import 'dart:async';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/text_styles.dart';
import '../../../firebase/database.dart';
import '../../../pages/homepage_sections/widgets/modify_contact.dart';
import '../../../utils/extensions.dart';
import '../../../utils/helper.dart';
import '../../../constants/constants.dart';
import '../../../constants/themes.dart';
import '../../../models/contact.dart';
import '../../../providers/settings_provider.dart';
import '../../../utils/get_size.dart';

class ContactCard extends ConsumerStatefulWidget {
  const ContactCard(
      {super.key,
      required this.contact,
      this.showLetter = true,
      this.matchedPhone = false,
      this.matched = 0});
  final Contact contact;
  final bool showLetter;
  final bool matchedPhone;
  final int matched;

  @override
  ConsumerState createState() => _ContactCardState();
}

class _ContactCardState extends ConsumerState<ContactCard> {
  final ExpandableController controller =
      ExpandableController(initialExpanded: false);
  double expandedSize = 0;
  bool expanded = false;
  Database database = Database();
  bool removed = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() => expanded = !expanded);
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Themes themes = ref.watch(themesProvider);
    // bool collapse = ref.watch(collapseProvider);
    double letterWidth = 40;
    double width = screenSize(context).width - letterWidth - 15 * 2;
    double verticalPadding = 10;
    double horizontalPadding = 12;
    double size = 35;
    String name = '${widget.contact.firstName} ${widget.contact.lastName}';
    // if (collapse && expanded) {
    //   Future.delayed(Duration.zero).then((x) async {
    //     controller.toggle();
    //     ref.read(collapseProvider.notifier).state = false;
    //   });
    // }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: letterWidth,
          height: size + verticalPadding * 2,
          child: widget.showLetter
              ? Center(
                  child: Text(
                    widget.contact.firstName![0].toUpperCase(),
                    style: textStyleBold.copyWith(
                        fontSize: 15, color: themes.oppositeColor),
                  ),
                )
              : null,
        ),
        SizedBox(
          width: width,
          child: Stack(
            children: [
              AnimatedSwitcher(
                duration: Const.animationDuration,
                child: expanded
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          height: expandedSize,
                          decoration: BoxDecoration(
                            color: themes.tertiary.withOpacity(0.4),
                            borderRadius:
                                BorderRadius.circular(Const.uiRoundness * 2),
                          ),
                        ),
                      )
                    : Container(child: 0.ph),
              ),
              Center(
                child: MeasureSize(
                  onChange: (size) =>
                      setState(() => expandedSize = size.height),
                  child: ExpandablePanel(
                    controller: controller,
                    theme: ExpandableThemeData(
                      animationDuration: Const.animationDuration,
                      headerAlignment: ExpandablePanelHeaderAlignment.center,
                      hasIcon: false,
                      tapHeaderToExpand: true,
                      tapBodyToCollapse: true,
                    ),
                    header: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: verticalPadding,
                          horizontal: horizontalPadding),
                      child: SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: size,
                              width: size,
                              decoration: BoxDecoration(
                                color:
                                    widget.contact.profilePicColor!.toColor(),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Center(
                                child: widget.contact.profilePicLink != null &&
                                        widget.contact.profilePicLink != ''
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: Image.network(
                                          widget.contact.profilePicLink!,
                                          fit: BoxFit.cover,
                                          width: size,
                                          height: size,
                                        ))
                                    : Text(
                                        widget.contact.firstName![0]
                                            .toUpperCase(),
                                        style: textStyleNormal.copyWith(
                                            fontSize: 20, color: Colors.black),
                                      ),
                              ),
                            ),
                            15.pw,
                            !widget.matchedPhone
                                ? Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.yellow,
                                    ),
                                    child: Text(
                                      name.substring(0, widget.matched),
                                      style: textStyleNormal.copyWith(
                                          fontSize: 17, color: Colors.black),
                                    ),
                                  )
                                : 0.pw,
                            Text(
                              name.substring(
                                  !widget.matchedPhone ? widget.matched : 0),
                              style: textStyleNormal.copyWith(
                                  fontSize: 17, color: themes.oppositeColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    collapsed: 0.ph,
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                          color: themes.oppositeColor.withOpacity(0.4),
                          height: 0,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: verticalPadding,
                              horizontal: horizontalPadding + 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              widget.matchedPhone
                                  ? DetailsRow(
                                      icon: Icons.phone_outlined,
                                      text: widget
                                          .contact.phone!.formatPhoneNumber,
                                      matched: widget.matched,
                                    )
                                  : DetailsRow(
                                      icon: Icons.phone_outlined,
                                      text: widget
                                          .contact.phone!.formatPhoneNumber),
                              widget.contact.email == null ||
                                      widget.contact.email == ''
                                  ? 0.ph
                                  : DetailsRow(
                                      icon: Icons.email_outlined,
                                      text: widget.contact.email!),
                              widget.contact.address == null ||
                                      widget.contact.address == ''
                                  ? 0.ph
                                  : DetailsRow(
                                      icon: Icons.location_on_outlined,
                                      text: widget.contact.address!),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: horizontalPadding,
                              right: horizontalPadding,
                              bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomContactButton(
                                  text: translate('homepage.edit'),
                                  onPressed: () {
                                    showModalBottomSheet(
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        enableDrag: true,
                                        context: context,
                                        builder: (context) => ModifyContact(
                                            contact: widget.contact));
                                  },
                                  icon: Icons.edit,
                                  color: Colors.green),
                              CustomContactButton(
                                  text: translate('homepage.call'),
                                  onPressed: () {
                                    launchUrl(Uri.parse(
                                        "tel://${widget.contact.phone}"));
                                  },
                                  icon: Icons.phone,
                                  color: Colors.yellow),
                              CustomContactButton(
                                  text: translate('homepage.remove'),
                                  onPressed: () async {
                                    controller.toggle();
                                    await Future.delayed(
                                        Const.animationDuration, () async {
                                      await database.deleteContact(
                                          widget.contact.docRef!);
                                    });
                                  },
                                  icon: Icons.person_remove_rounded,
                                  color: Colors.red),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class DetailsRow extends ConsumerWidget {
  const DetailsRow({
    super.key,
    required this.icon,
    required this.text,
    this.matched = 0,
  });
  final IconData icon;
  final String text;
  final int matched;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Themes themes = ref.watch(themesProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(children: [
        Icon(
          icon,
          size: 18,
          color: themes.secondary,
        ),
        15.pw,
        Container(
          decoration: const BoxDecoration(
            color: Colors.yellow,
          ),
          child: Text(
            text.substring(0, matched),
            style: textStyleNormal.copyWith(fontSize: 16, color: Colors.black),
          ),
        ),
        Text(
          text.substring(matched),
          style: textStyleNormal.copyWith(
              fontSize: 14, color: themes.oppositeColor),
        ),
      ]),
    );
  }
}

class CustomContactButton extends ConsumerWidget {
  const CustomContactButton({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String text;
  final Color color;
  final Function onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Themes themes = ref.watch(themesProvider);
    return TextButton(
        style: TextButton.styleFrom(
            backgroundColor: Colors.transparent,
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Const.uiRoundness - 2),
            )),
        onPressed: () async => await onPressed(),
        child: SizedBox(
          height: 30,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                  6.pw,
                  Text(text,
                      style: textStyleNormal.copyWith(
                        fontSize: 15,
                        color: themes.oppositeColor,
                      )),
                ],
              ),
            ),
          ),
        ));
  }
}
