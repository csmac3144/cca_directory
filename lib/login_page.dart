import 'package:flutter/material.dart';
import 'package:cca_directory/auth.dart';
import 'package:cca_directory/simple.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.auth, this.onSignedIn});
  final AuthImpl auth;
  final VoidCallback onSignedIn;
  
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

enum FormMode { SIGNIN, SIGNUP}

class _LoginPageState extends State<LoginPage> {
  final formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  FormMode _formMode = FormMode.SIGNIN;

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        if (_formMode == FormMode.SIGNIN) {
          try {
            String userId =
                await widget.auth.signIn(_email, _password);
            print('Signed in: $userId');
            
          } catch (e) {
            _showDialog(e.message);
            return;
          }
        } else {
          String userId = await widget.auth
              .signUp(_email, _password);
          print('Signed up user: $userId');
        }
        widget.onSignedIn();
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void _signUp() {
    formKey.currentState.reset();
    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }

  void _signIn() {
    formKey.currentState.reset();
    setState(() {
      _formMode = FormMode.SIGNIN;
    });
  }


  void _showDialog(String alertMessage) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Error"),
          content: new Text(alertMessage,style: TextStyle(
                      color: Colors.red,
                    )),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Flutter login demo'),
        ),
        body: new Container(
            padding: EdgeInsets.all(16.0),
            child: new Form(
              key: formKey,
              child: new ListView(
                shrinkWrap: true,
                children: <Widget>[
                  _sizedBox(50.0),
                  _logo(),
                  _sizedBox(100.0),
                  _emailInput(),
                  _sizedBox(15.0),
                  _passwordInput(),
                  _sizedBox(30.0),
                  _submitButton(),
                  _label(),
                ],
              ),
            )));
  }

  Widget _logo() {
    return new Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/flutter-icon.png'),
      ),
    );
  }

  Widget _sizedBox(_height) {
    return new SizedBox(height: _height);
  }

  Widget _emailInput() {
    return new TextFormField(
          keyboardType: TextInputType.emailAddress,
          autofocus: false,
          decoration: new InputDecoration(
              hintText: 'Email',
              icon: new Icon(
                Icons.mail,
                color: Colors.grey,
              )),
          validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
          onSaved: (value) => _email = value,
        );
  }

  Widget _passwordInput() {
    return new TextFormField(
          obscureText: true,
          autofocus: false,
          decoration: new InputDecoration(
              hintText: 'Password',
              icon: new Icon(
                Icons.lock,
                color: Colors.grey,
              )),
          validator: (value) =>
              value.isEmpty ? 'Password can\'t be empty' : null,
          onSaved: (value) => _password = value,
        );
  }

  Widget _label() {
    if (_formMode == FormMode.SIGNIN) {
      return
        new FlatButton(
          child: new Text('Create an account',
              style:
                  new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
          onPressed: _signUp,
        );
    } else {
      return
        new FlatButton(
          child: new Text('Have an account? Sign in',
              style:
                  new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
          onPressed: _signIn,
        );
    }
  }
  Widget _submitButton() {
    if (_formMode == FormMode.SIGNIN) {
      return
        new Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: new Material(
                borderRadius: BorderRadius.circular(30.0),
                shadowColor: Colors.blueAccent.shade100,
                elevation: 5.0,
                color: Colors.blue,
                child: new MaterialButton(
                  minWidth: 200.0,
                  height: 42.0,
                  child: new Text('Login',
                      style:
                          new TextStyle(fontSize: 20.0, color: Colors.white)),
                  onPressed: validateAndSubmit,
                )));
    } else {
      return 
        new Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: new Material(
                borderRadius: BorderRadius.circular(30.0),
                shadowColor: Colors.lightBlueAccent.shade100,
                elevation: 5.0,
                color: Colors.blue,
                child: new MaterialButton(
                  minWidth: 200.0,
                  height: 42.0,
                  child: new Text('Create account',
                      style:
                          new TextStyle(fontSize: 20.0, color: Colors.white)),
                  onPressed: validateAndSubmit,
                )));
    }
  }
}
