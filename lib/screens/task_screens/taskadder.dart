import 'package:flutter/material.dart';
import 'package:gets_it_done/models/user.dart';
import 'package:gets_it_done/screens/home/settings.dart';
import 'package:gets_it_done/screens/task_screens/categoryadder.dart';
import 'package:gets_it_done/screens/task_screens/task_assistant.dart';
import 'package:gets_it_done/services/auth.dart';
import 'package:gets_it_done/shared/color_theme.dart';
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

  String err = "";
  bool taskAssistant;
  bool isSmallEnough = false;

  @override
  void initState() {
    super.initState();
    initSpeechRecognitizer();

    Future.delayed(Duration.zero, () {
      _user = Provider.of<User>(context);
      setCategories(_user);
      getUserPreferences(_user);
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

  getUserPreferences(user) async {
    _db = DatabaseCalls();
    dynamic preferences = await _db.getPreferences(user.uid);

    setState(() {
      colorScheme = preferences["colorScheme"];
      speechToText = preferences["speechToText"];
      taskAssistant = preferences["taskAssistant"];
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
      (String speech) {
        resultText = speech;
      },
    );

    _speechRecognition.setRecognitionCompleteHandler(
      () => setState(() => _isListening = false),
    );

    _speechRecognition.activate().then(
          (result) => setState(() => _isAvailable = result),
        );

    setState(() => _isAvailable = false);
  }

  // Bottom nav bar navigation
  void _navigatePage(int index) {
    setState(() {
      if (index == 0) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      }
      if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CategoryAdder()),
        );
      }
      if (index == 2) {
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
  dynamic colorScheme = '';
  dynamic speechToText = true;

  // Categories
  List<dynamic> _categories;
  bool _isLoading = true;

  //slider
  double rating = 0;
  var labelObj = {
    0.0: "< 5mins",
    30.0: "5-15 mins",
    60.0: "15-45 mins",
    90.0: "45+ mins"
  };

  var taskLengthObj = {0.0: 0, 30.0: 1, 60.0: 2, 90.0: 3};

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();

    void _showTaskAssistant() {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Center(
              child: Container(
                padding:
                    EdgeInsets.symmetric(vertical: 100.0, horizontal: 40.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      'We have noticed that your task description is quite long. Could this be broken down into smaller tasks?',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    FlatButton(
                      color: getColorTheme(colorScheme).primaryColor,
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskAssistant(),
                          ),
                        );
                      },
                      child: Text('Learn more about breaking tasks up.'),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Text(
                      'Are you happy to add the task?',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    FlatButton(
                      color: getColorTheme(colorScheme).primaryColor,
                      onPressed: () {
                        setState(() {
                          isSmallEnough = true;
                        });
                        Navigator.pop(context);
                        err = 'Please submit to add task.';
                      },
                      child: Text('Sure am!'),
                    )
                  ],
                ),
              ),
            );
          });
    }

    return _isLoading
        ? Loading()
        : Theme(
            data: getColorTheme(colorScheme) ?? ThemeData.dark(),
            child: Scaffold(
              appBar: AppBar(
                title: Text('Gets It Done'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Log Off'),
                    onPressed: () async {
                      await _auth.logOffUser();

                      Navigator.pushNamedAndRemoveUntil(
                          context, '/', (_) => false);
                    },
                  )
                ],
              ),
              body: Form(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 50.0,
                    ),
                    TextFormField(
                      controller: new TextEditingController.fromValue(
                          new TextEditingValue(
                              text: resultText,
                              selection: new TextSelection.collapsed(
                                  offset: resultText.length))),
                      onChanged: (text) {
                        setState(() {
                          resultText = text;
                        });
                      },
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                          labelText: 'Task',
                          hintText: 'Add a task here!',
                          fillColor: Colors.white,
                          filled: true),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    speechToText
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              FloatingActionButton(
                                heroTag: 'record',
                                onPressed: () {
                                  if (_isAvailable && !_isListening) {
                                    _speechRecognition
                                        .listen(locale: "en_US")
                                        .then((result) => print(result));
                                  }
                                },
                                backgroundColor:
                                    getColorTheme(colorScheme).primaryColor,
                                child: Icon(Icons.mic),
                              ),
                            ],
                          )
                        : Text(""),
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
                                // print(dueDate);
                              });
                            },
                            color: priority != "today"
                                ? getColorTheme(colorScheme).primaryColor
                                : getColorTheme(colorScheme).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : Colors.black,
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
                                // print(dueDate);
                              });
                            },
                            color: priority != "tomorrow"
                                ? getColorTheme(colorScheme).primaryColor
                                : getColorTheme(colorScheme).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : Colors.black,
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
                                // print(dueDate);
                              });
                            },
                            color: priority != "later"
                                ? getColorTheme(colorScheme).primaryColor
                                : getColorTheme(colorScheme).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : Colors.black,
                            child: Text("Later"))
                      ],
                    ),
                    Slider(
                      value: rating,
                      onChanged: (newRating) {
                        setState(() {
                          rating = newRating;
                        });
                      },
                      min: 0,
                      max: 90,
                      divisions: 3,
                      label: labelObj[rating],
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
                        color: Colors.black,
                      ),
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      onChanged: (String newValue) {
                        setState(() {
                          categoryDropdown = newValue;
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
                        onPressed: () async {
                          if (resultText.length > 20 &&
                              isSmallEnough == false) {
                            _showTaskAssistant();
                          } else {
                            if (resultText != "") {
                              _db.addTask(_user.uid, categoryDropdown,
                                  resultText, dueDate, taskLengthObj[rating]);

                              setState(() {
                                err = "Task added";
                                isSmallEnough = false;
                              });
                              Future.delayed(Duration(milliseconds: 800), () {
                                setState(() {
                                  err = "";
                                  resultText = "";
                                });
                              });
                            } else {
                              setState(() {
                                err = "Please enter a task";
                                isSmallEnough = false;
                              });
                            }
                          }

                          //Navigator.pop(context);
                        },
                        child: Text("Submit")),
                    Text(
                      err,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    )
                  ],
                ),
              ),
              bottomNavigationBar: new Theme(
                data: Theme.of(context).copyWith(
                  // sets the background color of the `BottomNavigationBar`
                  canvasColor: getColorTheme(colorScheme).primaryColor,
                  // sets the active color of the `BottomNavigationBar` if `Brightness` is light
                  primaryColor: Colors.red,
                  textTheme: Theme.of(context).textTheme.copyWith(
                        caption: new TextStyle(
                          color: Colors.white,
                        ),
                      ),
                ),
                child: BottomNavigationBar(
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.home,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Home',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.add),
                      title: Text('Category'),
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.settings),
                      title: Text('Settings'),
                    ),
                  ],
                  onTap: _navigatePage,
                ),
              ),
            ),
          );
  }
}
