import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:penny_pincher/models/preferences_articles.dart';
import 'package:penny_pincher/models/ws_product.dart';
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
import 'package:penny_pincher/view/widget/new_article_card.dart';
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

  Map<String, int> mainCategories = {
    "Elektroartikel": 30311,
    "Drogerie & Gesundheit": 3932,
    "Haus & Garten": 3686,
    "Mode & Accessoires": 9908,
    "Tierbedarf": 7032,
    "Gaming & Spielen": 3326,
    "Essen & Trinken": 12913,
    "Baby & Kind": 4033,
    "Auto & Motorrad": 2400,
    "Haushaltselektronik": 1940,
    "Sport & Outdoor": 3626,
  };
  List<String> mainCategoryNames = [
    "Elektroartikel",
    "Drogerie & Gesundheit",
    "Haus & Garten",
    "Mode & Accessoires",
    "Tierbedarf",
    "Gaming & Spielen",
    "Essen & Trinken",
    "Baby & Kind",
    "Auto & Motorrad",
    "Haushaltselektronik",
    "Sport & Outdoor"
  ];
  List<int> mainCategoryIds = [
    30311,
    3932,
    3686,
    9908,
    7032,
    3326,
    12913,
    4033,
    2400,
    1940,
    3626,
  ];

  JsonFunctions json = JsonFunctions();
  Map<String, int> subCategoriesMap = Map();
  // names and Ids have matching indexes for name and id of the category
  List<String> subCategoriesNames = [];
  List<int> subCategoriesIds = [];
  late int categoryId;
  late String categoryName;
  List<int> productCategoryIDs = [];
 // bool check = false;

  //when map is empty then json funtions is called
  Future<void> getSubCategories() async{
    if(subCategoriesMap.isEmpty) {
      print("getSubCategories is empty");
      json.getJson().then((List<dynamic> result) {
        List<dynamic> resultList = [];
        resultList = result;
        subCategoriesMap = json.getMapOfSubOrProductCategories(categoryId, resultList);
        print("subCategoriesMap in getSubCategories $subCategoriesMap");
      });
    }
    if(subCategoriesMap.isNotEmpty) {
      print("getSubCategories is not empty");
      subCategoriesMap.clear();
      json.getJson().then((List<dynamic> result) {
        List<dynamic> resultList = [];
        resultList = result;
        subCategoriesMap = json.getMapOfSubOrProductCategories(categoryId, resultList);
        print("subCategoriesMap in getSubCategories $subCategoriesMap");
      });
    }
  }
  //seperate the sub map into 2 lists 1 with names and 1 with ids
  Future<void> mapToLists() async {
    if(subCategoriesNames.isEmpty) {
      print("mapToLists Is emtpy");
      subCategoriesMap.forEach((name, id) {
        subCategoriesNames.add(name);
        subCategoriesIds.add(id);
        print("added $name");
      });
    }
    if (subCategoriesNames.isNotEmpty) {
      print("mapToLists Its Not Empty");
      subCategoriesNames.clear();
      subCategoriesIds.clear();
        subCategoriesMap.forEach((name, id) {
        subCategoriesNames.add(name);
        subCategoriesIds.add(id);
        print("added $name");
        print("added $id");
      });
    }
  }



  StreamController<bool> streamController = StreamController<bool>.broadcast();


  late List<Product> _product;

  late List<ProductWS> newProduct;

  late final List _favoriteIds = [];
  late final List<Product> _products = [];
  late final List<ProductWS> newProducts = [];
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

  int _selectedItem = -1;

  _onSelect(int index) {
    setState(() {
      _selectedItem = index;
    });
  }

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

  Future<void> getProductsWS() async {
    newProduct = await ProductApi().fetchProductWebSocket();

    /*List<Product> favorites = await _preferenceArticles.getAllFavorites();
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
    }*/



      newProducts.insert(count, newProduct[count]);
      count++;

    //ProductController.addProducts(_products);
  }

  /*
  void initListOfIDs() {
    _jsonFunctions.getListOfProdCatIDs().then((value) => timerFunction(value));
  }

   */
  


  timerFunctionn(List<int> ids) {
    // every 2 seconds get a random category id, call the api with it, load the product and animate it
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      randomCategory = ids[0];
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

  timerFunction(List<int> ids) {
    // every 2 seconds get a random category id, call the api with it, load the product and animate it
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      index = _jsonFunctions.getRandomInt(_jsonFunctions.count);
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

  String string = "1.049,09��";

  String parseString(String string) {
    String newString = "";
    for (int i = 0; i < string.length; i++) {
      if (string[i] ==  ",") {
       newString = string.substring(0, i + 2);
      }
    }
    return newString;
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
    //initListOfIDs();
    //ProductApi().fetchProductWebSocket();
    print("AAAAAAAAAAA" + "sa" +parseString("1.049,09��"));

    tz.initializeTimeZones();
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  var data;

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
        body:
        //_isLoading ? Center(child: CircularProgressIndicator()) :
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                color: ThemeChanger.lightBlue,
                height: 40,
                width: displayWidth,
                child: ListView.builder(
                    physics: ScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: mainCategories.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () async {
                            mainCategories[index];
                            categoryId = mainCategoryIds[index];
                            print("categoryid = ${categoryId}");
                            await getSubCategories();
                            await mapToLists();

                            setState(() {
                              _jsonFunctions.getListOfProdCatIDs(mainCategoryIds.indexOf(categoryId))
                                  .then((value) {
                                    timerFunction(value);
                                    //_jsonFunctions.count = 1;
                                print("AAAAAA $_jsonFunctions.count");
                                  });
                            });

                            setState(() {
                              _onSelect(index);
                            });

                            print("subCategoryMAP = ${subCategoriesMap}");
                            print("subCategoryID = ${subCategoriesIds}");
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: _selectedItem != null && _selectedItem == index ? ThemeChanger.highlightedColor : ThemeChanger.articlecardbackground,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            alignment: Alignment.centerRight,
                            margin: EdgeInsets.all(4),
                            //padding: EdgeInsets.all(4),
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            height: 40,
                            child: Text(
                              mainCategoryNames[index],
                              style: TextStyle(
                                color: ThemeChanger.reversetextColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ));
                    }),
              ),
            ),
          Expanded(
            child:
            Align(
                alignment: Alignment.topCenter,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification is ScrollUpdateNotification) {
                      _onUpdateScroll();
                    }
                    return true;
                  },
                  child: StreamBuilder(
                    stream: ProductApi().fetchProductWebSocket().stream,
                    builder: (context, snapshot) {
                      if(snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.connectionState == ConnectionState.active
                          || snapshot.connectionState == ConnectionState.done){
                       if (snapshot.hasError) {
                         return const Text('ERROR !!!');
                       } else if (snapshot.hasData) {
                         print("CCCCCCC: ${snapshot.data}");
                         print("NewArticleCard NewArticleCard: ${NewArticleCard(productFromJson(snapshot.data.toString()))}");
                         return NewArticleCard(productFromJson(snapshot.data.toString()));
                       }
                      }
                      return const Text('');
                      /*
                      return ListView.builder(
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
                            child: NewArticleCard(newProducts[index], this)
                        );
                      }
                      );
                      */
                      },
                  ),
                )
            ),
          )
          ],
        )

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
    await preferences.setBool("nofirstTime", false); // run welcome screen everytime

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
