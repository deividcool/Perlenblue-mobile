import 'dart:async';
import 'package:snapta/Helper/sizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:snapta/layouts/user/login.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => new SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  var _visible = true;

  AnimationController animationController;
  Animation<double> animation;

  startTime() async {
    var _duration = new Duration(seconds: 3);
    return new Timer(_duration, navigationPage);
  }

  // void navigationPage() {
  //   Navigator.of(context).pushReplacementNamed(APP_SCREEN);
  // }

  void navigationPage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Login()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
        vsync: this, duration: new Duration(seconds: 4));
    animation =
        new CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    animation.addListener(() => this.setState(() {}));
    animationController.forward();

    setState(() {
      _visible = !_visible;
    });
    startTime();

    // new Timer(new Duration(milliseconds: 3000), () {
    //   checkFirstSeen();
    // });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Container(
        color: Colors.black,
        height: SizeConfig.screenHeight,
        width: SizeConfig.screenWidth,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/snaptaIcon.png',
                  height: 100,
                  width: 100,
                ),
                SizedBox(
                  height: 10,
                ),
                Text('Snapta',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'BrushScript',
                        fontSize: SizeConfig.blockSizeHorizontal * 12.5)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
