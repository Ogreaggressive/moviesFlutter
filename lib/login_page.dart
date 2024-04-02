import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/login_cubit.dart';
import 'package:local_auth/local_auth.dart';
import 'movies_page.dart';


class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);


  @override
  _LoginFormState createState() => _LoginFormState();
}

enum SupportState {
  unknown,
  supported,
  unSupported,
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _signInKey = GlobalKey();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RegExp emailValid = RegExp(r"^[a-zA-Z0-9.a-zA]");

  final LocalAuthentication auth = LocalAuthentication();
  SupportState supportState = SupportState.unknown;
  List<BiometricType>? availableBiometrics;

  @override
  void initState(){
    auth.isDeviceSupported().then((bool isSupported) =>
        setState(()=> supportState = isSupported ? SupportState.supported : SupportState.unSupported));
    super.initState();
    checkBiometric();
    getAvailableBiometrics();
  }

  Future<void> checkBiometric() async{
    late bool canCheckBiometric;
    try{
      canCheckBiometric = await auth.canCheckBiometrics;
      print("biometric supported: $canCheckBiometric");
    } on PlatformException catch (e){
      print(e);
      canCheckBiometric = false;
    }
  }

  Future<void> getAvailableBiometrics() async {
    late List<BiometricType> biometricTypes;
    try{
      biometricTypes = await auth.getAvailableBiometrics();
      print("supported biometrics $biometricTypes");
    } on PlatformException catch (e){
      print(e);
    }

    if(!mounted){
      return;
    }
    setState(() {
      availableBiometrics = biometricTypes;
    });
  }

  Future<void> authenticateWithBiometrics() async{
    try{
      final authenticated = await auth.authenticate(localizedReason: 'Authenticate with fingerprint',
          options:AuthenticationOptions(
              stickyAuth: true,
              biometricOnly: true
          )
      );
      if(!mounted){
        return;
      }
      if(authenticated){
        MaterialPageRoute(builder: (context) => PopularMovies());
      }
    }on PlatformException catch (e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginCubit = BlocProvider.of<LoginCubit>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio de sesión'),
      ),
      body: Material(
        child: Center(
          child: Form(
            key: _signInKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(15),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'ingrese un email',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                      labelStyle: TextStyle(color: Colors.black),
                      hintStyle: TextStyle(color: Colors.black),
                    ),
                    style: TextStyle(color: Colors.black),
                    validator: (value) {
                      return loginCubit.validateEmail(value!);
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(15),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'ingrese una contrasena',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                      labelStyle: TextStyle(color: Colors.black),
                      hintStyle: TextStyle(color: Colors.black),
                    ),
                    style: TextStyle(color: Colors.black),
                    validator: (value) {
                      return loginCubit.validatePassword(value!);
                    },
                  ),
                ),
                Text(supportState == SupportState.supported
                    ? 'se puede hacer logeo biometrico'
                    : supportState == SupportState.unSupported
                    ? 'no se puede hacer logeo biometrico'
                    : 'viendo si se puede hacer logeo biometrico',

                    style: TextStyle(
                      color: supportState == SupportState.supported
                          ? Colors.green
                          : supportState == SupportState.unSupported
                          ? Colors.red
                          :Colors.grey,
                    )
                ),
                const SizedBox(height: 20),
                Text('Supported biometrics: $availableBiometrics'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fingerprint),
                    ElevatedButton(onPressed: authenticateWithBiometrics, child: Text("Autenticar con logeo biometrico"))
                  ]
                ),

                Container(
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextButton(
                    onPressed: () {
                      if (_signInKey.currentState!.validate()) {
                        final String email = _emailController.text.trim();
                        final String password = _passwordController.text.trim();
                        loginCubit.login(context, email, password);
                      }
                    },
                    child: const Text(
                      "Sign In",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
