import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobileproject/Screens/Main%20Screen.dart';
import '../Cubit/Login/Login Cubit.dart';
import '../Cubit/Login/Login States.dart';
import '../Cubit/Theme/Theme Cubit.dart';
import '../Shared/Constants.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final confirmController = TextEditingController();
  final dateController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF00B96D),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('MMM dd, yyyy').format(picked);
      });
    }
  }

  CollectionReference Users = FirebaseFirestore.instance.collection('Users');

  Future<void> addUser() {
    // Call the user's CollectionReference to add a new user
    return Users.add({
      'name': nameController.text, // John Doe
      'email': emailController.text, // Stokes and Sons
      'phone': phoneController.text, // 42
      'dateOfBirth': dateController.text, // 42// 42
      'role': 'user'
    })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => Shoplogincubit(),
      child: BlocConsumer<Shoplogincubit, LoginStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            body: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Register',
                          style: GoogleFonts.montserrat(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Register now to browse our hot offers',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 20),
                        defaultTextFormField(
                          isDark: ThemeCubit.get(context).themebool,
                          textController: nameController,
                          label: 'Name',
                          prefixIcon: Icon(Icons.person),
                          type: TextInputType.text,
                          Validator: (value) {
                            if (value!.isEmpty) {
                              return 'Name must not be empty';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        defaultTextFormField(
                          isDark: ThemeCubit.get(context).themebool,
                          textController: emailController,
                          prefixIcon: Icon(Icons.email_outlined),
                          label: 'Email',
                          type: TextInputType.emailAddress,
                          Validator: (value) {
                            if (value!.isEmpty) {
                              return 'Email must not be empty';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        defaultTextFormField(
                          isDark: ThemeCubit.get(context).themebool,
                          onSubmit: (value) {},
                          textController: passwordController,
                          prefixIcon: Icon(Icons.lock),
                          label: 'Password',
                          suffixIcon: IconButton(
                            onPressed: () {
                              Shoplogincubit.get(context)
                                  .changeSignupPasswordVisibility();
                            },
                            icon: Shoplogincubit.get(context)
                                    .signupPasswordObscure
                                ? Icon(Icons.visibility_off)
                                : Icon(Icons.visibility),
                          ),
                          obscureText:
                              Shoplogincubit.get(context).signupPasswordObscure,
                          type: TextInputType.visiblePassword,
                          Validator: (value) {
                            if (value!.isEmpty) {
                              return 'Password is too short';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        defaultTextFormField(
                          isDark: ThemeCubit.get(context).themebool,
                          onSubmit: (value) {},
                          textController: confirmController,
                          prefixIcon: Icon(Icons.lock),
                          label: 'Confirm Password',
                          suffixIcon: IconButton(
                            onPressed: () {
                              Shoplogincubit.get(context)
                                  .changeSignupConfirmPasswordVisibility();
                            },
                            icon: Shoplogincubit.get(context)
                                    .signupConfirmPasswordObscure
                                ? Icon(Icons.visibility_off)
                                : Icon(Icons.visibility),
                          ),
                          obscureText: Shoplogincubit.get(context)
                              .signupConfirmPasswordObscure,
                          type: TextInputType.visiblePassword,
                          Validator: (value) {
                            if (value!.isEmpty) {
                              return 'Password is too short';
                            } else if (passwordController.text != value) {
                              return 'Password is not matched';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        defaultTextFormField(
                          isDark: ThemeCubit.get(context).themebool,
                          textController: phoneController,
                          label: 'Phone',
                          prefixIcon: Icon(Icons.phone),
                          type: TextInputType.number,
                          Validator: (value) {
                            if (value!.isEmpty) {
                              return 'Phone must not be empty';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          style: TextStyle(
                            color: ThemeCubit.get(context).themebool
                                ? Colors.white
                                : Colors.black,
                          ),
                          controller: dateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Date of Birth',
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          onTap: () => _selectDate(context),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Date of birth must not be empty';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });
                                try {
                                  final credential = await FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );
                                  addUser();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MainScreen(),
                                    ),
                                  );
                                } on FirebaseAuthException catch (e) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  if (e.code == 'weak-password') {
                                    print('The password provided is too weak.');
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.error,
                                      animType: AnimType.rightSlide,
                                      title: 'Sign up Error',
                                      titleTextStyle: GoogleFonts.montserrat(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeCubit.get(context).themebool
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      descTextStyle: GoogleFonts.montserrat(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeCubit.get(context).themebool
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      dialogBackgroundColor:
                                          ThemeCubit.get(context).themebool
                                              ? Colors.grey[800]
                                              : Colors.white,
                                      desc:
                                          'The password provided is too weak.',
                                    )..show();
                                  } else if (e.code == 'email-already-in-use') {
                                    print(
                                        'The account already exists for that email.');
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.error,
                                      animType: AnimType.rightSlide,
                                      title: 'Dialog Title',
                                      titleTextStyle: GoogleFonts.montserrat(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeCubit.get(context).themebool
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      descTextStyle: GoogleFonts.montserrat(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeCubit.get(context).themebool
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      dialogBackgroundColor:
                                          ThemeCubit.get(context).themebool
                                              ? Colors.grey[800]
                                              : Colors.white,
                                      desc:
                                          'The account already exists for that email.',
                                    )..show();
                                  } else if (e.code == 'invalid-email') {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.error,
                                      animType: AnimType.rightSlide,
                                      title: 'Sign up Error',
                                      titleTextStyle: GoogleFonts.montserrat(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeCubit.get(context).themebool
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      descTextStyle: GoogleFonts.montserrat(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeCubit.get(context).themebool
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      dialogBackgroundColor:
                                          ThemeCubit.get(context).themebool
                                              ? Colors.grey[800]
                                              : Colors.white,
                                      desc: 'Wrong Email Format',
                                    )..show();
                                  }
                                } catch (e) {
                                  print(e);
                                }
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                Color(0xFF00B96D),
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              padding: MaterialStateProperty.all(
                                EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                              ),
                            ),
                            child: isLoading
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
