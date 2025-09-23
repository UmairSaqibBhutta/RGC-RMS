import 'package:flutter/material.dart';
import 'package:leadmanagementsystem/constants/constants.dart';

class ChatTheme {
  final Color? appBarColor;
  final Color? backArrowColor;
  final Color? backgroundColor;
  final Color? textFieldTextColor;
  final Color? closeIconColor;
  final Color? sendButtonColor;
  final Color? appBarTitleTextStyle;
  final double? elevation;
  final Color? chatBubbleColor;
  final Color? chatBubbleTextColor;
  final Color? timeStampColor;
  final Color? statusIconColor;
  final Color? inputBorderColor;
  final Color? inputFillColor;
  final Color? hintTextColor;
  final Color? dividerColor;

  ChatTheme({
    this.appBarColor,
    this.backArrowColor,
    this.backgroundColor,
    this.textFieldTextColor,
    this.closeIconColor,
    this.sendButtonColor,
    this.appBarTitleTextStyle,
    this.elevation,
    this.chatBubbleColor,
    this.chatBubbleTextColor,
    this.timeStampColor,
    this.statusIconColor,
    this.inputBorderColor,
    this.inputFillColor,
    this.hintTextColor,
    this.dividerColor,
  });
}

class DarkTheme extends ChatTheme {
  DarkTheme()
      : super(
          appBarColor: blackColor,
          backArrowColor: whiteColor,
          backgroundColor: blackColor,
          textFieldTextColor: whiteColor,
          closeIconColor: whiteColor,
          sendButtonColor: blackColor,
          appBarTitleTextStyle: whiteColor,
          elevation: 1,
          chatBubbleColor: appColor,
          chatBubbleTextColor: whiteColor,
          timeStampColor: greyColor,
          statusIconColor: greyColor,
          inputBorderColor: greyColor,
          inputFillColor: greyColor,
          hintTextColor: greyColor,
          dividerColor: greyColor,
        );
}

class LightTheme extends ChatTheme {
  LightTheme()
      : super(
          appBarColor: whiteColor,
          backArrowColor: blackColor,
          backgroundColor: whiteColor,
          textFieldTextColor: whiteColor,
          closeIconColor: blackColor,
          sendButtonColor: blackColor,
          appBarTitleTextStyle: blackColor,
          elevation: 2,
          chatBubbleColor: appColor,
          chatBubbleTextColor: blackColor,
          timeStampColor: whiteColor,
          statusIconColor: greyColor,
          inputBorderColor: greyColor,
          inputFillColor: whiteColor,
          hintTextColor: whiteColor,
          dividerColor: greyColor,
        );
}
