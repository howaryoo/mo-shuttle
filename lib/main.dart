import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:tts/tts.dart';
import 'package:speech_recognition/speech_recognition.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Shuttlebot',
      theme: new ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: new MyHomePage(title: 'ShuttleBot'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

/* https://github.com/VictorRancesCode/flutter_dialogflow/blob/master/example/lib/main.dart */

class _MyHomePageState extends State<MyHomePage> {

  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = new TextEditingController();
  var _speech;
  bool _speechRecognitionAvailable;
  String _currentLocale;
  bool _isListening;
  String transcription;

  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration:
                new InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: () => _handleSubmitted(_textController.text)),
            ),
          ],
        ),
      ),
    );
  }

  void Response(query) async {
    _textController.clear();
    // TODO update credentials here
    AuthGoogle authGoogle = await AuthGoogle(fileJson: "assets/fuseteam3-1c284d1e865d.json").build();
    Dialogflow dialogflow = Dialogflow(authGoogle: authGoogle, language: Language.ENGLISH);
    AIResponse response = await dialogflow.detectIntent(query);

    ChatMessage message = new ChatMessage(
      text: response.getMessage(),
      name: "ShuttleBot",
      type: false,
    );
    Tts.speak(response.getMessage());
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    ChatMessage message = new ChatMessage(
      text: text,
      name: "Me",
      type: true,
    );
    setState(() {
      _messages.insert(0, message);
    });
    Response(text);
  }

  void _handleFabClick(){
    print("_handleFabClick: pressed");
    _speech = SpeechRecognition();

// The flutter app not only call methods on the host platform,
// it also needs to receive method calls from host.
    _speech.setAvailabilityHandler((bool result)
    => setState(() => _speechRecognitionAvailable = result));

// handle device current locale detection
    _speech.setCurrentLocaleHandler((String locale) =>
        setState((){
          print("current locale: $locale");
            _currentLocale = locale;
        }));

    _speech.setRecognitionStartedHandler(() => setState((){
      _isListening = true;
      print("csetRecognitionStartedHandler: isListening $_isListening");
    });

// this handler will be called during recognition.
// the iOS API sends intermediate results,
// On my Android device, only the final transcription is received
    _speech.setRecognitionResultHandler((String text) => setState((){
          print("setRecognitionResultHandler: $text");
          transcription = text;
    }));

    _speech.setRecognitionCompleteHandler(() => setState((){
    _isListening = false;
    } ));

// 1st launch : speech recognition permission / initialization
    _speech.activate().then((res) => setState(() => _speechRecognitionAvailable = res));

    _speech.listen(locale:_currentLocale).then((result)=>
        print('result : $result')
    );

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      floatingActionButton: Container(
        padding: EdgeInsets.only(bottom: 50.0, right: 25),
        child: Stack(children: <Widget>[
          FloatingActionButton(onPressed: _handleFabClick, child: Icon(Icons.keyboard_voice))
          ]
      )
      ),
      body: new Column(children: <Widget>[
        new Flexible(
            child: new ListView.builder(
              padding: new EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
            )),
        new Divider(height: 1.0),
        new Container(
          decoration: new BoxDecoration(color: Theme.of(context).cardColor),
          child: _buildTextComposer(),
        ),
      ]),
    );
  }

  @override
  void initState() {
    super.initState();
//    _getSavedWeightNote();
  }

  Future<double> _getSavedWeightNote() async {
    String sharedData = await const MethodChannel('app.channel.shared.data')
        .invokeMethod("getSavedNote");
    print("_getSavedWeightNote: $sharedData");

    if (sharedData != null) {
      int firstIndex = sharedData.indexOf(new RegExp("[0-9]"));
      int lastIndex = sharedData.lastIndexOf(new RegExp("[0-9]"));
      if (firstIndex != -1) {
        String number = sharedData.substring(firstIndex, lastIndex + 1);
        double num = double.parse(number, (error) => null);
        return num;
      }
    }
    return null;
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage({this.text, this.name, this.type});

  final String text;
  final String name;
  final bool type;

  List<Widget> otherMessage(context) {
    return <Widget>[
      new Container(
        margin: const EdgeInsets.only(right: 16.0),
//        child: new CircleAvatar(child: new Image.asset("img/placeholder.png")),
      ),
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(this.name, style:new TextStyle(fontWeight:FontWeight.bold )),
            new Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: new Text(text),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> myMessage(context) {
    return <Widget>[
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            new Text(this.name, style: Theme.of(context).textTheme.subhead),
            new Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: new Text(text),
            ),
          ],
        ),
      ),
      new Container(
        margin: const EdgeInsets.only(left: 16.0),
        child: new CircleAvatar(child: new Text(this.name[0])),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: this.type ? myMessage(context) : otherMessage(context),
      ),
    );
  }
}
