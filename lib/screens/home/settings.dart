import 'package:flutter/material.dart';
import 'package:gets_it_done/models/user.dart';
import 'package:gets_it_done/screens/task_screens/categoryadder.dart';
import 'package:gets_it_done/screens/task_screens/taskadder.dart';
import 'package:gets_it_done/services/auth.dart';
import 'package:gets_it_done/services/database.dart';
import 'package:gets_it_done/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:gets_it_done/shared/color_theme.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  dynamic user;
  DatabaseCalls _db;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      user = Provider.of<User>(context);
      setPreferences(user);
      _isLoading = false;
    });
  }

  void setPreferences(user) async {
    _db = DatabaseCalls();
    dynamic preferences = await _db.getPreferences(user.uid);

    setState(() {
      colorScheme = preferences["colorScheme"];
      speechToText = preferences["speechToText"];
      taskAssistant = preferences["taskAssistant"];
    });
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
          MaterialPageRoute(builder: (context) => TaskAdder()),
        );
      }
      if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CategoryAdder()),
        );
      }
    });
  }

  // Inputs
  dynamic colorScheme = '';
  bool speechToText;
  bool taskAssistant;
  // Loading page
  bool _isLoading = true;
  // Error handling
  String message = '';

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();

    return _isLoading
        ? Loading()
        : Theme(
            data: getColorTheme(colorScheme),
            child: _isLoading
                ? Loading()
                : Scaffold(
                    appBar: AppBar(
                      elevation: 0.0,
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () async {
                            await _auth.logOffUser();

                            Navigator.pushNamedAndRemoveUntil(
                                context, '/', (_) => false);
                          },
                          child: Text('log off'),
                        ),
                      ],
                      title: Text('Settings'),
                    ),
                    body: Container(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 30.0,
                          ),
                          Text(
                            'Color Scheme',
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              RaisedButton(
                                onPressed: () {
                                  setState(() {
                                    colorScheme = '1';
                                  });
                                },
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(50.0),
                                ),
                                color: colorScheme == '1'
                                    ? Colors.black
                                    : getColorTheme(colorScheme).primaryColor,
                                elevation: 0.0,
                                child: Text(
                                  '1',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              RaisedButton(
                                onPressed: () {
                                  setState(() {
                                    colorScheme = '2';
                                  });
                                },
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(50.0),
                                ),
                                color: colorScheme == '2'
                                    ? Colors.black
                                    : Colors.teal[300],
                                elevation: 0.0,
                                child: Text(
                                  '2',
                                  style: TextStyle(color: Colors.blue[800]),
                                ),
                              ),
                              RaisedButton(
                                onPressed: () {
                                  setState(() {
                                    colorScheme = '3';
                                  });
                                },
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(50.0),
                                ),
                                color: colorScheme == '3'
                                    ? Colors.black
                                    : Colors.deepOrangeAccent[100],
                                elevation: 0.0,
                                child: Text(
                                  '3',
                                  style: TextStyle(color: Colors.yellow[300]),
                                ),
                              ),
                              RaisedButton(
                                onPressed: () {
                                  setState(() {
                                    colorScheme = '4';
                                  });
                                },
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(50.0),
                                ),
                                color: colorScheme == '4'
                                    ? Colors.black
                                    : Colors.deepPurple,
                                elevation: 0.0,
                                child: Text(
                                  '4',
                                  style: TextStyle(color: Colors.green[200]),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            'Speech to text',
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              ButtonTheme(
                                minWidth: 150.0,
                                child: RaisedButton(
                                  onPressed: () {
                                    setState(() {
                                      speechToText = true;
                                    });
                                  },
                                  shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(50.0),
                                  ),
                                  color: speechToText == true
                                      ? Colors.black
                                      : getColorTheme(colorScheme).primaryColor,
                                  elevation: 0.0,
                                  child: Text(
                                    'On',
                                  ),
                                ),
                              ),
                              ButtonTheme(
                                minWidth: 150.0,
                                child: RaisedButton(
                                  onPressed: () {
                                    setState(() {
                                      speechToText = false;
                                    });
                                  },
                                  shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(50.0),
                                  ),
                                  color: speechToText == false
                                      ? Colors.black
                                      : getColorTheme(colorScheme).primaryColor,
                                  elevation: 0.0,
                                  child: Text(
                                    'Off',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            'Task assistant',
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              ButtonTheme(
                                minWidth: 150.0,
                                child: RaisedButton(
                                  onPressed: () {
                                    setState(() {
                                      taskAssistant = true;
                                    });
                                  },
                                  shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(50.0),
                                  ),
                                  color: taskAssistant == true
                                      ? Colors.black
                                      : getColorTheme(colorScheme).primaryColor,
                                  elevation: 0.0,
                                  child: Text(
                                    'On',
                                  ),
                                ),
                              ),
                              ButtonTheme(
                                minWidth: 150.0,
                                child: RaisedButton(
                                  onPressed: () {
                                    setState(() {
                                      taskAssistant = false;
                                    });
                                  },
                                  shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(50.0),
                                  ),
                                  color: taskAssistant == false
                                      ? Colors.black
                                      : getColorTheme(colorScheme).primaryColor,
                                  elevation: 0.0,
                                  child: Text(
                                    'Off',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 40.0,
                          ),
                          ButtonTheme(
                            minWidth: 250.0,
                            height: 50.0,
                            child: RaisedButton(
                              onPressed: () {
                                final result = _db.updatePreferences(user.uid,
                                    colorScheme, speechToText, taskAssistant);

                                if (result["status"] == 200) {
                                  setState(() {
                                    message = 'Preferences updated successful';
                                  });

                                  Future.delayed(Duration(milliseconds: 800),
                                      () {
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, '/home', (_) => false);
                                  });
                                }
                              },
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(50.0),
                              ),
                              elevation: 2.0,
                              child: Text(
                                'Finish',
                              ),
                              color: getColorTheme(colorScheme).primaryColor,
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            message,
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0),
                          ),
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
                            title: Text('Task'),
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.add),
                            title: Text('Category'),
                          ),
                        ],
                        onTap: _navigatePage,
                      ),
                    ),
                  ),
          );
  }
}
