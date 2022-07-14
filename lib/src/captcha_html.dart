///存放Html相关代码
class CaptchaHtml {
  ///获取参数信息
  static String getParams(String captchaID,
      {String language = "zh",
      bool needFeedBack = false,
      String enableDarkMode = "false"}) {
    return """loadCaptcha(
{"width": 0,"height": 0,"lang": "$language","captchaId": "$captchaID","needFeedBack":"$needFeedBack","enableDarkMode":"$enableDarkMode"}
) """;
  }

  ///图形验证码的本地file内容
  static String getCaptchaHtml(double scale, bool isShow,
      {double bgOpacity = 0.5, String bgColor = "#000000"}) {
    String maskStr = "";
    if (isShow) {
      maskStr = """#t_mask{opacity:$bgOpacity;background:$bgColor}""";
    } else {
      maskStr = """#t_mask{background:#00000000}""";
    }

    return """
  <html>
  <head>
      <meta name="viewport" content="width=device-width,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no">
       <!--整体view缩放,遮罩颜色为透明  <style>#tcaptcha_transform{transform:scale(1)}#t_mask{opacity:0;background:#00000000}</style>-->
      <style>#tcaptcha_transform{transform:scale($scale)}$maskStr</style>
      <script type="text/javascript">
      function loadCaptcha(param){
              var res = param;
              try {
                var sdkOptions = {"sdkOpts": {"width":res.width, "height": res.height}};
                sdkOptions.ready = function (retJson) {
                    if (retJson && retJson.sdkView && retJson.sdkView.width && retJson.sdkView.height &&  parseInt(retJson.sdkView.width) >0 && parseInt(retJson.sdkView.height) >0 ){
                       var result = { width:retJson.sdkView.width, height:retJson.sdkView.height };
                       CaptchaInit.postMessage(JSON.stringify(result));
                    }
                };
                sdkOptions.enableDarkMode = res.enableDarkMode;
                sdkOptions.userLanguage = res.lang;
                sdkOptions.needFeedBack = res.needFeedBack;
                new TencentCaptcha(res.captchaId, function (res) {
                    CaptchaSuccess.postMessage(JSON.stringify(res));
                },sdkOptions).show();
              } catch (error) {
                  CaptchaError.postMessage(JSON.stringify(error));
              }
      }
      </script>
  </head>
  <body>
  <script src="https://ssl.captcha.qq.com/TCaptcha.js"></script>
  </body>
  </html>
  """;
  }
}
