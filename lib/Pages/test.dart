import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

const html = '''
<div class='text_res'><p style='text-align:justify'>While you are unable to shoot, you are still able to use your melee attack to fend off the hordes of zombies. Happily, 6 minutes isn't long enough for any of the more seriously dangerous zombies to appear. Also, there is a handy spot in the top right of the map that can be considered a 'safe spot'. If you wedge yourself into the small corner at this edge of the arena the zombies will have a hard time funnelling their way up to you to do damage. Pair this trophy with <strong>Melee Master</strong> by standing in the safe spot for six minutes and the two trophies will become very easy. Do note though that using this method is not a good way to play long-term so you will want to restart the game after going for these trophies.<br/>
<br/>
To see the safe spot in action, check out the video below:</p>
<p style='text-align:justify'><iframe allowfullscreen='' frameborder='0' height='350' src='https://www.youtube.com/embed/d6huKy-eTps?rel=0' width='632'></iframe></p>
</div>
''';

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 60, horizontal: 30),
        child: SingleChildScrollView(
          child: HtmlWidget(
            // the first parameter (`html`) is required
            html,

            // all other parameters are optional, a few notable params:

            // specify custom styling for an element
            // see supported inline styling below
            customStylesBuilder: (element) {
              if (element.classes.contains('foo')) {
                return {'color': 'red'};
              }

              return null;
            },

            // render a custom widget

            // set the default styling for text
            textStyle: TextStyle(fontSize: 14),

            // By default, `webView` is turned off because additional config
            // must be done for `PlatformView` to work on iOS.
            // https://pub.dev/packages/webview_flutter#ios
            // Make sure you have it configured before using.
            webView: true,
          ),
        ),
      ),
    );
  }
}
