import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../Login-SignUp/Login Screen.dart';

class OnBoardingScreen extends StatefulWidget {
  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  var boardController = PageController();
  bool islast = false;

  List<OnBoardingModel> onBoarding = [
    OnBoardingModel(
      image: 'Images/Digital_Shopping-transformed.png',
      title: 'Purchase Online',
      body: 'Easily browse and shop for your favorite items from the comfort of your home.',
    ),
    OnBoardingModel(
      image: 'Images/Digital_Shopping_(1)-transformed.png',
      title: 'Track Your Order',
      body: 'Monitor the status of your order and get real-time updates on its delivery.',
    ),
    OnBoardingModel(
      image: 'Images/Online Shopping.png',
      title: 'Get Your Order',
      body: 'Receive your order at your doorstep, hassle-free and on time.',
    ),

  ];

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        // backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
            child: Text(
              'SKIP',
              style: TextStyle(fontSize: 20,color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(  // Wrap the whole body with SingleChildScrollView to make it scrollable
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05), // 5% of the screen width for padding
          child: Column(
            children: [
              SizedBox(
                height: screenHeight * 0.8, // Make sure the content has space for the page indicator
                child: PageView.builder(
                  onPageChanged: (index) {
                    setState(() {
                      islast = index == onBoarding.length - 1;
                    });
                  },
                  controller: boardController,
                  itemBuilder: (context, index) => OnBoardingItem(onBoarding[index], screenWidth, screenHeight),
                  itemCount: 3,
                ),
              ),
              Row(
                children: [
                  SmoothPageIndicator(
                    controller: boardController,
                    count: onBoarding.length,
                    effect: ExpandingDotsEffect(
                      dotColor: Colors.grey,
                      activeDotColor: Color(0xFF00B96D),
                      dotHeight: 15,
                      expansionFactor: 3,
                      dotWidth: 15,
                      spacing: 5.0,
                    ),
                  ),
                  Spacer(),
                  FloatingActionButton(
                    backgroundColor: Color(0xFF00B96D),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    onPressed: () {
                      if (islast) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                      }
                      boardController.nextPage(
                        duration: Duration(microseconds: 750),
                        curve: Curves.fastLinearToSlowEaseIn,
                      );
                    },
                    child: Icon(Icons.arrow_forward_ios_sharp, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget OnBoardingItem(OnBoardingModel model, double screenWidth, double screenHeight) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.1), // 10% vertical space
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(model.image, width: screenWidth * 0.8), // Adjust image size based on screen width
        ),
      ),
      SizedBox(height: screenHeight * 0.01), // Add space between the image and text
      Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Text(
          model.title,
          style: GoogleFonts.montserrat(fontSize: screenWidth * 0.07, fontWeight: FontWeight.bold), // Adjust font size based on screen width
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Text(
          model.body,
          style: GoogleFonts.montserrat(fontSize: screenWidth * 0.04), // Adjust font size based on screen width
        ),
      ),
    ],
  );
}

class OnBoardingModel {
  final String image;
  final String title;
  final String body;

  OnBoardingModel({required this.image, required this.title, required this.body});
}
