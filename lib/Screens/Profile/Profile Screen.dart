
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobileproject/Cubit/Shop/Shop%20Cubit.dart';
import 'package:mobileproject/Cubit/Shop/Shop%20States.dart';

import 'package:mobileproject/Shared/Constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Cubit/Theme/Theme Cubit.dart';
import '../../Cubit/Theme/Theme States.dart';
import '../Home/OnBoarding Screen.dart';

class ProfileScreen extends StatelessWidget {
  // final String name = "Nour Eldin Hesham";
  // final String email = "noureldean@gmail.com";
  // final String phone = "01203299971";


  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return BlocConsumer<ShopCubit, ShopStates>(
      listener: (context, state) {},
      builder: (context, state) {
        print(ShopCubit.get(context).userData);
        return Scaffold(
          // appBar: AppBar(
          //   title: Text(
          //     'Profile',
          //     style: GoogleFonts.montserrat(
          //       fontSize: 24,
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          //   centerTitle: true,
          //   elevation: 0,
          // ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Profile Picture Section
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black.withOpacity(0.5)
                              : Colors.grey.withOpacity(0.5),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'Images/Profile.jpg',
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      )
                    ),
                  ),
                  const SizedBox(height: 20),
                  // User Details Section
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.person, color: Colors.blue),
                            title: Text(
                              ShopCubit.get(context).userData?['name'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Divider(color: Colors.grey.shade300),
                          ListTile(
                            leading: Icon(Icons.email, color: Colors.green),
                            title: Text(
                              ShopCubit.get(context).userData?['email'],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Divider(color: Colors.grey.shade300),
                          ListTile(
                            leading: Icon(Icons.phone, color: Colors.orange),
                            title: Text(
                              ShopCubit.get(context).userData?['phone'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Dark Mode Toggle Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Dark Mode",
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      BlocBuilder<ThemeCubit, AppStates>(
                        builder: (context, state) => Switch(
                          value: ThemeCubit.get(context).themebool,
                          activeColor: Colors.blue,
                          onChanged: (value) {
                            ThemeCubit.get(context).changeThemeMode();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                // Sign-Out Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shadowColor: Colors.redAccent,
                        elevation: 5,
                      ),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();

                        // Clear shared preferences
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.remove('rememberMe');
                        prefs.remove('email');
                        prefs.remove('password');

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => OnBoardingScreen()),
                        );
                      },
                      child: Text(
                        "Sign Out",
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}

