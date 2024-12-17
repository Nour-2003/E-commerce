import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobileproject/Cubit/Shop/Shop%20Cubit.dart';
import 'package:mobileproject/Cubit/Shop/Shop%20States.dart';
import 'package:mobileproject/Cubit/Theme/Theme%20Cubit.dart';
import 'package:mobileproject/Models/Product%20Model.dart';

import '../../Shared/Constants.dart';
import 'Category Screen.dart';
import 'Product Details Screen.dart';
class HomePage extends StatelessWidget {
  // final List<String> images = [
  List Data = [];

  List categories = [];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShopCubit, ShopStates>(
      listener: (context, state) {
        if (state is ProductUpdatedSuccessState) {
          ShopCubit.get(context).getData();
        }
      },
      builder: (context, state) {
        var cubit = ShopCubit.get(context);
        var data = cubit.firebaseProducts;
        var categories = cubit.firebaseCategories;
        print("Fire Base Data Here " + data.length.toString());

        return Scaffold(
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text('Categories',
                      style: GoogleFonts.montserrat(
                          fontSize: 25, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  ConditionalBuilder(
                    condition: categories.isNotEmpty,
                    fallback: (context) => Center(
                      child: CircularProgressIndicator(
                        color: defaultcolor,
                      ),
                    ),
                    builder: (context) {
                      return Container(
                        height: 100,
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) => GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => CategoryScreen(
                                        role: cubit.userData?['role'],
                                        categoryName: categories[index]['name'],
                                      ),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        const begin = Offset(1.0, 0.0); // Start from right
                                        const end = Offset.zero; // End at the current position
                                        const curve = Curves.easeInOut; // Smooth curve

                                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                        var offsetAnimation = animation.drive(tween);

                                        return SlideTransition(
                                          position: offsetAnimation,
                                          child: child,
                                        );
                                      },
                                    )
                                ).then((_) {
                                  cubit.selectCategory('');
                                });
                              },
                              onLongPress: () async {
                                // Check if the user is an admin
                                if (cubit.userData?['role'] == 'admin') {
                                  // Show a confirmation dialog
                                  bool confirmDelete = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: ThemeCubit.get(context).themebool?Colors.grey[800]:Colors.white,
                                      title: Text('Delete Category',style: GoogleFonts.montserrat(
                                        color: ThemeCubit.get(context).themebool?Colors.white:Colors.black
                                      ),),
                                      content: Text(
                                          'Are you sure you want to delete the ${categories[index]['name']} category and all associated data? This action cannot be undone.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: Text('Delete', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmDelete == true) {
                                    try {
                                      // Get the collection name
                                      String collectionName = categories[index]['name'];

                                      // 1. Delete all documents in the category's collection
                                      final collectionRef =
                                      FirebaseFirestore.instance.collection(collectionName);

                                      final querySnapshot = await collectionRef.get();
                                      for (var doc in querySnapshot.docs) {
                                        await doc.reference.delete();
                                      }

                                      // 2. Delete the category entry from the 'Categories' collection
                                      final categoriesCollection =
                                      FirebaseFirestore.instance.collection('Categories');
                                      await categoriesCollection
                                          .where('name', isEqualTo: collectionName)
                                          .limit(1)
                                          .get()
                                          .then((querySnapshot) {
                                        if (querySnapshot.docs.isNotEmpty) {
                                          querySnapshot.docs.first.reference.delete();
                                        }
                                      });

                                      // 3. Remove the category from the UI
                                      categories.removeAt(index);
                                      cubit.emit(ProductsUpdatedState()); // Rebuild UI

                                      // Show success message
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '$collectionName category and deleted successfully.'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } catch (error) {
                                      // Handle errors
                                      print('Error deleting category: $error');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Failed to delete category and associated data.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                } else {
                                  // Non-admins get a warning or no action
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('You do not have permission to delete categories.'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              },
                              child: Stack(
                                children: [
                                  // Image Container with enhanced shadow and animation
                                  ClipRRect(
                                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.15),
                                            spreadRadius: 1,
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Hero(
                                        tag: 'category_${categories[index]['name']}',
                                        child: (categories[index]['imageUrl'] != null &&
                                            categories[index]['imageUrl'].isNotEmpty)
                                            ? FadeInImage.assetNetwork(
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          placeholder: "Images/Animation - 1734121167586.gif",
                                          image: categories[index]['imageUrl'],
                                          imageErrorBuilder: (context, error, stackTrace) =>
                                              Image.asset("Images/placeholder.png"),
                                          fadeInDuration: const Duration(milliseconds: 300),
                                          fadeInCurve: Curves.easeInOut,
                                        )
                                            : Image.asset(
                                          "Images/placeholder.png",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Enhanced gradient overlay
                                  Positioned.fill(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.7),
                                          ],
                                          stops: const [0.5, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Enhanced text container
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      child: Text(
                                        categories[index]['name'],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            const Shadow(
                                              offset: Offset(0, 1),
                                              blurRadius: 2,
                                              color: Colors.black26,
                                            ),
                                          ],
                                          letterSpacing: 0.3,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            separatorBuilder: (context, index) =>
                              const SizedBox(width: 10),
                          itemCount: categories.length,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 25),
                  Text('Top Products:',
                      style: GoogleFonts.montserrat(
                          fontSize: 25, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  ConditionalBuilder(
                    condition: data.isNotEmpty,
                    fallback: (context) => Center(
                      child: CircularProgressIndicator(
                        color: defaultcolor,
                      ),
                    ),
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: GridView.count(
                            shrinkWrap: true,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.48,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            children: List.generate(data.length, (index) {
                              return GestureDetector(
                                onTap: () {
                                  String role =
                                      cubit.userData?['role'] ?? 'user';
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => ProductDetails(
                                        role: role,
                                        productId: data[index].id,
                                        title: data[index]['title'],
                                        imageUrl: data[index]['imageUrl'],
                                        description: data[index]['description'],
                                        price: data[index]['price'],
                                        rating: data[index]['rating'],
                                        reviews: data[index]['count'],
                                        category: data[index]['category'],
                                      ),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        const begin = Offset(0.0, 1.0); // Start from bottom
                                        const end = Offset.zero;
                                        const curve = Curves.easeInOut;

                                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                        var offsetAnimation = animation.drive(tween);

                                        return SlideTransition(
                                          position: offsetAnimation,
                                          child: FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          ),
                                        );
                                      },

                                    ),
                                  ).then((_) {
                                    cubit.getData();
                                  });

                                },
                                onLongPress: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        content: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          constraints: const BoxConstraints(
                                            maxHeight: 400,
                                          ),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  child: (data[index][
                                                                  'imageUrl'] !=
                                                              null &&
                                                          data[index]
                                                                  ['imageUrl']
                                                              .isNotEmpty)
                                                      ? FadeInImage
                                                          .assetNetwork(
                                                          height: 200,
                                                          width:
                                                              double.infinity,
                                                          fit: BoxFit.fill,
                                                          placeholder:
                                                              "Images/Animation - 1734121167586.gif",
                                                          image: data[index]
                                                              ['imageUrl'],
                                                          imageErrorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            // Show placeholder if the image fails to load
                                                            return Image.asset(
                                                                "Images/placeholder.png");
                                                          },
                                                        )
                                                      : Image.asset(
                                                          "Images/placeholder.png"),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  "Category: ${data[index]['category']}",
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 14,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  "Price: \$${data[index]['price']}",
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  "Rating: ${data[index]['rating']} (${data[index]['count']} reviews)",
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 14,
                                                    color: Colors.amber,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  data[index]['description'],
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 14,
                                                    color: Colors.grey[800],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              "Close",
                                              style: GoogleFonts.montserrat(
                                                fontSize: 14,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child:Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Enhanced Image Container
                                      Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              spreadRadius: 1,
                                              blurRadius: 5,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15),
                                          ),
                                          child: Stack(
                                            children: [
                                              (data[index]['imageUrl'] != null && data[index]['imageUrl'].isNotEmpty)
                                                  ? FadeInImage.assetNetwork(
                                                height: 180, // Slightly increased height
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                placeholder: "Images/Animation - 1734121167586.gif",
                                                image: data[index]['imageUrl'],
                                                imageErrorBuilder: (context, error, stackTrace) {
                                                  return Image.asset(
                                                    "Images/placeholder.png",
                                                    height: 180,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                  );
                                                },
                                              )
                                                  : Image.asset(
                                                "Images/placeholder.png",
                                                height: 180,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              ),
                                              // Add a subtle gradient overlay
                                              Positioned.fill(
                                                child: DecoratedBox(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                      colors: [
                                                        Colors.transparent,
                                                        Colors.black.withOpacity(0.2),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Enhanced Content Container
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(15),
                                            bottomRight: Radius.circular(15),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              spreadRadius: 1,
                                              blurRadius: 5,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Title with enhanced typography
                                              Text(
                                                "${data[index]['title']}",
                                                maxLines: 2,
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  height: 1.2,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              // Category with pill background
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  "${data[index]['category']}",
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 13,
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              // Price and Admin Actions Row
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    // Enhanced price display
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Text(
                                                        "\$${data[index]['price']}",
                                                        style: GoogleFonts.montserrat(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.blue,
                                                        ),
                                                      ),
                                                    ),
                                                    // Admin delete button with enhanced styling
                                                    if (cubit.userData?['role'] == 'admin')
                                                      Material(
                                                        color: Colors.red.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(20),
                                                        child: InkWell(
                                                          onTap: () {
                                                            AwesomeDialog(
                                                              context: context,
                                                              dialogType: DialogType.warning,
                                                              headerAnimationLoop: false,
                                                              animType: AnimType.bottomSlide,
                                                              title: 'Are you sure?',
                                                              desc: 'Do you really want to delete this product? This action cannot be undone.',
                                                              btnCancelOnPress: () {},
                                                              btnOkOnPress: () async {
                                                                await FirebaseFirestore.instance
                                                                    .collection('Products')
                                                                    .doc(data[index].id)
                                                                    .get()
                                                                    .then((docSnapshot) {
                                                                  if (docSnapshot.exists) {
                                                                    String category = docSnapshot.data()?['category'];
                                                                    String title = docSnapshot.data()?['title'];

                                                                    CollectionReference categoryCollection = FirebaseFirestore.instance.collection(category);
                                                                    categoryCollection
                                                                        .where('title', isEqualTo: title)
                                                                        .get()
                                                                        .then((querySnapshot) {
                                                                      if (querySnapshot.docs.isNotEmpty) {
                                                                        categoryCollection.doc(querySnapshot.docs.first.id).delete();
                                                                        print("Deleted categorized product with title '$title' from $category collection.");
                                                                      } else {
                                                                        print("No matching product found with title '$title' in $category collection.");
                                                                      }

                                                                      FirebaseFirestore.instance.collection('Products').doc(data[index].id).delete();
                                                                      print("Deleted product with title '$title' from 'Products' collection.");
                                                                      cubit.getData();
                                                                    })
                                                                        .catchError((error) {
                                                                      print("Failed to delete categorized product with title '$title': $error");
                                                                    });
                                                                  } else {
                                                                    print("Product not found in 'Products' collection.");
                                                                  }
                                                                })
                                                                    .catchError((error) {
                                                                  print("Failed to find product in 'Products' collection: $error");
                                                                });
                                                              },
                                                              btnOkColor: Colors.red,
                                                              titleTextStyle: GoogleFonts.montserrat(
                                                                fontSize: 20,
                                                                fontWeight: FontWeight.bold,
                                                                color: ThemeCubit.get(context).themebool ? Colors.white : Colors.black,
                                                              ),
                                                              descTextStyle: GoogleFonts.montserrat(
                                                                fontSize: 17,
                                                                fontWeight: FontWeight.bold,
                                                                color: ThemeCubit.get(context).themebool ? Colors.white : Colors.black,
                                                              ),
                                                              dialogBackgroundColor: ThemeCubit.get(context).themebool ? Colors.grey[800] : Colors.white,
                                                              btnOkText: 'Delete',
                                                              btnCancelText: 'Cancel',
                                                            ).show();
                                                          },
                                                          borderRadius: BorderRadius.circular(20),
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(8),
                                                            child: Icon(
                                                              Icons.delete_outline,
                                                              color: Colors.red,
                                                              size: 22,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    else
                                                      Container()
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              // Enhanced Rating Display
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.amber.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Row(
                                                            children: List.generate(
                                                              5,
                                                                  (starIndex) => Icon(
                                                                starIndex < double.parse(data[index]['rating'])
                                                                    ? Icons.star_rounded
                                                                    : Icons.star_outline_rounded,
                                                                color: Colors.amber,
                                                                size: 18,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 5),
                                                          Text(
                                                            "${data[index]['rating']}",
                                                            style: GoogleFonts.montserrat(
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.amber[800],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                  ,
                                ),
                              );
                            }),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}