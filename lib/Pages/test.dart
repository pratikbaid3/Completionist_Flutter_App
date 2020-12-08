import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Html(
        data: """
        <div class="text_res">I have linked a video for&nbsp; quick reference to this. The location of&nbsp; this is in the Upper West Side district where you will find a Stan Lee statue you can interact with. Press&nbsp;<img alt="triangle.png" src="https://www.playstationtrophies.org/images/icons/controller/triangle.png">&nbsp;when prompted.<br><div class="vid-resp"><iframe data-src="https://www.youtube-nocookie.com/embed/oMVJbkUXeds" class=" lazyloaded" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen=""></iframe></div><span style="color:#2980b9;"><strong>Credit Credit Powerpyx for the video.</strong></span></div>
      """,
        onLinkTap: (url) {
          // open url in a webview
        },
        onImageTap: (src) {
          // Display the image in large form.
        },
      ),
    );
  }
}
