import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'captcha_html.dart';
import 'utils.dart';

///图形验证码
class Captcha{
  ///需要更改id图形验证码
  static String _captchaId = "";
  ///可以配置语言：https://cloud.tencent.com/document/product/1110/36841#userLanguage
  static String _userLanguage = "zh";
  //开启自适应深夜模式, 'force'将强制深夜模式。经过验证不能强制设置白天模式；
  static String _enableDarkMode = "false";
  ///隐藏帮助按钮
  static bool _needShowFeedBack = false;
  ///是否显示背景颜色
  static bool _isShowBG = true;
  ///验证码框的缩放值，必须在0-1之间
  static double _viewScale = 0.9;

  ///控制是否显示webView
  static OverlayEntry? _overlayEntry;
  ///控制加载js
  static WebViewController? _mWebViewController;

  ///初始化验证码，captchaID：腾讯图形验证码ID
  static void initCaptcha(String captchaID,{String userLanguage = "zh",bool needFeedBack = false,double viewScale = 0.9,bool isShowMask = true,String enableDarkMode = "false"}){
    _captchaId = captchaID;
    _userLanguage = userLanguage;
    _needShowFeedBack = needFeedBack;
    _viewScale = viewScale;
    _isShowBG = isShowMask;
    _enableDarkMode = enableDarkMode;
  }

  ///显示图形验证码
  static void showCaptchaWebView(BuildContext context,CaptchaCallback callBack,{CaptchaCallError? error}){
    try{
      _overlayEntry= OverlayEntry(builder: (context) {
        return _getWebView(callBack,error);
      });
      if(_overlayEntry != null){
        Overlay.of(context)?.insert(_overlayEntry!);
      }
    }catch(e){
      _webViewError(e.toString(),error);
    }
  }

  ///加载webView的图形验证码
  static Widget _getWebView(CaptchaCallback callBack,CaptchaCallError? error){
    String htmlStr = Utils.getBase64Url(CaptchaHtml.getCaptchaHtml(_viewScale,_isShowBG));
    return WebView(
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        _mWebViewController = webViewController;
        //加载图形验证码
        _mWebViewController?.loadUrl(htmlStr);
      },
      javascriptChannels: <JavascriptChannel>{
        ///验证码初始化
        JavascriptChannel(
            name: 'CaptchaInit',
            onMessageReceived: (JavascriptMessage message) {
              //真正显示出验证码view,之前是loading
              // Map<String, dynamic> data = json.decode(message.message);
              //print("真正显示出验证码view："+data.toString());
            }),
        ///加载成功并回调
        JavascriptChannel(
            name: 'CaptchaSuccess',
            onMessageReceived: (JavascriptMessage message) {
              closeWebView();
              Map<String, dynamic> data = json.decode(message.message);
              //只有成功才回调出去,手动关闭直接消失
              if(data["ret"] == 0){
                callBack(data["ticket"],data["randstr"]);
              }else{
                callBack("","");
              }
            }),
        /// 加载失败并回调
        JavascriptChannel(
            name: 'CaptchaError',
            onMessageReceived: (JavascriptMessage message) {
              Map<String, dynamic> data = json.decode(message.message);

              //出错了,关闭WebView，回调出去
              _webViewError(data.toString(),error);
            }),
      },
      onPageFinished: (String url) {
        if(url == htmlStr){
          try{
            _mWebViewController?.runJavascript(CaptchaHtml.getParams(_captchaId,language: _userLanguage,needFeedBack:_needShowFeedBack,enableDarkMode: _enableDarkMode));
          }catch(e){
            _webViewError(e.toString(),error);
          }
        }
      },
      onWebResourceError: (error) {
        _mWebViewController?.reload();
      },
      // navigationDelegate: (NavigationRequest request) {
      //   print('$request}');
      //   return NavigationDecision.navigate;
      // },
      gestureNavigationEnabled: true,
      backgroundColor: const Color(0x00000000),
    );
  }

  ///图形验证码出现错误
  static void _webViewError(String errorStr,CaptchaCallError? error){
    closeWebView();
    if(error != null){
      error(errorStr);
    }
  }
  ///关闭图形验证码
  static void closeWebView(){
    _overlayEntry?.remove();
    _overlayEntry = null;
    _mWebViewController = null;
  }

}

//调用验证码成功回调
typedef CaptchaCallback = void Function(String ticket,String randStr);//限定参数和返回值

//调用验证码失败回调
typedef CaptchaCallError = void Function(String error);