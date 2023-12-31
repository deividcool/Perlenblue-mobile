import 'package:snapta/global/global.dart';
import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';

class WebViewContainer extends StatefulWidget {
  final url;

  WebViewContainer(this.url);

  @override
  createState() => _WebViewContainerState(this.url);
}

class _WebViewContainerState extends State<WebViewContainer> {
  var _url;
  final _key = UniqueKey();
  var scaffoldKey = GlobalKey<ScaffoldState>();

  _WebViewContainerState(this._url);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: appColor,
          elevation: 1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: appColorBlack),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            Expanded(
                child: WebView(
                    key: _key,
                    javascriptMode: JavascriptMode.unrestricted,
                    initialUrl: _url)),
          ],
        ));
  }
}
