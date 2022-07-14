import 'dart:convert';

///工具类
class Utils{
  ///html转换成base64格式
  static String getBase64Url(String srcHtml){
    final String contentBase64 = base64Encode(const Utf8Encoder().convert(srcHtml));
    return 'data:text/html;base64,$contentBase64';
  }
}