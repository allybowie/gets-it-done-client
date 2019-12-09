import 'package:flutter/material.dart';
import 'package:gets_it_done/models/user.dart';
import 'package:gets_it_done/screens/home/settings.dart';
import 'package:gets_it_done/services/auth.dart';
import 'package:gets_it_done/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:gets_it_done/services/database.dart';

class TaskAdder extends StatefulWidget {
  @override
  _TaskAdderState createState() => _TaskAdderState();
}

class _TaskAdderState extends State<TaskAdder> {
  dynamic _user;
  DatabaseCalls _db;
  // Speech to Text
  SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;
  String resultText = '';

  @override
  void initState() {
    super.initState();
    initSpeechRecognitizer();

    Future.delayed(Duration.zero, () {
      _user = Provider.of<User>(context);
      setCategories(_user);
    });
  }

  void setCategories(user) async {
    _db = DatabaseCalls();

    dynamic categories = await _db.getCategories(user.uid);
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  void initSpeechRecognitizer() {
    _speechRecognition = SpeechRecognition();

    _speechRecognition.setAvailabilityHandler(
      (bool result) => setState(() => _isAvailable = result),
    );

    _speechRecognition.setRecognitionStartedHandler(
      () => setState(() => _isListening = true),
    );

    _speechRecognition.setRecognitionResultHandler(
      (String speech) => setState(() => resultText = speech),
    );

    _speechRecognition.setRecognitionCompleteHandler(
      () => setState(() => _isListening = false),
    );

    _speechRecognition.activate().then(
          (result) => setState(() => _isAvailable = result),
        );
  }

  // Bottom nav bar navigation
  void _navigatePage(int index) {
    setState(() {
      if (index == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Settings()),
        );
      }
      if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Settings()),
        );
      }
    });
  }

  // Inputs
  // String taskBody;
  String priority = "today";
  String categoryDropdown = "general";
  String message = "";

  dynamic dueDate;

  // Color Scheme
  final bgColor = const Color(0xFFb4c2f3);
  final textColor = const Color(0xFFffffff);
  final altBgColor = const Color(0xFFe96dae);

  // Categories
  List<dynamic> _categories;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();

    return _isLoading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text('Gets It Done'),
              backgroundColor: altBgColor,
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    'Log Off',
                    style: TextStyle(color: textColor, fontSize: 18.0),
                  ),
                  onPressed: () async {
                    await _auth.logOffUser();
                    Navigator.pop(context);
                  },
                )
              ],
            ),
            backgroundColor: bgColor,
            body: Form(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 50.0,
                  ),
                  TextFormField(
                    controller: TextEditingController(text: resultText),
                    onChanged: (text) {
                      setState(() {
                        resultText = text;
                        print(resultText);
                      });
                    },
                    style: TextStyle(
                      fontSize: 20,
                    ),
                    validator: (value) =>
                        value.isEmpty ? 'Please write your task.' : null,
                    decoration: InputDecoration(
                        labelText: 'Task',
                        hintText: 'Please enter task.',
                        fillColor: Colors.white,
                        filled: true),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FloatingActionButton(
                        heroTag: 'stop',
                        mini: true,
                        backgroundColor: altBgColor,
                        onPressed: () {
                          if (_isListening) {
                            _speechRecognition.stop().then(
                                  (result) =>
                                      setState(() => _isListening = result),
                                );
                          }
                        },
                        child: Icon(Icons.stop),
                      ),
                      FloatingActionButton(
                        heroTag: 'record',
                        onPressed: () {
                          if (_isAvailable && !_isListening) {
                            _speechRecognition
                                .listen(locale: "en_US")
                                .then((result) => print(result));
                          }
                        },
                        child: Icon(Icons.mic),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text("Priority"),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      RaisedButton(
                          onPressed: () {
                            setState(() {
                              priority = "today";
                              // Add 24 hours to current time
                              dynamic timestamp = new DateTime.now()
                                  .add(new Duration(days: 1))
                                  .millisecondsSinceEpoch;
                              dueDate = timestamp;
                              print(timestamp);
                            });
                          },
                          color:
                              priority == "today" ? altBgColor : Colors.white,
                          child: Text("Today")),
                      RaisedButton(
                          onPressed: () {
                            setState(() {
                              priority = "tomorrow";
                              // Add 48 hours to current time
                              dynamic timestamp = new DateTime.now()
                                  .add(new Duration(days: 2))
                                  .millisecondsSinceEpoch;
                              dueDate = timestamp;
                              print(timestamp);
                            });
                          },
                          color: priority == "tomorrow"
                              ? altBgColor
                              : Colors.white,
                          child: Text("Tomorrow")),
                      RaisedButton(
                          onPressed: () {
                            setState(() {
                              priority = "later";
                              // Add 7 days to task
                              dynamic timestamp = new DateTime.now()
                                  .add(new Duration(days: 7))
                                  .millisecondsSinceEpoch;
                              dueDate = timestamp;
                              print(timestamp + 604800000);
                            });
                          },
                          color:
                              priority == "later" ? altBgColor : Colors.white,
                          child: Text("Later"))
                    ],
                  ),
                  SizedBox(
                    height: 40.0,
                  ),
                  Text("Category"),
                  SizedBox(
                    height: 20.0,
                  ),
                  DropdownButton<String>(
                    value: categoryDropdown.length == 0
                        ? "Please select text"
                        : categoryDropdown,
                    isExpanded: false,
                    underline: Container(
                      height: 2,
                      color: altBgColor,
                    ),
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    onChanged: (String newValue) {
                      setState(() {
                        categoryDropdown = newValue;
                        print(categoryDropdown);
                      });
                    },
                    items: _categories
                        .map<DropdownMenuItem<String>>((dynamic value) {
                      return DropdownMenuItem<String>(
                          child: Text(value), value: value);
                    }).toList(),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  RaisedButton(
                      onPressed: ()async {
                      _db.addTask(_user.uid, categoryDropdown, resultText);
                      Navigator.pop(context);
                      },
                      color: altBgColor,
                      child: Text("Submit")),
                      Text(message)
                ],
              ),
            ),
            bottomNavigationBar: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Colors.pink[300],
                primaryColor: Colors.white,
                textTheme: Theme.of(context).textTheme.copyWith(
                      caption: new TextStyle(color: Colors.white),
                    ),
              ),
              child: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.done),
                    title: Text('Do Task'),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    title: Text('Settings'),
                  ),
                ],
                onTap: _navigatePage,
              ),
            ),
          );
  }
}
