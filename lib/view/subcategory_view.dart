import 'dart:async';
import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:penny_pincher/services/json_functions.dart';
import 'package:penny_pincher/services/product_api.dart';
import 'package:penny_pincher/view/theme.dart';
import 'package:penny_pincher/view/widget/subcat_button.dart';
import 'package:provider/provider.dart';

class SubcategoryView extends StatefulWidget{
  int categoryId;
  String categoryName;


  SubcategoryView({
    required this.categoryId,
    required this.categoryName,
  });


  @override
  State<StatefulWidget> createState() => _SubcategoryViewState();


  }

class _SubcategoryViewState extends State<SubcategoryView>{
  RangeValues _currentSliderValuesPrice = const RangeValues(20, 70);

  JsonFunctions json = JsonFunctions();


  Map<String, int> subCategoriesMap = new Map();
  // names and Ids have matching indexes for name and id of the category
  List<String> subCategoriesNames = [];
  List<int> subCategoriesIds = [];
  @observable
  ObservableList<SubcatButton> subCatButtons = new ObservableList();
  //List<SubcatButton> subCatButtons = [];


  Future<void> listToButtons() async{
    if(subCatButtons.isEmpty) {
      for (int i = 0; i < subCategoriesNames.length; i++) {
        subCatButtons.add(
            SubcatButton(categoryName: subCategoriesNames[i], categoryId: subCategoriesIds[i]));
      }
    }
  }

  Future<void> mapToLists() async {
    if(subCategoriesNames.isEmpty) {
      subCategoriesMap.forEach((name, id) {
        subCategoriesNames.add(name);
        subCategoriesIds.add(id);
       // print("added $name addedID $id");
      });
    }
  }

  Future<void> getSubCategories() async{
    //print("category ID view!!! :_______   ${widget.categoryId}");
    if(subCategoriesMap.isEmpty) {
      json.getJson().then((List<dynamic> result) {
        List<dynamic> resultList = [];
        resultList = result;
         subCategoriesMap =
            json.getMapOfSubOrProductCategories(widget.categoryId, resultList);
      });
     // print("subCategoriesMap.lengthsubCategoriesMap.length ${subCategoriesMap.length}");
    }
  }

  Future<void> getCats() async {
    await getSubCategories();
    await mapToLists();
    await listToButtons();
  }

  @override
    Widget build (BuildContext context){
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);

    MediaQueryData _mediaQueryData;
    double displayWidth;
    double displayHeight;
    double blockSizeHorizontal;
    double blockSizeVertical;

    double _safeAreaHorizontal;
    double _safeAreaVertical;
    double safeBlockHorizontal;
    double safeBlockVertical;

    _mediaQueryData = MediaQuery.of(context);
    displayWidth = _mediaQueryData.size.width;
    displayHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = displayWidth / 100;
    blockSizeVertical = displayHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (displayWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (displayHeight - _safeAreaVertical) / 100;


    return
      Scaffold(
          appBar: AppBar(
              backgroundColor: ThemeChanger.navBarColor,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 3),
                    child:
                    Text(
                      'Categories',
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
              )),
          body:
              // Everything shown in body
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Price and Discount
                  Container(
                    child: Column(
                      children: [

                        // Title for Price-Slider
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(left: blockSizeHorizontal * 6, top: blockSizeHorizontal * 2),
                          //Headline: Price
                          child: Text("Preisklasse : ",
                              style: TextStyle(
                                color: ThemeChanger.navBarColor,
                                //fontWeight: FontWeight.bold,
                                fontSize: safeBlockHorizontal * 5,
                              )),
                        ),

                        // PriceSlider
                        Container(
                          width: blockSizeHorizontal * 100,
                          child: RangeSlider(
                            activeColor: ThemeChanger.navBarColor,
                            //inactiveColor: ProductApi.orange,
                            values: _currentSliderValuesPrice,
                            min: 0,
                            max: 1000,
                            divisions: 100,
                            /*
                      labels: RangeLabels(
                        _currentSliderValuesPrice.start.round().toString() + "€",
                        _currentSliderValuesPrice.end.round().toString() + "€",
                      ),
                       */
                            onChanged: (RangeValues values) {
                              setState(() {
                                _currentSliderValuesPrice = values;
                              });
                            },
                          ),
                        ),

                        // Output of Price-Slider
                        Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: blockSizeVertical * 2),
                              padding: EdgeInsets.only(
                                  top: blockSizeVertical * 1,
                                  bottom: blockSizeVertical * 1,
                                  left: blockSizeHorizontal * 3,
                                  right: blockSizeHorizontal * 3),
                              decoration: BoxDecoration(
                                color: ThemeChanger.lightBlue,
                                borderRadius:
                                BorderRadius.circular(blockSizeHorizontal * 3),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    _currentSliderValuesPrice.start.round().toString() +
                                        " €",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: safeBlockHorizontal * 4.8,
                                      color: ThemeChanger.textColor,
                                      //backgroundColor: ProductApi.lightBlue,
                                    ),
                                  ),
                                  Text(
                                    _currentSliderValuesPrice.end.round().toString() +
                                        " €",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: safeBlockHorizontal * 4.8,
                                      color: ThemeChanger.textColor,
                                      //backgroundColor: ProductApi.lightBlue,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Waits for the lists of categories before it builds the widgets
                  Expanded(
                    child: FutureBuilder(
                        future: getCats(),
                        builder: (context, snapshot){
                          return
                            ListView.builder(
                                itemCount: subCatButtons.length,
                                itemBuilder: (context, index) {
                                  // print("length of categories : ${subCatButtons.length}");
                                  return subCatButtons[index];
                                });
                        }
                    )
                  ),
                ],
              )
              );
  }
}

