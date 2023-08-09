import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snapta/global/global.dart';
import 'package:snapta/layouts/user/publicProfile.dart';
import 'package:timeago/timeago.dart';

import 'chat.dart';

class ChatList extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  ChatList({Key key, this.parentScaffoldKey}) : super(key: key);
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColorLight),
        elevation: 0.5,
        title: Text(
          "Messages",
          style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).primaryColorLight,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // leading: IconButton(
        //   icon: Image.asset(
        //     'assets/images/menu.png',
        //     height: 35,
        //     width: 35,
        //   ),
        //   onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
        // ),
      ),
      body: Container(
        height: double.infinity,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(40),
                        topLeft: Radius.circular(40)),
                    // image: DecorationImage(
                    //   image: AssetImage(
                    //     "assets/images/img.png",
                    //   ),
                    //   fit: BoxFit.fill,
                    //   alignment: Alignment.topCenter,
                    //   colorFilter: new ColorFilter.mode(
                    //       Colors.blue.withOpacity(0.5), BlendMode.dstATop),
                    // ),
                  ),
                  child: friendListToMessage(userID)),
            ),
          ],
        ),
      ),
    );
  }

  Widget friendListToMessage(String userData) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("chatList")
          .doc(userData)
          .collection(userData)
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: snapshot.data.docs.length > 0
                ? ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: snapshot.data.docs.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: const Divider(),
                    ),
                    itemBuilder: (context, int index) {
                      List chatList = snapshot.data.docs;
                      return buildItem(chatList, index);
                    },
                  )
                : Center(
                    child: Text("Currently you don't have any messages"),
                  ),
          );
        }
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                CupertinoActivityIndicator(),
              ]),
        );
      },
    );
  }

  Widget buildItem(List chatList, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 0, top: 0),
      child: Column(
        children: [
          Container(
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 8),
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 0),
                    child: Container(
                      decoration: new BoxDecoration(
                          //color: Colors.grey[300],
                          borderRadius:
                              new BorderRadius.all(Radius.circular(0.0))),
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.centerLeft,
                      child: Stack(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              print(
                                  '${chatList[index]['id']},${chatList[index]['profileImage']},${chatList[index]['name']}');
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => Chat(
                                          peerID: chatList[index]['id'],
                                          peerUrl: chatList[index]
                                                      ['profileImage'] !=
                                                  null
                                              ? chatList[index]['profileImage']
                                              : null,
                                          peerName: chatList[index]['name'])));
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(width: 35),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 50,
                                        top: 10,
                                        right: 40,
                                        bottom: 5),
                                    child: Container(
                                      // color: Colors.purple,
                                      width: MediaQuery.of(context).size.width -
                                          200,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            height: 5,
                                          ),
                                          Container(
                                            // color: Colors.yellow,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                180,
                                            child: Text(
                                              chatList[index]['name'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .primaryColorLight,
                                                fontFamily: "Poppins-Medium",
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          // Padding(
                                          //   padding:
                                          //       const EdgeInsets.only(top: 3),
                                          //   child: Container(
                                          //     width: MediaQuery.of(context)
                                          //             .size
                                          //             .width -
                                          //         150,
                                          //     child: Text(
                                          //       DateFormat('dd MMM yyyy, kk:mm')
                                          //           .format(DateTime
                                          //               .fromMillisecondsSinceEpoch(
                                          //                   int.parse(chatList[
                                          //                           index][
                                          //                       'timestamp']))),
                                          //       style: TextStyle(
                                          //           color: Color(0xFF343e57),
                                          //           fontSize: 11.0,
                                          //           fontStyle:
                                          //               FontStyle.normal),
                                          //     ),
                                          //   ),
                                          // ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 3),
                                            child: Container(
                                              // color: Colors.red,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  150,
                                              height: 20,
                                              child: Text(
                                                chatList[index]['type'] !=
                                                            null &&
                                                        chatList[index]
                                                                ['type'] ==
                                                            1
                                                    ? "📷 Image"
                                                    : chatList[index]
                                                        ['content'],
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: appColor,
                                                  fontSize: 12,
                                                  fontFamily: "Poppins-Medium",
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Row(
                                      children: [
                                        Text(format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                int.parse(
                                              chatList[index]['timestamp'],
                                            )),
                                            locale: 'en_short')),
                                        int.parse(chatList[index]['badge']) > 0
                                            ? Row(
                                                children: [
                                                  SizedBox(
                                                    width: 05,
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.red,
                                                    ),
                                                    alignment: Alignment.center,
                                                    height: 30,
                                                    width: 30,
                                                    child: Text(
                                                      chatList[index]['badge'],
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w900),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Container(),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 12),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PublicProfile(
                                  peerId: chatList[index]['id'],
                                  peerUrl: chatList[index]['profileImage'],
                                  peerName: chatList[index]['name'])),
                        );
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.5,
                          ),
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: Material(
                          child: chatList[index]['profileImage'] != null
                              ? CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CupertinoActivityIndicator(),
                                    width: 30.0,
                                    height: 30.0,
                                    padding: EdgeInsets.all(10.0),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Material(
                                    child: Padding(
                                      padding: const EdgeInsets.all(0.0),
                                      child: Icon(
                                        Icons.person,
                                        size: 30,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  imageUrl: chatList[index]['profileImage']
                                      .toString(),
                                  width: 35.0,
                                  height: 35.0,
                                  fit: BoxFit.cover,
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(05.0),
                                  child: Icon(
                                    Icons.person,
                                    size: 25,
                                  ),
                                ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(100.0),
                          ),
                          clipBehavior: Clip.hardEdge,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget friendName(AsyncSnapshot friendListSnapshot, int index) {
    return Container(
      width: 200,
      alignment: Alignment.topLeft,
      child: RichText(
        text: TextSpan(children: <TextSpan>[
          TextSpan(
            text:
                "${friendListSnapshot.data["firstname"]} ${friendListSnapshot.data["lastname"]}",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
          )
        ]),
      ),
    );
  }

  Widget messageButton(AsyncSnapshot friendListSnapshot, int index) {
    // ignore: deprecated_member_use
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        "Message",
        style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
      ),
      onPressed: () {},
    );
  }
}
