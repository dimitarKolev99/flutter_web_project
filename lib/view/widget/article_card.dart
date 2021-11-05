//import 'dart:html';

import 'package:http/http.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:penny_pincher/models/preferences_articles.dart';
import 'package:penny_pincher/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';




class ArticleCard extends StatelessWidget {
  final int id;
  final String title;
  final String rating = "30";
  final double price;
  final String image;
  final String description;
  final String category;
  dynamic callback;

  ArticleCard({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.description,
    required this.category,
    required this.callback,
  });

 // final List<PreferencesArticles> savedProducts;



  /*
  @override
  void _populateFileds() async {
    final articleCard = await _preferenceArticles.getArticleCard();

    setState(() {
      title = articleCard.title;
      price = articleCard.price;
      image = articleCard.image;
      description = articleCard.description;
      category = articleCard.category;
    });
  }

   */


  @override
  Widget build(BuildContext context) {
    final displayWidth =  MediaQuery.of(context).size.width;
    final displayHeight =  MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      width: displayWidth,
      height: displayHeight / 5 - 1,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            offset: Offset(
              0.0,
              10.0,
            ),
            blurRadius: 10.0,
            spreadRadius: -6.0,
          ),
        ],
      ),
      child:
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
                                                                                // Picture + Rating / Discount%
          Align(
            child:
                                                                                // Product Image
                  Container(
                    width: displayWidth/3 - 20,
                    margin: EdgeInsets.only(left: 10),
                    child:
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                    child:
                    Image.network(
                      image,
                      width: displayWidth / 3 - 30,
                      height: displayWidth / 3 - 30,
                      fit: BoxFit.contain,
                      ),
                  ),
                  ),
                alignment: Alignment.centerLeft,
          ),


            Container(
                                                                                // title
            margin: EdgeInsets.only(left: 4, right: 4, top: 20),
            width: displayWidth/3 ,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              alignment: Alignment.topCenter,
            ),

          Container(
            width: displayWidth / 3 -35,
            child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
                                                                                // Favourite Icon
              Align(
                child: Padding(
                  padding: EdgeInsets.only(right: 7),
                  child:
                  IconButton(
                  icon: (callback.isFavorite(id)
                      ? const Icon(Icons.favorite,
                      color: Colors.red)
                      : const Icon(Icons.favorite_border,
                      color: Colors.black)),
                  onPressed: _changeFavorite,
                  )
                ),
              alignment: Alignment.centerRight,
              ),
                Container(                                                      // % Badge
                  padding: EdgeInsets.only(top: 3, bottom: 3, left: 10, right: 17),
                  decoration: BoxDecoration(color: Color.fromRGBO(220, 110, 30, 1),  // const Color.fromRGBO(23, 41, 111, 0.8),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child:
                  Text("-" + rating+ "%",
                    style: TextStyle(
                      color: Color.fromRGBO(240, 240, 240, 1),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                                                                                // current Price...
                Container(
                margin: EdgeInsets.only(right: 10, bottom: 0),
                child:
                Column(
                    children: [
                      const Text(
                        "Current Price:",
                        style: TextStyle(
                            fontWeight: FontWeight
                                .bold,
                            fontSize: 10,
                            color: Colors
                                .black),
                      ),
                      Text(
                        price.toString() + " €",
                        style: const TextStyle(
                          fontWeight: FontWeight
                              .bold,
                          fontSize: 20,
                          color: Color
                              .fromRGBO(
                              220, 110, 30,
                              1),),
                      ),
                      const Text(
                        //ToDO: add previous price
                        "Previously 9.99€",
                        style: TextStyle(
                            fontSize: 8,
                            color: Colors
                                .black),
                      ),
                    ]
                ),
            ),
            ],
          )
),
        ],
      )
    );
  }




  //creating an object of ArticleCard
  Future _changeFavorite() async {
    await callback.changeFavoriteState(this);
  }
}













