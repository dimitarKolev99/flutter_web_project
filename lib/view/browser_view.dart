import 'package:penny_pincher/models/preferences_articles.dart';
import 'package:penny_pincher/services/fav_functions.dart';
import 'package:penny_pincher/services/product_api.dart';
import 'package:penny_pincher/models/product.dart';
import 'package:penny_pincher/view/theme.dart';
import 'package:penny_pincher/view/widget/article_card.dart';
import 'package:flutter/material.dart';
import 'package:penny_pincher/view/widget/article_search.dart';
import 'dart:async';

import 'package:penny_pincher/view/widget/browser_article_card.dart';
import 'package:penny_pincher/view/widget/extended_view.dart';
import 'package:provider/provider.dart';

import 'filter_view.dart';

StreamController<bool> streamController = StreamController<bool>.broadcast();

class BrowserPage extends StatefulWidget {

  late final Stream<bool> stream;
  late final StreamController updateStream;

  BrowserPage(this.stream, this.updateStream);

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  late List<Product> _product;
  late final List _favoriteIds = [];
  late final List<Product> _products = [];
  bool _isLoading = true;
  var count = 0;
  Timer? _timer;

  final _preferenceArticles = PreferencesArticles();

  @override
  void initState() {
    if (this.mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    super.initState();
    widget.stream.listen((update) {
      updateBrowser(update);
    });
    getProducts(3832); print("CALLED FROM BROWSER VIEW");
  }

  Future<void> getProducts(int categoryID) async {
    _product = await ProductApi().fetchProduct(categoryID);

    List<Product> favorites = await _preferenceArticles.getAllFavorites();
    for (var i in favorites) {
      if (!_favoriteIds.contains(i.productId)) {
        _favoriteIds.add(i.productId);
      }
    }

    if (this.mounted) {
      setState(() {
        _isLoading = false;
      });
    }
    _products.addAll(_product);
    FavFunctions.addProducts(_products);
  }

  updateBrowser(bool update) {
    if (this.mounted) {
      updateFavorites();
    }
  }

  Future<void> updateFavorites() async {
    _favoriteIds.clear();
    List<Product> favorites = await _preferenceArticles.getAllFavorites();
    for (var i in favorites) {
      if (!_favoriteIds.contains(i.productId)) {
        _favoriteIds.add(i.productId);
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
    MediaQueryData _mediaQueryData = MediaQuery.of(context);
    double displayWidth = _mediaQueryData.size.width;
    double displayHeight = _mediaQueryData.size.height;
    double blockSizeHorizontal = displayWidth / 100; // screen width in 1%
    double blockSizeVertical = displayHeight / 100; // screen height in 1%
    return Scaffold(
      appBar: AppBar(
          backgroundColor: ThemeChanger.navBarColor,
          leading: IconButton(
            icon: Icon(Icons.category),
            onPressed: () {
              Navigator.push (
                context,
                MaterialPageRoute(
                    builder: (context) => FilterView())
            ); },
          ),
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
                ), ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                final results =
                showSearch(context: context, delegate: ArticleSearch(false, this, streamController));
              },
            )
          ]
      ),

      body: GridView.count(
        // Create a grid with 2 columns. If you change the scrollDirection to
        // horizontal, this produces 2 rows.
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        children: List.generate(_products.length, (index) {
          return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ExtendedView(
                          id: _products[index].productId,
                          title: _products[index].title,
                          saving: _products[index].saving,
                          category: _products[index].categoryName,
                          description: _products[index].description,
                          image: _products[index].image,
                          price: _products[index].price,
                          stream: streamController.stream,
                          callback: this)),
                );
                streamController.add(true);
              },
              child: BrowserArticleCard(
                  id: _products[index].productId,
                  title: _products[index].title,
                  saving: _products[index].saving,
                  category: _products[index].categoryName,
                  description: _products[index].description,
                  image: _products[index].image,
                  price: _products[index].price,
                  callback: this));
        }),
      ),
    );
  }

}
