import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:snapta/Helper/sizeConfig.dart';
import 'package:snapta/global/global.dart';
import 'package:snapta/layouts/user/forgotpass.dart';
import 'package:snapta/layouts/user/google_sign_in.dart';
import 'package:snapta/layouts/user/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapta/models/getSettingModel.dart';
import 'package:snapta/models/social_model.dart';
import 'package:snapta/shared_preferences/preferencesKey.dart';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLoading = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  // ignore: unused_field
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final emailNode = FocusNode();
  final passwordNode = FocusNode();
  bool _obscureText = false;

  @override
  void initState() {
    getSetting();
    super.initState();
  }

  GetSettingModel settingModel;
  getSetting() async {
    setState(() {
      // isLoading = true;
    });

    var uri = Uri.parse('${baseUrl()}/get_setting');
    var request = http.MultipartRequest("GET", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    // request.fields['user_id'] = userID;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    settingModel = GetSettingModel.fromJson(userData);
    setState(() {
      privacyPolicy = settingModel.settings.prvPolUrl.toString();
      termsandConditions = settingModel.settings.tncUrl.toString();
      serverKey = settingModel.settings.notifyKey.toString();
    });

    print(responseData);

    if (mounted) {
      setState(() {
        print('privacyPolicy>>>>' + privacyPolicy);
        print('termsandConditions>>>>' + termsandConditions);
        print('serverKey>>>>' + serverKey);
        print("SUCCESS");
        // isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Container(
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
              colors: [
                // const Color(0xFFC7A4D5),
                // const Color(0xFFB5B7E0),
                Colors.white,
                Colors.white,
              ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),
        child: WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: LayoutBuilder(builder: (context, constraint) {
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                // Padding(
                                //   padding: const EdgeInsets.only(top: 100),
                                //   child: Center(child: _appIcon()),
                                // ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 100),
                                  child: Center(
                                      child: Text('Snapta',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColorLight,
                                              fontFamily: 'BrushScript',
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal *
                                                  12.5))),
                                ),
                                SizedBox(
                                  height: SizeConfig.blockSizeVertical * 10,
                                ),
                                _emailTextfield(context),
                                _passwordTextfield(context),
                                _forgotPassword(),
                                _loginButton(context),
                                // _dontHaveAnAccount(context),
                                Padding(
                                  padding: const EdgeInsets.only(top: 30),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      horizontalLine(),
                                      Text("OR",
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              fontFamily: "Poppins-Medium",
                                              fontWeight: FontWeight.bold,
                                              color: fontColorGrey)),
                                      horizontalLine(),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                //numberButton(),
                                googleButton(),
                                Platform.isIOS == true
                                    ? appleButton()
                                    : SizedBox(),
                              ],
                            ),
                            isLoading == true
                                ? Center(child: loader(context))
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      color: Colors.grey[300],
                    ),
                    _dontHaveAnAccount(context),
                  ],
                );
              })),
        ),
      ),
    );
  }

  Widget _emailTextfield(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
        child: CustomtextField(
          focusNode: emailNode,
          textInputAction: TextInputAction.next,
          controller: emailController,
          hintText: 'Enter Email',
          prefixIcon: Icon(
            Icons.person,
            color: iconColor,
            size: 30.0,
          ),
        ));
  }

  Widget _passwordTextfield(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
        child: CustomtextField(
          focusNode: passwordNode,
          maxLines: 1,
          controller: passwordController,
          obscureText: !_obscureText,
          hintText: 'Enter Password',
          prefixIcon: Icon(
            Icons.lock,
            color: iconColor,
            size: 30.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
              color: appColorGrey,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
        ));
  }

  Widget _forgotPassword() {
    return Padding(
      padding: const EdgeInsets.only(right: 20, top: 10),
      child: Align(
        alignment: Alignment.topRight,
        child: InkWell(
          onTap: () {
            setState(() {
              emailNode.unfocus();
              passwordNode.unfocus();
            });
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ForgetPass()),
            );
          },
          child: Text.rich(
            TextSpan(
              text: 'Forgot Password?',
              style: TextStyle(
                fontSize: 14,
                color: appColor,
                fontWeight: FontWeight.normal,
                fontFamily: "Poppins-Medium",
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Padding(
        padding: const EdgeInsets.only(right: 20, top: 0, left: 20),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(0)),
          height: 55,
          width: SizeConfig.blockSizeHorizontal * 85,
          child: CustomButtom(
            title: 'Log In',
            color: Colors.black,
            onPressed: () {
              if (emailController.text.isNotEmpty &&
                  passwordController.text.isNotEmpty) {
                setState(() {
                  emailNode.unfocus();
                  passwordNode.unfocus();
                  isLoading = true;
                });

                _signInWithEmailAndPassword();
              } else {
                setState(() {
                  emailNode.unfocus();
                  passwordNode.unfocus();
                });
                toast("Error", "Email and password is required", context);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _dontHaveAnAccount(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => SignUp(),
          ),
        );
      },
      child: Padding(
        padding:
            const EdgeInsets.only(right: 20, top: 10, left: 20, bottom: 10),
        child: Text.rich(
          TextSpan(
            text: "Don't have an account? ",
            style: TextStyle(
              fontSize: 14,
              color: appColorGrey,
              fontWeight: FontWeight.w700,
            ),
            children: <TextSpan>[
              TextSpan(
                text: 'Sign Up',
                style: TextStyle(
                  fontSize: 14,
                  // decoration: TextDecoration.underline,
                  color: appColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget appleButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 30),
      child: Container(
          height: 55,
          width: SizeConfig.blockSizeHorizontal * 85,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(05),
            color: Colors.black,
            // shape: BoxShape.circle,
            boxShadow: [],
          ),
          child: InkWell(
            onTap: () {
              _signInWithApple();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: new Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  new Image.asset('assets/images/apple.png',
                      height: SizeConfig.blockSizeVertical * 4),
                  // new Image.asset('assets/images/apple.png',
                  //     height: SizeConfig.blockSizeVertical * 4),
                  new Container(
                      padding: EdgeInsets.only(left: 0.0, right: 10.0),
                      child: new Text(
                        "Sign in with Apple",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      )),
                ],
              ),
            ),
          )),
    );
  }

  Future<void> _signInWithApple() async {
    loginWithApple().whenComplete(() {
      setState(() {
        // controller.reverse();
      });
    });
  }

  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future loginWithApple() async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],

      nonce: nonce,
      // webAuthenticationOptions: WebAuthenticationOptions(
      //   clientId: 'com.pressfame.applesignin',
      //   redirectUri: Uri.parse(
      //     'https://com.pressfame.applesignin.glitch.me/callbacks/sign_in_with_apple',
      //     // 'https://example.com/callbacks/sign_in_with_apple',
      //     // 'https://pressfame-fb8d6.firebaseapp.com/__/auth/handler',
      //   ),
      // ),

      //nonce: 'example-nonce',
      // state: 'example-state',
    );
    print("????????????????????????????");

    // FirebaseAuth firebaseAuth;
    // final rawNonce = generateNonce();

    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: credential.identityToken,
      rawNonce: rawNonce,
    );

    final authResult =
        await FirebaseAuth.instance.signInWithCredential(oauthCredential);

    final firebaseUser = authResult.user;
    // await firebaseUser
    //     .updateDisplayName('${credential.givenName} ${credential.familyName}');
    await firebaseUser.updateEmail(credential.email);
    print("userID: " + authResult.user.uid.toString());
    print("Email: " + credential.email.toString());
    print("Name: " + credential.toString());
    print("Token: " + credential.identityToken.toString());

    if (authResult.user != null) {
      _userDataPost(authResult.user.uid, authResult.user.email,
          credential.givenName, authResult.user.photoURL);
    }

    final signInWithAppleEndpoint = Uri(
      scheme: 'https',
      host: 'flutter-sign-in-with-apple-example.glitch.me',
      path: '/sign_in_with_apple',
      queryParameters: <String, String>{
        'code': credential.authorizationCode,
        if (credential.givenName != null) 'firstName': credential.givenName,
        if (credential.familyName != null) 'lastName': credential.familyName,
        'useBundleId': Platform.isIOS || Platform.isMacOS ? 'true' : 'false',
        if (credential.state != null) 'state': credential.state,
      },
    );

    final session = await http.Client().post(
      signInWithAppleEndpoint,
    );

    print(session);
  }

  _userDataPost(userID, email, name, photo) async {
    SocialModel socialModel;
    FirebaseMessaging.instance.getToken().then((token) async {
      var uri = Uri.parse('${baseUrl()}/social_login');
      var request = new http.MultipartRequest("Post", uri);
      Map<String, String> headers = {
        "Accept": "application/json",
      };
      request.headers.addAll(headers);
      request.fields.addAll({
        'username': name.toString(),
        'email': email.toString(),
        'type': 'apple',
        'id': userID.toString(),
        'image_url': photo.toString(),
        'google_id': '',
        "device_token": token
      });
      var response = await request.send();
      print(response.statusCode);
      String responseData =
          await response.stream.transform(utf8.decoder).join();
      var userData = json.decode(responseData);
      socialModel = SocialModel.fromJson(userData);

      if (socialModel.responseCode == "1") {
        String userResponseStr = json.encode(userData);
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString(
            SharedPreferencesKey.LOGGED_IN_USERRDATA, userResponseStr);
        Navigator.of(context).pushReplacementNamed('/Pages', arguments: 0);
        // Navigator.of(context).pushAndRemoveUntil(
        //   MaterialPageRoute(
        //     builder: (context) => BottomTabbar(),
        //   ),
        //   (Route<dynamic> route) => false,
        // );
      } else {
        toast("apple login fail!", context, context);
      }
      print(responseData);
    });
  }

  Widget horizontalLine() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
            width: SizeConfig.blockSizeHorizontal * 30,
            height: 2.0,
            color: Colors.grey[300]),
      );
  Widget googleButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 30),
      child: Container(
          height: 55,
          // width: 350,
          width: SizeConfig.blockSizeHorizontal * 85,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.black,
            // shape: BoxShape.circle,
            boxShadow: [],
          ),
          child: InkWell(
            onTap: () {
              _signInWithGoogle();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: new Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  new Image.asset('assets/images/google.png',
                      height: SizeConfig.blockSizeVertical * 4),
                  new Container(
                      padding: EdgeInsets.only(left: 0.0, right: 10.0),
                      child: new Text(
                        "Sign in with Google",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      )),
                ],
              ),
            ),
          )),
    );
  }

  // Widget googleButton() {
  //   return Padding(
  //     padding: const EdgeInsets.only(top: 20, bottom: 30),
  //     child: Container(
  //         width: SizeConfig.blockSizeHorizontal * 70,
  //         margin: EdgeInsets.fromLTRB(30.0, 5.0, 30.0, 5.0),
  //         child: InkWell(
  //           onTap: () {
  //             _signInWithGoogle();
  //           },
  //           child: new Row(
  //             mainAxisSize: MainAxisSize.min,
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: <Widget>[
  //               new Image.asset('assets/images/google.png',
  //                   height: SizeConfig.blockSizeVertical * 4),
  //               new Container(
  //                   padding: EdgeInsets.only(left: 10.0, right: 10.0),
  //                   child: new Text(
  //                     "Sign in with Google",
  //                     style: TextStyle(
  //                         color: appColor, fontWeight: FontWeight.bold),
  //                   )),
  //             ],
  //           ),
  //         )),
  //   );
  // }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      setState(() {
        isLoading = true;
      });
      FirebaseMessaging.instance.getToken().then((token) async {
        print(token);
        final response =
            await client.post(Uri.parse('${baseUrl()}/login'), body: {
          "email": emailController.text,
          "password": passwordController.text,
          "device_token": token,
        });
        print('*****************' + token + '*****************');

        if (response.statusCode == 200) {
          setState(() {
            isLoading = false;
          });
          Map<String, dynamic> dic = json.decode(response.body);
          print(response.body);

          if (dic['response_code'] == "1") {
            String userResponseStr = json.encode(dic);
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            preferences.setString(
                SharedPreferencesKey.LOGGED_IN_USERRDATA, userResponseStr);

            print("PRINT DIC>>>>>>>>>>>>> $dic");
            // Loader().hideIndicator(context);
            setState(() {
              isLoading = false;
            });
            Navigator.of(context).pushReplacementNamed('/Pages', arguments: 0);

            // Navigator.of(context).pushAndRemoveUntil(
            //   MaterialPageRoute(
            //     builder: (context) => BottomTabbar(),
            //   ),
            //   (Route<dynamic> route) => false,
            // );
          } else {
            // Loader().hideIndicator(context);
            setState(() {
              isLoading = false;
            });
            toast("Error", "Wrong Email / Phone Number, Please try agains",
                context);
          }
        } else {
          // Loader().hideIndicator(context);
          setState(() {
            isLoading = false;
          });
          toast("Error", "Cannot communicate with server", context);
        }
      });

      // final response = await client.post('${baseUrl()}/login', body: {
      //   "phone": emailController.text,
      //   "password": passwordController.text
      // });

    } catch (e) {
      setState(() {
        isLoading = false;
      });
      toast("Error", e.toString(), context);
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        emailNode.unfocus();
        passwordNode.unfocus();
        isLoading = true;
      });
      signInWithGoogle(context).whenComplete(() {
        setState(() {
          isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      toast("Error", 'Failed to sign in with Google: $e', context);
    }
  }
}
