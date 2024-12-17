import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobileproject/Cubit/Shop/Shop%20Cubit.dart';
import 'package:mobileproject/Cubit/Shop/Shop%20States.dart';
import 'package:mobileproject/Screens/Product%20Details%20Screen.dart';
import 'package:mobileproject/Shared/Constants.dart';

class CategoryScreen extends StatelessWidget {
  final String categoryName;
  final String role;
  CategoryScreen({required this.categoryName,required this.role});

  @override
  Widget build(BuildContext context) {
    var cubit = BlocProvider.of<ShopCubit>(context); // Access ShopCubit instance

    if (cubit.selectedCategory != categoryName) {
      cubit.selectCategory(categoryName);
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(categoryName),
      ),
      body: BlocConsumer<ShopCubit, ShopStates>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is ShopLoadingCatProductsDataState) {
            return Center(
              child: CircularProgressIndicator(
                color: defaultcolor,
              ),
            );
          }

          if (cubit.categoryProducts.isEmpty) {
            return Center(
              child: Text(
                'No products found in $categoryName',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: GridView.builder(
              itemCount: cubit.categoryProducts.length,
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.49,
              ),
              itemBuilder: (context, index) {
                var product = cubit.categoryProducts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetails(
                          role: role,
                          productId: product.id,
                          title: product['title'],
                          imageUrl: product['imageUrl'],
                          description: product['description'],
                          price: product['price'],
                          rating: product['rating'],
                          reviews: product['count'],
                          category: product['category'],
                        ),
                      ),
                    ).then((_) {
                      cubit.selectCategory('');
                      cubit.selectCategory(categoryName);
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
              },
            ),
          );
        },
      ),
    );
  }
}
