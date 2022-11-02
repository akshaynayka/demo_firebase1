import '../../values/app_routes.dart';
import '../../values/colors.dart';
import '../../widgets/restart_app_widget.dart';

import '../../common_methods/common_methods.dart';
import '../../common_methods/field_validator.dart';
import '../../values/string_en.dart';
import '../../widgets/round_button_widget.dart';
import '../../widgets/text_form_field_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _auth = FirebaseAuth.instance;
  final Map<String, String?> _userData = {
    'name': '',
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  var _passwordVisible = false;
  var _isInit = true;
  String? _userType;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments as String?;
      _userType = args;
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  Future<void> _submitAuthform() async {
    // UserCredential authResult;
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    try {
      setState(() {
        _isLoading = true;
      });

      await _auth
          .signInWithEmailAndPassword(
              email: _userData['email']!, password: _userData['password']!)
          .then((value) {
        RestartAppWidget.restartApp(context);
      });
    } on PlatformException catch (error) {
      setState(() {
        _isLoading = false;
      });
      var message = 'An error occurred, please check your credentials';
      if (error.message != null) {
        message = error.message!;
      }
      displaySnackbar(context: context, msg: message);
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      var message = 'An error occurred, please check your credentials';

      displaySnackbar(context: context, msg: message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 280,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(100),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            appColorPrimary,
                            appColorPrimary,
                            // appColorSecondGradient,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Container(
                          height: 110.0,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3.0,
                              )),
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                    ),
                     Positioned(
                      bottom: 35.0,
                      right: 40.0,
                      child: Text(
                        appTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 70,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextFormFieldWidget(
                    icon: Icons.email_outlined,
                    lableText: appTitleEmail,
                    validator: requiredEmailValidator,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (value) {
                      _userData['email'] = removeSpaceFromString(value!);
                    },
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: StatefulBuilder(builder: (context, setWidgetState) {
                    return TextFormFieldWidget(
                      icon: Icons.vpn_key,
                      lableText: appTitlePassword,
                      validator: nameValidator,
                      obscureText: !_passwordVisible,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (value) {
                        _submitAuthform();
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Based on passwordVisible state choose the icon
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          // color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () {
                          // Update the state i.e. toogle the state of passwordVisible variable
                          setWidgetState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                      onSaved: (value) {
                        _userData['password'] = value;
                      },
                    );
                  }),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  width: double.infinity,
                  alignment: Alignment.centerRight,
                  child: const Text(
                    appTitleForgotPassword,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Material(
                    elevation: 15.0,
                    borderRadius: BorderRadius.circular(25.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.0),
                        gradient: const LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: <Color>[
                            appColorPrimary,
                            appColorPrimary,
                            // appColorSecondGradient,
                          ],
                        ),
                      ),
                      height: 50.0,
                      width: double.infinity,
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : RoundButtonWidget(
                              label: appTitleLogin,
                              onPressed: _submitAuthform,
                            ),
                    ),
                  ),
                ),
                // ElevatedButton(
                //     onPressed: () async {
                //       final FirebaseAuth auth = FirebaseAuth.instance;

                //       GoogleSignInAccount? userSignin;

                //       final GoogleSignIn googleSignIn =
                //           GoogleSignIn(scopes: <String>["email"]);
                //       userSignin = await googleSignIn.signIn();
                //       final authntication = await userSignin?.authentication;
                //       OAuthCredential? credential;
                //       credential = GoogleAuthProvider.credential(
                //           idToken: authntication!.idToken,
                //           accessToken: authntication.accessToken);

                //       await auth.signInWithCredential(credential);
                //     },
                //     child: Text('Google Login')),
                const SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      appTitleDontHaveAnAccount,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      child: Text(
                        appTitleRegister,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          appRouteRegisterScreen,
                          arguments: _userType,
                        );
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
