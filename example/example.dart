import 'package:captcha_flutter/captcha_flutter.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: '腾讯图形验证码demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  String ticketStr = "";
  String captchaID= "从腾讯图形验证码获取的ID";

  void _incrementCounter() {
    Captcha.showCaptchaWebView(context, (ticket, randStr) {
      setState(() {
        if(ticket.isEmpty){
          ticketStr = "用户手动关闭";
        }else{
          ticketStr = "ticket：$ticket,randStr：$randStr";
        }
      });
    },error: (errorStr){
      setState(() {
        ticketStr = "出现失败";
      });
    });
  }

  @override
  void initState() {
    super.initState();
    Captcha.initCaptcha(captchaID,enableDarkMode: "false");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '显示获取成功的ticket和randStr',
            ),
            Text(
              ticketStr,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        child: const Text("验证码"),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
