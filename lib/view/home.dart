import 'package:flutter/cupertino.dart';
import 'package:penny_pincher/models/preferences_articles.dart';
import 'package:penny_pincher/services/product_controller.dart';
import 'package:penny_pincher/services/json_functions.dart';
import 'package:penny_pincher/services/product_api.dart';
import 'package:penny_pincher/models/product.dart';
import 'package:penny_pincher/view/theme.dart';
import 'package:penny_pincher/view/welcome_screen.dart';
import 'package:penny_pincher/view/widget/app_bar_navigator.dart';
import 'package:penny_pincher/view/widget/article_card.dart';
import 'package:penny_pincher/view/widget/article_search.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:penny_pincher/view/extended_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

class HomePage extends StatefulWidget {
  late final Stream<bool> stream;
  late final StreamController updateStream;
  final dynamic callback;
  var height;
  HomePage(this.stream, this.updateStream, this.callback, {this.height});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamController<bool> streamController = StreamController<bool>.broadcast();

  late List<Product> _product;
  late final List _favoriteIds = [];
  late final List<Product> _products = [];
  bool _isLoading = true;
  var count = 0;
  Timer? _timer;
  bool isScrolling = false;
  ScrollController _scrollController = ScrollController();
  var x = 0.0;
  WelcomeStatus status = WelcomeStatus.loading;
  dynamic preferences;

  //var screenHeight = ;

  final _preferenceArticles = PreferencesArticles();
  final _jsonFunctions = JsonFunctions();
  var index = 0;
  var randomCategory = 0;

  _onUpdateScroll() {
    if (this.mounted) {
      setState(() {
        if (_scrollController.offset <
            _scrollController.position.maxScrollExtent) {
          isScrolling = true;
        } else {
          isScrolling = false;
        }
      });
    }
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
        if (status == WelcomeStatus.noFirstTime) {
          _isLoading = false;
        }
      });
    }
    if (status == WelcomeStatus.noFirstTime) {
      widget.callback.loadingFinished();
    }
    if (count < _product.length) {
      _products.insert(count, _product[count]);
      count++;
    }
    ProductController.addProducts(_products);
  }

  void initListOfIDs() {
    _jsonFunctions.getListOfProdCatIDs().then((value) => timerFunction(value));
  }

  timerFunction(List<int> ids) {
    // every 2 seconds get a random category id, call the api with it, load the product and animate it
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      index = _jsonFunctions.getRandomInt();
      randomCategory = ids[index];
      getProducts(randomCategory);
      if (_scrollController.hasClients && !isScrolling) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
      }
    });
  }

  @override
  void initState() {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    super.initState();
    widget.stream.listen((update) {
      if (this.mounted) {
        ProductController.updateFavorites(this);
      }
    });
    firstAppStart();
    initListOfIDs();

    tz.initializeTimeZones();
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);

    MediaQueryData _mediaQueryData;
    double displayWidth;
    double displayHeight;
    double blockSizeHorizontal;
    double blockSizeVertical;

    double _safeAreaHorizontal;
    double _safeAreaVertical;

    double _safeAreaBottomPadding;
    double safeBlockBottom;

    double safeBlockHorizontal;
    double safeBlockVertical;

    _mediaQueryData = MediaQuery.of(context);
    displayWidth = _mediaQueryData.size.width;
    displayHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = displayWidth / 100;
    blockSizeVertical = displayHeight / 100;

    displayHeight = x;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

    _safeAreaBottomPadding = _mediaQueryData.padding.bottom;
    safeBlockBottom = (displayWidth - _safeAreaBottomPadding) / 100;

    safeBlockHorizontal = (displayWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (displayHeight - _safeAreaVertical) / 100;

    if (status == WelcomeStatus.firstTime) {
      return WelcomePage(this);
    }
    if (_isLoading || status == WelcomeStatus.loading) {
      return Scaffold(
        body: Container(
            color: ThemeChanger.lightBlue,
            alignment: Alignment.center,
            child: Icon(Icons.search, color: Colors.grey, size: 100)),
      );
    } else {
      return Scaffold(
        appBar: HomeBrowserAppBar(this),
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
                                MaterialPageRoute(
                                    builder: (context) => ExtendedView(
                                        _products[index],
                                        this,
                                        streamController.stream)),
                              );
                            },
                            child: ArticleCard(_products[index], this));
                      }),
                )),
      );
    }
  }

  void closeWelcomeScreen() {
    setState(() {
      _isLoading = false;
      widget.callback.loadingFinished();
      status = WelcomeStatus.noFirstTime;
    });
  }

  firstAppStart() async {
    preferences = await SharedPreferences.getInstance();
    //await preferences.setBool("nofirstTime", false); // run welcome screen everytime

    var nofirstTime = preferences.getBool('nofirstTime');
    if (!nofirstTime) {
      await preferences.setBool("nofirstTime", true);
    }
    setState(() {
      if (nofirstTime) {
        status = WelcomeStatus.noFirstTime;
      } else {
        status = WelcomeStatus.firstTime;
      }
    });
  }

  bool getLoading() {
    return _isLoading;
  }

  void setLoading(bool b) {
    _isLoading = b;
  }
}

enum WelcomeStatus { loading, firstTime, noFirstTime }
