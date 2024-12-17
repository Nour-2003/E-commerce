import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../Cubit/Shop/Shop Cubit.dart';
import '../../Cubit/Shop/Shop States.dart';
import '../../Cubit/Theme/Theme Cubit.dart';
import '../../Shared/Constants.dart';
import '../Home/Product Details Screen.dart';
import 'Barcode Screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final textController = TextEditingController();
  final SpeechToText speech = SpeechToText();
  bool speechEnabled = false;
  String lastWords = "";

  @override
  void initState() {
    super.initState();
    initSpeech();
    BlocProvider.of<ShopCubit>(context).loadProducts(ShopCubit.get(context).firebaseProducts);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<ShopCubit>(context).searchProducts('');
    });
  }

  void initSpeech() async {
    speechEnabled = await speech.initialize();
    setState(() {});
  }
//   String barcodeString = "";
//   Future<void> scanBarCodeNormal() async{
//     String ?barcode;
//     try {
//       barcode = await FlutterBarcodeScanner.scanBarcode("#004297", "Cancel", true, ScanMode.BARCODE);
//       print(barcode);
//     } catch (e) {
//       print(e);
//     }
//     if(!mounted)
//       {
//         return;
//       }
//     setState(() {
// barcodeString = barcode!;
//     });
//   }
  void startListening(ShopCubit cubit) async {
    if (speechEnabled) {
      await speech.listen(onResult: onSpeechResult);
      setState(() {});
    }
  }

  void stopListening() async {
    await speech.stop();
    setState(() {
      lastWords = '';
    });
  }

  void onSpeechResult(result) {
    setState(() {
      lastWords = result.recognizedWords.trim(); // Get recognized speech
      textController.text = lastWords; // Update the text field with the speech result
      // Trigger search with the speech input
      BlocProvider.of<ShopCubit>(context).searchProducts(lastWords);
    });
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopCubit, ShopStates>(
      builder: (context, state) {
        var cubit = ShopCubit.get(context);

        return Scaffold(
          // appBar: AppBar(
          //   centerTitle: true,
          //   title: Text('Search Page'),
          // ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: defaultTextFormField(
                          isDark: ThemeCubit.get(context).themebool,
                          textController: textController,
                          label: 'Search',
                          type: TextInputType.text,
                          prefixIcon: Icon(CupertinoIcons.search),
                          Validator: (value) {
                            if (value!.isEmpty) {
                              return 'Search must not be empty';
                            }
                            return null;
                          },
                          onSubmit: (value) {
                            cubit.searchProducts(value);
                          },
                          onChange: (value) {
                            cubit.searchProducts(value);
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: defaultcolor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            speech.isListening
                                ? Icons.mic
                                : Icons.mic_off_sharp,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (speechEnabled) {
                              if (speech.isListening) {
                                stopListening();
                              } else {
                                startListening(cubit);
                              }
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: defaultcolor,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.qr_code_scanner_sharp,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => BarcodeScreen(role: cubit.userData?['role'],)));
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  state is ShopSearchState || state is ShopProductsLoadedState
                      ? cubit.filteredProducts.isEmpty
                      ? Center(
                    child: Text(
                      'No Products Found',
                      style: GoogleFonts.montserrat(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )
                      : Container(
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
                      children: List.generate(
                          cubit.filteredProducts.length, (index) {
                        var product = cubit.filteredProducts[index];
                        return GestureDetector(
                            onTap: () {
                              Navigator.push(context, PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => ProductDetails(
                                  role: cubit.userData?['role'],
                                  productId: product.id,
                                  title: product['title'],
                                  imageUrl: product['imageUrl'],
                                  price: product['price'],
                                  description: product['description'],
                                  rating: product['rating'],
                                  category: product['category'],
                                  reviews: product['count'],
                                ),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(0.0, 1.0); // Start from bottom
                                  const end = Offset.zero; // End at the top
                                  const curve = Curves.easeInOut; // Smooth curve

                                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);

                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                              )).then((_) {
                                initSpeech();
                                BlocProvider.of<ShopCubit>(context).loadProducts(ShopCubit.get(context).firebaseProducts);
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  BlocProvider.of<ShopCubit>(context).searchProducts('');
                                });
                              });
                            },
                            child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
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
                                        (product['imageUrl'] != null && product['imageUrl'].isNotEmpty)
                                            ? FadeInImage.assetNetwork(
                                          height: 180, // Slightly increased height
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          placeholder: "Images/Animation - 1734121167586.gif",
                                          image: product['imageUrl'],
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
                                          "${product['title']}",
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
                                            "${product['category']}",
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
                                                  "\$${product['price']}",
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
                                                              .doc(product.id)
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

                                                                FirebaseFirestore.instance.collection('Products').doc(product.id).delete();
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
                                                          starIndex < double.parse(product['rating'])
                                                              ? Icons.star_rounded
                                                              : Icons.star_outline_rounded,
                                                          color: Colors.amber,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      "${product['rating']}",
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
                            ),
                          ),
                        );
                      }),
                    ),
                  )
                      : CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
