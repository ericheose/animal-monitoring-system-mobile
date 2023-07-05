import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/models/models.dart';
import 'package:my_app/pages/chat-page.dart';
import 'package:my_app/theme.dart';
import 'package:my_app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import '../database_service.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context);
    return Scaffold(
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: dbService.getUserChats(),
        builder: (BuildContext context,
            AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            print('Waiting for data...');
            return const CircularProgressIndicator();
          }

          if (snapshot.hasData) {}

          List<DocumentSnapshot> chats = snapshot.data!;
          return CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return FutureBuilder<String>(
                      future:
                          dbService.getUserName(chats[index].get('users')[0]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        String userName = snapshot.data ?? 'Unknown';

                        return FutureBuilder<String>(
                          future: dbService.getLastMessageContent(chats[index]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }

                            String lastMessageContent =
                                snapshot.data ?? 'No content';

                            return FutureBuilder<Timestamp>(
                              future: dbService
                                  .getLastMessageTimeStamp(chats[index]),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }

                                Timestamp lastMessageTimeStamp =
                                    snapshot.data ??
                                        Timestamp.fromDate(DateTime.now());

                                String dateMessage =
                                    Jiffy(lastMessageTimeStamp.toDate())
                                        .fromNow();

                                // assuming profilePicture is stored in user document and obtained using getUserName function
                                return FutureBuilder<String>(
                                  future: dbService.getUserProfilePicture(chats[
                                          index]
                                      .get('users')[0]
                                      .id), // users[0] should be a DocumentReference of user
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }

                                    String profilePicture =
                                        snapshot.data ?? 'default_image_path';

                                    return _MessageTitle(
                                      messageData: MessageData(
                                        chatId: chats[index].id,
                                        senderName: userName,
                                        message: lastMessageContent,
                                        messageDate:
                                            lastMessageTimeStamp.toDate(),
                                        dateMessage: dateMessage,
                                        profilePicture: profilePicture,
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                  childCount: chats.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MessageTitle extends StatelessWidget {
  const _MessageTitle({
    Key? key,
    required this.messageData,
  }) : super(key: key);

  final MessageData messageData;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(chatPage.route(messageData));
        },
        child: Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey,
                width: 0.2,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Avatar.medium(url: messageData.profilePicture),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          messageData.senderName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            letterSpacing: 0.2,
                            wordSpacing: 1.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                        child: Text(
                          messageData.message,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textFaded,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        messageData.dateMessage.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          letterSpacing: -0.2,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textFaded,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textLigth,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
