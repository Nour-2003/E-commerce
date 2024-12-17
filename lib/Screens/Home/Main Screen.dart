import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobileproject/Cubit/Shop/Shop%20States.dart';
import '../../Cubit/Shop/Shop Cubit.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => ShopCubit()
        ..getData()
        ..getUserByEmail(FirebaseAuth.instance.currentUser!.email!)
        ..getCategories()
        ..getCartData(),
      child: BlocConsumer<ShopCubit, ShopStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = ShopCubit.get(context);
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(cubit.userData?['role'] == 'admin'
                  ? cubit.adminTitles[cubit.currentIndex]
                  : cubit.titles[cubit.currentIndex]),
            ),
            body: cubit.userData?['role'] == 'admin'
                ? cubit.adminScreens[cubit.currentIndex]
                : cubit.screens[cubit.currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              elevation: 10,
              items: cubit.userData?['role'] == 'admin'
                  ? [
                      BottomNavigationBarItem(
                          icon: Icon(Icons.home), label: 'Home'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.search), label: 'Search'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.admin_panel_settings),
                          label: 'Admin Panel'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.person), label: 'Profile'),
                    ]
                  : [
                      BottomNavigationBarItem(
                          icon: Icon(Icons.home), label: 'Home'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.search), label: 'Search'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.shopping_cart), label: 'Cart'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.person), label: 'Profile'),
                    ],
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeBottomNav(index);
              },
            ),
          );
        },
      ),
    );
  }
}
