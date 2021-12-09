import 'dart:convert';
import 'package:penny_pincher/models/preferences_articles.dart';
import 'package:penny_pincher/services/fav_functions.dart';
import 'package:penny_pincher/services/product_api.dart';
import 'package:penny_pincher/models/product.dart';
import 'package:penny_pincher/view/theme.dart';
import 'package:penny_pincher/view/widget/article_card.dart';
import 'package:penny_pincher/view/widget/extended_view.dart';
import 'package:penny_pincher/view/widget/favorite_card.dart';
import 'package:flutter/material.dart';
import 'package:penny_pincher/view/widget/favorite_search.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

StreamController<bool> streamController = StreamController<bool>.broadcast();

class FavoritePage extends StatefulWidget {

  late final Stream<bool> stream;
  late final StreamController updateStream;

  FavoritePage(this.stream, this.updateStream);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  //late Product _product;

  late List<Product> _product;
  late final List<Product> favoriteProducts = [];
  bool _isLoading = true;
  bool _isClosed = false;
  String query = '';
  dynamic search;

  final _preferenceArticles = PreferencesArticles();

  @override
  void initState() {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    getProducts();
    super.initState();
    widget.stream.listen((update) {
      updateFavorites(update);
    });
  }

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // displayName = prefs.getStringList('displayName');
    });
  }

  Future <void> getProducts() async {
    favoriteProducts.clear();
    _product = await _preferenceArticles.getAllFavorites();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
    for (var i = 0; i < _product.length; i++) {
      favoriteProducts.insert(i, _product[i]);
    }
    FavFunctions.setFavs(favoriteProducts);
    FavFunctions.addProducts(favoriteProducts);
  }

  updateFavorites(bool update) {
    if (this.mounted) {
      setState(() {
        getProducts();
      });
    }
    if (_isClosed) {
      _isClosed = false;
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
    return Scaffold(
      appBar: AppBar(
          backgroundColor: ThemeChanger.navBarColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Icon(Icons.restaurant_menu),
              Image.network(
                "https://cdn.discordapp.com/attachments/899305939109302285/903270501781221426/photopenny.png",
                width: 40,
                height: 40,
              ),
              /*
            // Doesnt work yet
            Image.asset("pictures/logopenny.png"
            , width: 40,
              height: 40,
            ),
            */
              SizedBox(width: 10),
              Padding(
                padding: EdgeInsets.only(top: 3),
                child:
                Text(
                  'Penny Pincher',
                  style: TextStyle(
                    // Shaddow is used to get Distance to the underline -> TextColor itself is transparent
                    shadows: [
                      Shadow(
                          color: Color.fromRGBO(240, 240, 240, 1),
                          offset: Offset(0, -6))
                    ],
                    //fontFamily: '....',
                    fontSize: 21,
                    letterSpacing: 3,
                    color: Colors.transparent,
                    fontWeight: FontWeight.w900,
                    decoration:
                    TextDecoration.underline,
                    decorationColor: ThemeChanger.highlightedColor,
                    decorationThickness: 4,
                  ),
                ),),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                final results =
                showSearch(context: context,
                    delegate: FavoriteSearch(this, streamController));
              },
            )
          ]),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : favoriteProducts.isNotEmpty
          ? Align(
        alignment: Alignment.topCenter,
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: favoriteProducts.length,
            itemBuilder: (context, index) {
              return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ExtendedView(
                                  id: favoriteProducts[index].productId,
                                  title: favoriteProducts[index].title,
                                  saving: favoriteProducts[index].saving,
                                  category:
                                  favoriteProducts[index].categoryName,
                                  description:
                                  favoriteProducts[index].description,
                                  image: favoriteProducts[index].image,
                                  price: favoriteProducts[index].price,
                                  stream: streamController.stream,
                                  callback: this)),
                    );
                    streamController.add(true);
                    _isClosed = true;
                  },
                  child: ArticleCard(
                    id: favoriteProducts[index].productId,
                    title: favoriteProducts[index].title,
                    saving: favoriteProducts[index].saving,
                    category: favoriteProducts[index].categoryName,
                    description: favoriteProducts[index].description,
                    image: favoriteProducts[index].image,
                    price: favoriteProducts[index].price,
                    callback: this,
                  ));
            }),
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_outlined, color: Colors.grey, size: 80),
            SizedBox(height: 30),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                      text:
                      "Du hast noch keine Favorites gespeichert.\n \nDu kannst Favorites hinzufügen, indem du auf das ",
                      style: TextStyle(
                          fontSize: 18, color: ThemeChanger.reversetextColor)),
                  WidgetSpan(
                    child: Icon(Icons.favorite,
                        color: Colors.red, size: 20),
                  ),
                  TextSpan(
                      text: " klickst.",
                      style: TextStyle(
                          fontSize: 18, color: ThemeChanger.reversetextColor)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Text("Du hast noch keine Favoriten gespeichert.\n \nDu kannst Favoriten hinzufügen, indem du auf das ❤ klickst.",
  // textAlign: TextAlign.center,
  // style: TextStyle(fontSize: 18, color: Colors.black),
  // )

  Future changeFavoriteState(ArticleCard card) async {
    FavFunctions.changeFavoriteState(card, this);
  }
}
