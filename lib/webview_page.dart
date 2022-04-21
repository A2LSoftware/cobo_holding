import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'common/TextStyles.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage(
      {Key key,
      @required this.title,
      @required this.url,
      this.isShowInBottomSheet: false,
      this.isShowAppBar: false})
      : super(key: key);

  final String title;
  final String url;
  final bool isShowInBottomSheet;
  final bool isShowAppBar;

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage>
    with TickerProviderStateMixin {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  bool isCanForward = false;
  bool isCanGoBack = false;

  bool isShowWebView = false;

  AnimationController controller;

  bool isLoadFinish = false;

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    controller = AnimationController(
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    if (widget.isShowInBottomSheet) {
      // Delay for bottom sheet animation
      Future.delayed(const Duration(milliseconds: 400), () {
        setState(() {
          isShowWebView = true;
        });
      });
    } else {
      setState(() {
        isShowWebView = true;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
        future: _controller.future,
        builder: (context, snapshot) {
          return WillPopScope(
            onWillPop: () async {
              if (snapshot.hasData) {
                var canGoBack = await snapshot.data.canGoBack();
                if (canGoBack) {
                  await snapshot.data.goBack();
                  return Future.value(false);
                }
              }
              return Future.value(true);
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: widget.isShowAppBar
                  ? AppBar(
                      centerTitle: true,
                      title: Text(
                        widget.title,
                        style: TextStyles.simpleTextStyle
                            .copyWith(fontSize: 18)
                            .copyWith(color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                      // leading: CloseButton(
                      //   color: Colors.black,
                      //   onPressed: () {
                      //     Navigator.of(context).pop(true);
                      //   },
                      // ),
                      backgroundColor: Colors.white,
                    )
                  : null,
              body: isShowWebView
                  ? Column(
                      children: [
                        isLoadFinish
                            ? const SizedBox.shrink()
                            : LinearProgressIndicator(
                                value: controller.value,
                              ),
                        Expanded(
                          child: CustomScrollView(
                            slivers: [
                              SliverFillRemaining(
                                child: Container(
                                  child: WebView(
                                    gestureRecognizers: [
                                      Factory(() =>
                                          PlatformViewVerticalGestureRecognizer()),
                                    ].toSet(),
                                    initialUrl: widget.url,
                                    javascriptMode: JavascriptMode.unrestricted,
                                    onProgress: (progress) {
                                      controller.value =
                                          (progress / 100.0).toDouble();
                                      isLoadFinish = false;
                                      if (progress == 100) {
                                        isLoadFinish = true;
                                      }
                                    },
                                    userAgent: Platform.isAndroid
                                        ? 'Mozilla/5.0 (Linux; Android 5.1.1; Nexus 5 Build/LMY48B; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/43.0.2357.65 Mobile Safari/537.36'
                                        : null,
                                    onPageFinished: (_) async {
                                      var canGoForward =
                                          await snapshot?.data?.canGoForward();
                                      var canGoBack =
                                          await snapshot?.data?.canGoBack();

                                      setState(() {
                                        isCanForward = canGoForward;
                                        isCanGoBack = canGoBack;
                                      });
                                    },
                                    onWebViewCreated: (
                                      WebViewController webViewController,
                                    ) {
                                      _controller.complete(webViewController);
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: isCanGoBack == true
                                    ? () async {
                                        await snapshot?.data?.goBack();
                                      }
                                    : null,
                                icon: Icon(Icons.arrow_back),
                              ),
                              IconButton(
                                onPressed: isCanForward == true
                                    ? () async {
                                        await snapshot?.data?.goForward();
                                      }
                                    : null,
                                icon: Icon(
                                  Icons.arrow_forward,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await snapshot?.data?.reload();
                                },
                                icon: Icon(Icons.refresh),
                              )
                            ],
                          ),
                        )
                      ],
                    )
                  : SizedBox.shrink(),
            ),
          );
        });
  }
}

class PlatformViewVerticalGestureRecognizer
    extends VerticalDragGestureRecognizer {
  PlatformViewVerticalGestureRecognizer({PointerDeviceKind kind})
      : super(kind: kind);

  Offset _dragDistance = Offset.zero;

  @override
  void addPointer(PointerEvent event) {
    startTrackingPointer(event.pointer);
  }

  @override
  void handleEvent(PointerEvent event) {
    _dragDistance = _dragDistance + event.delta;
    if (event is PointerMoveEvent) {
      final double dy = _dragDistance.dy.abs();
      final double dx = _dragDistance.dx.abs();

      if (dy > dx && dy > kTouchSlop) {
        // vertical drag - accept
        resolve(GestureDisposition.accepted);
        _dragDistance = Offset.zero;
      } else if (dx > kTouchSlop && dx > dy) {
        resolve(GestureDisposition.accepted);
        // horizontal drag - stop tracking
        stopTrackingPointer(event.pointer);
        _dragDistance = Offset.zero;
      }
    }
  }

  @override
  String get debugDescription => 'Horizontal drag (platform view)';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}
