import 'dart:io' show Platform, exit;

import 'package:cobo/common/Const.dart';
import 'package:cobo/common/utils.dart';
import 'package:cobo/webview_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WebViewPage(
          title: Constants.TITLE_COBO_HOLDING,
          url: Constants.URL_COBO_HOLDING,
          isShowAppBar: true),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage() : super();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  WebViewController controller;
  List<String> urls = [];
  String title;
  final flutterWebViewPlugin = FlutterWebviewPlugin();

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (urls.length == 1) {
      return (await showDialog(
            context: context,
            builder: (context) => new AlertDialog(
              title: new Text('Are you sure?'),
              content: new Text('Do you want to exit an App'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: new Text('No'),
                ),
                TextButton(
                  onPressed: () => {Navigator.of(context).pop(true)},
                  child: new Text('Yes'),
                ),
              ],
            ),
          )) ??
          false;
    } else {
      if (controller != null) {
        urls.removeLast();
        print("WillPop: ${urls.length}");
        controller.loadUrl(urls.last);
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();

    // urls.clear();
    // urls.add(Constants.URL_COBO_HOLDING);
    // print("urls.length = ${urls.length}}");
    // return WillPopScope(
    //     onWillPop: _onWillPop,
    //     child: Scaffold(
    //       appBar: AppBar(
    //         automaticallyImplyLeading: false,
    //         title: Row(
    //             mainAxisAlignment: MainAxisAlignment.start,
    //             crossAxisAlignment: CrossAxisAlignment.center,
    //             children: <Widget>[
    //               AbsorbPointer(
    //                 absorbing: urls.length == 1,
    //                 child: IconButton(
    //                   icon: Icon(Icons.navigate_before),
    //                   color: urls.length == 1 ? Colors.grey : Colors.black87,
    //                   onPressed: () => urls.length == 1 ? null : _onWillPop(),
    //                 ),
    //               ),
    //               IconButton(
    //                   icon: Icon(Icons.navigate_next),
    //                   color: Colors.black87,
    //                   onPressed: () => {}),
    //               IconButton(
    //                   icon: Icon(Icons.history),
    //                   color: Colors.black87,
    //                   onPressed: () => {}),
    //               Text(
    //                 "Cobo Holding",
    //                 style: TextStyles.simpleTextStyle.copyWith(
    //                   fontWeight: FontWeight.bold,
    //                   fontSize: 18,
    //                 ),
    //                 maxLines: 1,
    //               ),
    //             ]),
    //         centerTitle: true,
    //         backgroundColor: Colors.white,
    //       ),
    //       body: Stack(
    //         children: _buildBody(),
    //       ),
    //     ));
  }

  List<Widget> _buildBody() {
    return [
      WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: urls[0],
          onWebViewCreated: (controller) {
            this.controller = controller;
          },
          onPageStarted: (url) {
            print("New url: $url");
            List<String> temp = [];
            temp.addAll(urls);

            bool isExists = false;
            temp.forEach((element) {
              if (element == url) {
                isExists = true;
              }
            });
            if (!isExists) {
              temp.add(url);
              setState(() {
                urls = temp;
              });
            }
          }),
    ];
  }

  bool isLauchUrlIOS = true;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("didChangeAppLifecycleState $state");
    if (Platform.isAndroid) {
      if (state == AppLifecycleState.paused) {
        SystemNavigator.pop();
      }
    }

    if (Platform.isIOS) {
      if (state == AppLifecycleState.inactive) {
        isLauchUrlIOS = false;
      }
      if (state == AppLifecycleState.resumed) {
        if (isLauchUrlIOS) {
          launchURL(context, Constants.URL_COBO_HOLDING);
        }
      }
    }
  }
}
