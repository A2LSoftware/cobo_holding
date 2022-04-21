import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';

launchURL(BuildContext context, String url) async {
  FlutterWebBrowser.openWebPage(
    url: url,
    customTabsOptions: CustomTabsOptions(
      colorScheme: CustomTabsColorScheme.light,
      toolbarColor: Colors.white,
      secondaryToolbarColor: Colors.white,
      navigationBarColor: Colors.white,
      addDefaultShareMenuItem: true,
      instantAppsEnabled: true,
      showTitle: true,
      urlBarHidingEnabled: true,
    ),
    safariVCOptions: SafariViewControllerOptions(
      barCollapsingEnabled: true,
      preferredBarTintColor: Colors.white,
      preferredControlTintColor: Colors.black,
      dismissButtonStyle: null,
      modalPresentationCapturesStatusBarAppearance: true,
    ),
  );
}
