import 'package:penny_pincher/models/preferences_articles.dart';
import 'package:penny_pincher/services/product_api.dart';
import 'package:penny_pincher/models/product.dart';
import 'package:penny_pincher/view/widget/article_card.dart';
import 'package:penny_pincher/view/widget/article_search.dart';
import 'package:penny_pincher/view/widget/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:penny_pincher/view/widget/extended_view.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Product> _product;
  late final List _favoriteIds = [];
  late final List<Product> _products = [];
  bool _isLoading = true;
  var count = 0;
  Timer? _timer;
  bool _isScrolling = false;
  ScrollController _scrollController = ScrollController();

  final _preferenceArticles = PreferencesArticles();

  _onUpdateScroll() {
    setState(() {
      if (_scrollController.offset < _scrollController.position.maxScrollExtent) {
        _isScrolling = true;
      }
      else {
        _isScrolling = false;
      }
    });
  }

  Future<void> getProducts() async {
    _product = await ProductApi.fetchProduct();
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
    _products.insert(count, _product[count]);
    count++;
  }

  @override
  void initState() {
    if(this.mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    super.initState();
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      getProducts();

      if(_scrollController.hasClients && !_isScrolling) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
      }

      if(count >= _product.length - 1) {
        dispose();
      }
    });
    //getProducts();
  }

 @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color.fromRGBO(23, 41, 111, 1),
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
              Text('Penny Pincher')
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                final results = showSearch(context: context, delegate: ArticleSearch());
              },
            )
          ]
      ),
      bottomNavigationBar: BottomNavBarGenerator(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Align(
        alignment: Alignment.topCenter,
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollUpdateNotification) {
              _onUpdateScroll();
            }
            return true;
          },

        child: ListView.builder(
            reverse: true,
            shrinkWrap: true,
            controller: _scrollController,
            itemCount: _products.length,
            itemBuilder: (context, index) {
              return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExtendedView(
                      id: _products[index].productId,
                      title: _products[index].title,
                      saving: _products[index].saving,
                      category: _products[index].categoryName,
                      description: _products[index].description,
                      image: _products[index].image,
                      price:  _products[index].price,
                      callback: this)),
                );
              },
                  child: ArticleCard(
                id: _products[index].productId,
                title: _products[index].title,
                    saving: _products[index].saving,
                category: _products[index].categoryName,
                description: _products[index].description,
                image: _products[index].image,
                price: _products[index].price,
                callback: this,));
            }),
        )
      ),
    );
  }

  bool isFavorite(int id) {
    return _favoriteIds.contains(id);
  }

  Future changeFavoriteState(ArticleCard card) async {
    if (isFavorite(card.id)) {
      showAlertDialog(context, card.id);
    } else {
      await _preferenceArticles.addFavorite(card);
      if (mounted) {
        setState(() {
          _favoriteIds.add(card.id);});
      }
    }
  }

  showAlertDialog(BuildContext context, int id) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Nein"),
      onPressed:  () {Navigator.of(context).pop();},
    );
    Widget continueButton = TextButton(style: TextButton.styleFrom(
      primary: Colors.red,
    ),
      child: const Text("Ja"),
      onPressed:  () async {
        Navigator.of(context).pop();
        await _preferenceArticles.removeFavorite(id);
        if (mounted) {
          setState(() {
            _favoriteIds.remove(id);
          });
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Artikel entfernen?"),
      content: const Text("Willst du diesen Artikel wirklich aus deinen Favorites entfernen?"),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
