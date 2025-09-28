import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:chatview/chatview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/constants/launchers_helper.dart';
import 'package:leadmanagementsystem/controllers/chat_controller.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/chat_members_model.dart';
import 'package:leadmanagementsystem/screens/chat/chat_theme.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ChatTheme theme = LightTheme();

  late ChatController _chatController;

  ChatViewState chatViewState = ChatViewState.loading;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late CollectionReference collectionRef;
  List<Message> messages = [];

  bool isFirstLoad = true;
  List<Member> members = [];
  final chatCont = Get.find<MyChatController>();
  String roomId = "RGCChats";
  @override
  void initState() {
    super.initState();
    members = chatCont.members;

    collectionRef = firestore.collection(roomId);
    _chatController = ChatController(
      initialMessageList: messages,
      scrollController: ScrollController(),
      currentUser: ChatUser(
        id: loginStorage.getUserId()!,
        name: loginStorage.getUserName(),
        // profilePhoto: (ApiUrls.imageBaseUrl +
        //     (profileBloc.myProfileModel?.user?.avatar ?? '')),
      ),
      otherUsers: members.map((member) {
        return ChatUser(
          id: member.userId ?? "",
          name: member.name ?? "",
          // profilePhoto: ApiUrls.imageBaseUrl + (member.avatar ?? ''),
          //! use following image as place holdeer and put it on server
          //profilePHNImg
        );
      }).toList(),
    );
    listenNewMessages();

    loadInitialChat();
  }

  void receiveMessage() async {
    // _chatController.addMessage(
    //   Message(
    //     id: DateTime.now().toString(),
    //     message: 'I will schedule the meeting.',
    //     createdAt: DateTime.now(),
    //     sentBy: '2',
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatView(
        chatController: _chatController,
        onSendTap: _onSendTap,
        swipeToReplyConfig: SwipeToReplyConfiguration(
          onLeftSwipe: (message, sentBy) {},
          onRightSwipe: (message, sentBy) {},
        ),
        featureActiveConfig: const FeatureActiveConfig(
          enableReplySnackBar: false,
          enableReactionPopup: false,
          enableDoubleTapToLike: false,
          enableSwipeToReply: false,
          lastSeenAgoBuilderVisibility: false,
          receiptsBuilderVisibility: false,
          enableScrollToBottomButton: false,
          enableSwipeToSeeTime: true,
        ),
        scrollToBottomButtonConfig: ScrollToBottomButtonConfig(
          // backgroundColor: ,
          border: Border.all(
            color: Colors.grey,
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: greyColor,
            weight: 10,
            size: 30,
          ),
        ),
        chatViewState: chatViewState,
        chatViewStateConfig: ChatViewStateConfiguration(
          loadingWidgetConfig: ChatViewStateWidgetConfiguration(
            widget: showSpinkit(),
            reloadButton: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // 🔹 button background
                foregroundColor: Colors.white, // 🔹 text/icon color
              ),
              onPressed: () => loadInitialChat(),
              child: const Text("Reload Chat"),
            ),
          ),
          onReloadButtonTap: () {
            loadInitialChat();
          },
        ),
        appBar: ChatViewAppBar(
          leading: InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Icon(CupertinoIcons.back),
            ),
          ),
          elevation: theme.elevation,
          backGroundColor: theme.appBarColor,
          // profilePicture: widget.roomImageUrl != null
          //     ? ApiUrls.imageBaseUrl + widget.roomImageUrl!
          //     : ApiUrls.communityPHNImg,
          backArrowColor: theme.backArrowColor,
          chatTitle: "RGC CHAT",
          chatTitleTextStyle: TextStyle(
            color: theme.appBarTitleTextStyle,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            // letterSpacing: 0.25,
          ),
          userStatusTextStyle: const TextStyle(color: Colors.grey),
        ),
        chatBackgroundConfig: ChatBackgroundConfiguration(
          messageTimeIconColor: greyColor,
          messageTimeTextStyle: const TextStyle(
            color: greyColor,
          ),
          defaultGroupSeparatorConfig: const DefaultGroupSeparatorConfiguration(
            textStyle: TextStyle(
              color: greyColor,
              fontSize: 17,
            ),
          ),
          backgroundColor: theme.backgroundColor,
        ),
        sendMessageConfig: SendMessageConfiguration(
          sendButtonIcon: const Icon(Icons.send_rounded),
          allowRecordingVoice: false,
          imagePickerIconsConfig: const ImagePickerIconsConfiguration(
            cameraIconColor: whiteColor,
            galleryIconColor: whiteColor,
          ),
          defaultSendButtonColor: theme.sendButtonColor,
          textFieldBackgroundColor: greyColor,
          closeIconColor: theme.closeIconColor,
          textFieldConfig: TextFieldConfiguration(
            onMessageTyping: (status) {
              /// Do with status
              debugPrint(status.toString());
            },
            compositionThresholdTime: const Duration(seconds: 1),
            textStyle: TextStyle(color: theme.textFieldTextColor),
          ),
        ),
        chatBubbleConfig: ChatBubbleConfiguration(
          outgoingChatBubbleConfig: ChatBubble(
            linkPreviewConfig: LinkPreviewConfiguration(
              backgroundColor: greyColor,
              // bodyStyle: theme.outgoingChatLinkBodyStyle,
              // titleStyle: theme.outgoingChatLinkTitleStyle,
              onUrlDetect: (p0) {
                UrlLauncherHelper.launchURL(p0);
              },
            ),
            receiptsWidgetConfig:
                const ReceiptsWidgetConfig(showReceiptsIn: ShowReceiptsIn.all),
            color: appColor,
          ),
          inComingChatBubbleConfig: ChatBubble(
            linkPreviewConfig: const LinkPreviewConfiguration(
              linkStyle: TextStyle(
                color: greyColor,
                decoration: TextDecoration.underline,
              ),
              backgroundColor: greyColor,
              // bodyStyle: isDarkTheme?whiteColor:greyColor,
              // titleStyle: theme.incomingChatLinkTitleStyle,
            ),
            textStyle: const TextStyle(
              color: whiteColor,
            ),
            onMessageRead: (message) {
              /// send your message reciepts to the other client
              debugPrint('Message Read');
            },
            senderNameTextStyle: const TextStyle(color: greyColor),
            color: greyColor,
          ),
        ),
        messageConfig: const MessageConfiguration(
          imageMessageConfig: ImageMessageConfiguration(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          ),
        ),
        // profileCircleConfig: const ProfileCircleConfiguration(
        //   profileImageUrl: "Data.profileImage",
        // ),
        reactionPopupConfig:
            const ReactionPopupConfiguration(showGlassMorphismEffect: true),
      ),
    );
  }

  Future<void> _onSendTap(
    String message,
    ReplyMessage replyMessage,
    MessageType messageType,
  ) async {
    log("_onSendTap fired message: $message, replyMessage: $replyMessage, messageType: $messageType");
    if (messageType == MessageType.image || messageType == MessageType.voice) {
      String? imageUrl = await uploadImageAndGetUrl(
        message,
      );
      if (imageUrl == null) {
        Get.snackbar("Error", "Message not sent");
      } else {
        _chatController.addMessage(
          Message(
            id: DateTime.now().toString(),
            createdAt: DateTime.now(),
            message: message,
            sentBy: _chatController.currentUser.id,
            replyMessage: replyMessage,
            messageType: messageType,
          ),
        );
        saveMessage(
          imageUrl,
          replyMessage,
          messageType,
        );
      }
    } else if (messageType == MessageType.text) {
      _chatController.addMessage(
        Message(
          id: DateTime.now().toString(),
          createdAt: DateTime.now(),
          message: message,
          sentBy: _chatController.currentUser.id,
          replyMessage: replyMessage,
          messageType: messageType,
        ),
      );
      saveMessage(
        message,
        replyMessage,
        messageType,
      );
    }
  }

  void loadInitialChat() {
    firestore
        .collection(roomId)
        .orderBy('createdAt') // Recommended
        .get()
        .then((value) {
      List<QueryDocumentSnapshot> docs = value.docs;
      if (docs.isNotEmpty) {
        MessageType type = MessageType.text;

        try {
          messages = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            type = MessageType.values.firstWhere(
              (e) => e.name == data['messageType'],
              orElse: () => MessageType.text,
            );
            return Message(
              id: doc.id,
              message: type == MessageType.image
                  ? baseUrl + data['message']
                  : data['message'] ?? '',
              sentBy: data['sentBy'] ?? '',
              createdAt: (data['createdAt'] as Timestamp).toDate(),
              messageType: type,
            );
          }).toList();
          _chatController.initialMessageList.clear();
          _chatController.initialMessageList.addAll(messages);
        } catch (e) {
          log("Error parsing messages: $e");
        }
      }

      if (docs.isNotEmpty) {
        log("value in firebase = ${docs.last.data()}");
      }

      log("messages length = ${messages.length}");
      chatViewState = messages.isNotEmpty
          ? ChatViewState.hasMessages
          : ChatViewState.noData;
      setState(() {});
    }).onError((error, stackTrace) {
      chatViewState = ChatViewState.error;
      setState(() {});
    });
  }

  Future<String?> uploadImageAndGetUrl(String message) async {
    File file = File(message);

    try {
      String? imagePath = await chatCont.uploadImage(file);
      return imagePath;
    } catch (e) {
      return null;
    }
  }

  void saveMessage(
    String message,
    ReplyMessage replyMessage,
    MessageType messageType,
  ) {
    firestore.collection(roomId).add({
      'message': message,
      'sentBy': _chatController.currentUser.id,
      'createdAt': DateTime.now(),
      'replyMessage': replyMessage.toJson(),
      'messageType': messageType.name,
    }).then((value) {
      // Message sent successfully
      setState(() {
        chatViewState = ChatViewState.hasMessages;
      });
    }).catchError((error) {
      // Handle error
      debugPrint('Error sending message: $error');
      setState(() {
        chatViewState = ChatViewState.error;
      });
    });
  }

  void listenNewMessages() {
    collectionRef
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen((querySnapshot) {
      log("isFirstLoad in listenNewMessages = $isFirstLoad");

      // ⛔ Skip the first load (we're already loading messages manually)
      if (isFirstLoad) {
        isFirstLoad = false;
        return;
      }

      for (var change in querySnapshot.docChanges) {
        if (change.type != DocumentChangeType.added) continue;

        final data = change.doc.data() as Map<String, dynamic>;

        if (data['sentBy'] == loginStorage.getUserId()) return;

        log("🟢 New message received: $data");

        final messageType = MessageType.values.firstWhere(
          (e) => e.name == data['messageType'],
          orElse: () => MessageType.text,
        );

        log("image url = ${baseUrl + data['message']}");

        final newMessage = Message(
          id: change.doc.id,
          message: messageType == MessageType.image
              ? baseUrl + data['message']
              : data['message'] ?? '',
          sentBy: data['sentBy'] ?? '',
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          replyMessage: ReplyMessage.fromJson(data['replyMessage']),
          messageType: messageType,
        );

        _chatController.addMessage(newMessage);

        if (chatViewState == ChatViewState.noData) {
          setState(() {
            chatViewState = ChatViewState.hasMessages;
          });
        }
      }
    });
  }
}
