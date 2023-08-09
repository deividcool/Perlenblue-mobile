import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:snapta/global/global.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snapta/Helper/sizeConfig.dart';
import 'package:http/http.dart' as http;
import 'package:snapta/layouts/chat/chat.dart';
import 'package:snapta/layouts/post/viewPublicPost.dart';
import 'package:snapta/layouts/user/myFollowers.dart';
import 'package:snapta/layouts/user/myFollowing.dart';
import 'package:snapta/models/postFollowModal.dart';
import 'package:snapta/models/postModal.dart';
import 'package:snapta/models/unFollowModal.dart';
import 'package:snapta/models/userdata_model.dart';

class PublicProfile extends StatefulWidget {
  final String peerId;
  final String peerUrl;
  final String peerName;

  PublicProfile({this.peerId, this.peerUrl, this.peerName});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<PublicProfile> {
  bool isInView = false;

  bool isLoading = false;
  UserDataModel modal;
  PostModal postModal;
  FollowModal followModal;
  UnfollowModal unfollowModal;

  @override
  void initState() {
    print(widget.peerId + ">>>>>>>>>>");
    print(widget.peerId + ">>>>>>>>>>");
    print(userID + ' User Id');
    _getUser();
    super.initState();
  }

  _getUser() async {
    setState(() {
      isLoading = true;
    });
    var uri = Uri.parse('${baseUrl()}/user_data');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields['user_id'] = widget.peerId;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    modal = UserDataModel.fromJson(userData);
    print(responseData);
    _getPost();
  }

  _getPost() async {
    var uri = Uri.parse('${baseUrl()}/post_by_user');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields["user_id"] = widget.peerId;
    request.fields['to_user_id'] = userID;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    postModal = PostModal.fromJson(userData);
    print(responseData);
    print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
    // print(modal.user.profilePic);
    if (mounted)
      setState(() {
        isLoading = false;
      });
  }

  void containerForSheet<T>({BuildContext context, Widget child}) {
    showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T value) {});
  }

  reportSheet(BuildContext context, postId) {
    containerForSheet<String>(
      context: context,
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            child: Text(
              "Report",
              style: TextStyle(
                  color: Theme.of(context).primaryColorLight,
                  fontSize: 16,
                  fontFamily: "Lato"),
            ),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop("Discard");
              openBottmSheet(context, 'report', modal.user.id);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(fontFamily: "Lato"),
          ),
          isDefaultAction: true,
          onPressed: () {
            // Navigator.pop(context, 'Cancel');
            Navigator.of(context, rootNavigator: true).pop("Discard");
          },
        ),
      ),
    );
  }

  openBottmSheet(BuildContext context, String reportType, String peerID) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context,
            StateSetter setState /*You can rename this!*/) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                  height: 700,
                  child: ListView(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                          child: Text(
                        'Report',
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(fontWeight: FontWeight.bold),
                      )),
                      SizedBox(
                        height: 10,
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              'Why are you reporting this user?',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            ListTile(
                              onTap: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop("Discard");
                                _reportPost(peerID, 'Report Account');
                              },
                              title: new Text(
                                "Report account",
                                style: new TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.0),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            ),
          );
        });
      },
    );
  }

  var reportPostData;
  bool stackLoader = false;
  _reportPost(peerID, reportTxt) async {
    print('*******');
    // print(status);
    print('*******');
    setState(() {
      stackLoader = true;
    });

    var uri = Uri.parse('${baseUrl()}/user_report');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields['reportByUserId'] = userID;
    request.fields['reportedUserId'] = peerID;
    request.fields['status'] = '';
    request.fields['report_text'] = reportTxt;

    var response = await request.send();
    print(response.statusCode);
    print(">>>>>>>>>>>>>>>>>>>>>>>>>");
    String responseData = await response.stream.transform(utf8.decoder).join();
    reportPostData = json.decode(responseData);
    if (reportPostData['response_code'] == '1') {
      setState(() {
        stackLoader = false;
      });

      Fluttertoast.showToast(
          msg: 'User reported', toastLength: Toast.LENGTH_LONG);
      // Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(
          msg: 'User Already reported', toastLength: Toast.LENGTH_LONG);
      setState(() {
        stackLoader = false;
      });

      print('REPORT RESPONSE FAIL');
      debugPrint('${reportPostData['response_code']}');
    }

    // deleteStoryModal = DeleteStoryModal.fromJson(userData);
    print(responseData);

    setState(() {
      stackLoader = false;
    });
  }

  openHideSheet(BuildContext context, String reportType) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context,
            StateSetter setState /*You can rename this!*/) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                  height: 700,
                  child: Container(
                      child: reportPostData != null &&
                              reportPostData['response_code'] == '1'
                          ? Container(
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/Done-pana.png',
                                    height: 300,
                                    width: MediaQuery.of(context).size.width,
                                  ),
                                  reportType == 'hide'
                                      ? Column(
                                          children: [
                                            Text(
                                              'Post Hidden successfully',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  reportType == 'report'
                                      ? Column(
                                          children: [
                                            Text(
                                              'Thanks for letting us know',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                                'Your feedback is important in helping us keep the community safe.',
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption
                                                    .copyWith(fontSize: 15)),
                                            SizedBox(
                                              height: 20,
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      // background color
                                      backgroundColor: appColor,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 10),
                                      textStyle: const TextStyle(fontSize: 15),
                                    ),
                                    child: const Text('Continue'),
                                    onPressed: () {
                                      debugPrint('Button clicked!');
                                      Navigator.of(context, rootNavigator: true)
                                          .pop("Discard");
                                      Navigator.of(context)
                                          .pushReplacementNamed('/Pages',
                                              arguments: 0);
                                    },
                                  ),
                                ],
                              ),
                            )
                          : reportPostData != null &&
                                  reportPostData['response_code'] == '0'
                              ? Container(
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/Done-pana.png',
                                        height: 300,
                                        width:
                                            MediaQuery.of(context).size.width,
                                      ),
                                      reportPostData['status'] != 'fail'
                                          ? Text(
                                              'This post is already reorted',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            )
                                          : Text(
                                              'Fail to submit',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Fail to submit your report please try again',
                                        textAlign: TextAlign.center,
                                        style:
                                            Theme.of(context).textTheme.caption,
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          // background color
                                          backgroundColor: appColor,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30, vertical: 10),
                                          textStyle:
                                              const TextStyle(fontSize: 15),
                                        ),
                                        child: const Text('Continue'),
                                        onPressed: () {
                                          debugPrint('Button clicked!');
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop("Discard");
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              : Container())),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Theme.of(context).primaryColorLight),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0.5,
          title: Text(
            modal != null && modal.user.fullname != ''
                ? modal.user.fullname
                : '',
            style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).primaryColorLight,
                fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: () {
                reportPostData = null;
                reportSheet(context, modal.user.id);
                // reportSheet(
                //   context,
                //   post.postId,
                //   post.userId,
                // );
              },
              icon: Icon(
                Icons.more_horiz,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ],
          centerTitle: true,
          automaticallyImplyLeading: true,
        ),
        body: isLoading
            ? Center(
                child: loader(context),
              )
            : modal != null
                ? Stack(
                    children: [
                      Column(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 40, top: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey[600],
                                              width: 1),
                                          shape: BoxShape.circle),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: CircleAvatar(
                                          backgroundImage: modal
                                                          .user.profilePic !=
                                                      null &&
                                                  modal.user.profilePic.length >
                                                      0
                                              ? NetworkImage(
                                                  modal.user.profilePic)
                                              : NetworkImage(
                                                  "${"https://www.nicepng.com/png/detail/136-1366211_group-of-10-guys-login-user-icon-png.png"}"),
                                          radius: 45,
                                        ),
                                      ),
                                    ),
                                    _buildCategory("Posts", modal.userPost),
                                    InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    FollowingScreen(
                                                        id: modal.user.id)),
                                          );
                                        },
                                        child: _buildCategory(
                                            "Following", modal.following)),
                                    InkWell(
                                      onTap: () {
                                        print(modal.user.id);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  FollowersScreen(
                                                      id: modal.user.id)),
                                        );
                                      },
                                      child: _buildCategory(
                                          "Followers", modal.followers),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                child: Text(
                                  modal.user.username ?? '',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color:
                                          Theme.of(context).primaryColorLight),
                                ),
                              ),
                              modal.user.bio != null
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20, right: 20, top: 3),
                                      child: Column(
                                        children: [
                                          Text(
                                            modal.user.bio,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: Theme.of(context)
                                                    .primaryColorLight),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, top: 10),
                                child: widget.peerId != userID
                                    ? Row(
                                        children: [
                                          globleFollowing
                                                  .contains(modal.user.id)
                                              ? Expanded(
                                                  child: Container(
                                                    // width: 100,
                                                    // ignore: deprecated_member_use
                                                    child: ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: 1.5))),
                                                      child: Text(
                                                        "Following",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[700]),
                                                      ),
                                                      onPressed: () {
                                                        unfollowApiCall();
                                                      },
                                                    ),
                                                  ),
                                                )
                                              : Expanded(
                                                  child: Container(
                                                    // width: 100,
                                                    // ignore: deprecated_member_use
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                              ),
                                                              backgroundColor:
                                                                  buttonColorBlue),
                                                      child: Text(
                                                        "Follow",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      onPressed: () {
                                                        followApiCall();
                                                      },
                                                    ),
                                                  ),
                                                ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                              child: Container(
                                            // width: 100,
                                            // ignore: deprecated_member_use
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    side: BorderSide(
                                                        color: Colors.grey,
                                                        width: 1.5)),
                                              ),
                                              child: Text(
                                                "Message",
                                                style: TextStyle(
                                                    color: Colors.grey[700]),
                                              ),
                                              onPressed: () {
                                                if (userName != '')
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Chat(
                                                              peerID:
                                                                  widget.peerId,
                                                              peerUrl: widget
                                                                  .peerUrl,
                                                              peerName: widget
                                                                  .peerName,
                                                              // currentusername:
                                                              //     userName,
                                                              // currentuserimage:
                                                              //     userImage,
                                                              // currentuser: userID,
                                                              //  peerToken: widget.peerToken,
                                                            )),
                                                  );
                                              },
                                            ),
                                          ))
                                        ],
                                      )
                                    : globleFollowing.contains(modal.user.id)
                                        ? Expanded(
                                            child: Container(
                                              // width: 100,
                                              // ignore: deprecated_member_use
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      side: BorderSide(
                                                          color: Colors.grey,
                                                          width: 1.5)),
                                                ),
                                                child: Text(
                                                  "Following",
                                                  style: TextStyle(
                                                      color: Colors.grey[700]),
                                                ),
                                                onPressed: () {
                                                  unfollowApiCall();
                                                },
                                              ),
                                            ),
                                          )
                                        : Expanded(
                                            child: Container(
                                              // width: 100,
                                              // ignore: deprecated_member_use
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      buttonColorBlue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                ),

                                                child: Text(
                                                  "Follow",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                // ignore: deprecated_member_use

                                                onPressed: () {
                                                  followApiCall();
                                                },
                                              ),
                                            ),
                                          ),
                              ),
                            ],
                          ),
                          Expanded(child: _userPost()),
                        ],
                      ),
                      stackLoader
                          ? Center(
                              child: loader(context),
                            )
                          : Container()
                    ],
                  )
                : Container());
  }

  Widget _userPost() {
    return myPost();
  }

  Widget myPost() {
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: postModal.follower.length > 0
            ? GridView.builder(
                shrinkWrap: true,
                // physics: NeverScrollableScrollPhysics(),
                primary: false,
                padding: EdgeInsets.all(5),
                itemCount: postModal.follower.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 200 / 200,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                      padding: EdgeInsets.all(5.0),
                      child: postModal.follower[index].allImage.length > 0
                          ? InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewPublicPost(
                                          id: postModal
                                              .follower[index].postId)),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(0),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      postModal.follower[index].allImage[0],
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) => Center(
                                    child: Container(
                                        // height: 40,
                                        // width: 40,
                                        child: CircularProgressIndicator()),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )

                          // Image.network(
                          //     postModal
                          //         .follower[index].allImage[0],
                          //     fit: BoxFit.cover,
                          //   )
                          : postModal.follower[index].video.length > 0 &&
                                  postModal.follower[index].thumbnail != ''
                              ? InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ViewPublicPost(
                                              id: postModal
                                                  .follower[index].postId)),
                                    );
                                  },
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(0),
                                        child: CachedNetworkImage(
                                          imageUrl: postModal
                                              .follower[index].thumbnail,
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          placeholder: (context, url) => Center(
                                            child: Container(
                                                // height: 40,
                                                // width: 40,
                                                child:
                                                    CircularProgressIndicator()),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5, top: 5),
                                          child: Icon(
                                            CupertinoIcons.play_circle_fill,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.image,
                                    size: 120,
                                  )));
                },
              )
            : Container(
                height: SizeConfig.blockSizeVertical * 20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Share photos and videos",
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 5,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 2,
                    ),
                    Text(
                      "When you share photos and videos, they'll appear\non your profile",
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 3,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ));
  }

  Widget _buildCategory(String title, data) {
    return Column(
      children: <Widget>[
        Text(
          data,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(),
        ),
      ],
    );
  }

  followApiCall() async {
    var uri = Uri.parse('${baseUrl()}/follow_user');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields['from_user'] = userID;
    request.fields['to_user'] = widget.peerId;
    var response = await request.send();
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    followModal = FollowModal.fromJson(userData);
    if (followModal.responseCode == "1") {
      setState(() {
        globleFollowing.add(widget.peerId);
      });
    }
  }

  unfollowApiCall() async {
    var uri = Uri.parse('${baseUrl()}/unfollow_user');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields['from_user'] = userID;
    request.fields['to_user'] = widget.peerId;
    var response = await request.send();
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    unfollowModal = UnfollowModal.fromJson(userData);
    if (unfollowModal.responseCode == "1") {
      setState(() {
        globleFollowing.remove(widget.peerId);
      });
    }
  }
}
