import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos/screens/account/Account.dart';
import 'package:flutter_pos/screens/order/cart.dart';
import 'package:flutter_pos/screens/account/vendor_information.dart';
import 'package:flutter_pos/screens/product/products_page.dart';
import 'package:flutter_pos/utils/Provider/ServiceData.dart';
import 'package:flutter_pos/utils/local/LanguageTranslated.dart';
import 'package:flutter_pos/model/ads.dart';
import 'package:flutter_pos/model/car_type.dart';
import 'package:flutter_pos/model/product_model.dart';
import 'package:flutter_pos/screens/product/category.dart';
import 'package:flutter_pos/utils/Provider/provider.dart';
import 'package:flutter_pos/utils/navigator.dart';
import 'package:flutter_pos/utils/screen_size.dart';
import 'package:flutter_pos/service/api.dart';
import 'package:flutter_pos/widget/app_bar_custom.dart';
import 'package:flutter_pos/widget/category/category_card.dart';
import 'package:flutter_pos/widget/custom_loading.dart';
import 'package:flutter_pos/widget/product/product_card.dart';
import 'package:flutter_pos/widget/product/product_list_titlebar.dart';
import 'package:flutter_pos/widget/slider/Banner.dart';
import 'package:flutter_pos/widget/slider/slider_dotAds.dart';
import 'package:flutter_svg/svg.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CarType> cartype;
  Ads ads;
  int checkboxType = 0;
  final ScrollController _scrollController = ScrollController();
  int complete;
  PersistentTabController _controller;
  final navigatorKey = GlobalKey<NavigatorState>();
  List<Widget> _buildScreens() {
    return [HomePage(), CategoryScreen(), CartScreen() ,Account()];

  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    final data = Provider.of<Provider_Data>(context);

    return [
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.home),
        title: getTransrlate(context, 'HomePage'),
        activeColorPrimary: CupertinoColors.activeOrange,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.apps),
        title: (getTransrlate(context, 'category')),
        activeColorPrimary: CupertinoColors.activeOrange,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Stack(
          children: [
            Center(child:
            Icon(CupertinoIcons.cart)),
            Center(
                child: Text(
              data.cart_model != null
                  ? " ${data.cart_model.data == null ? 0 : data.cart_model.data.count_pieces ?? 0} "
                  : '',
              style: TextStyle(
                  height: 1,
                  backgroundColor: Colors.white,
                  color: Colors.orange),
            )),
          ],
        ),
        iconSize: 35,
        title: (getTransrlate(context, 'Cart')),
        textStyle: TextStyle(height: 1),
        activeColorPrimary: CupertinoColors.activeOrange,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.menu,
          size: 35,
        ),
        title: (getTransrlate(context, 'MyProfile')),
        activeColorPrimary: CupertinoColors.activeOrange,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }

  @override
  void initState() {
    _controller = PersistentTabController(initialIndex: 0);

    API(context).get('car/types/list').then((value) {
      if (value != null) {
        setState(() {
          cartype = Car_type.fromJson(value).data;
        });
        getData(1);
      }
    });
    SharedPreferences.getInstance().then((value) {
      complete = value.getInt('complete');
    });
    super.initState();
  }

  getData(int cartypeId) {
    API(context).get('site/ads/show/filter?cartype_id=$cartypeId&platform=mobile').then((value) {
    if (value != null) {
      setState(() {
        ads = Ads.fromJson(value['data']);
      });
    }
  });
    Provider.of<Provider_Data>(context,listen: false).getData(cartypeId,context);
    Provider.of<Provider_Data>(context,listen: false).getShipping(context);

  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _carouselCurrentPage = 0;
  String pathImage;

  @override
  Widget build(BuildContext context) {
    final provider_Data = Provider.of<Provider_Data>(context);
    final theme = Provider.of<Provider_control>(context);
    return Scaffold(
      key: _scaffoldKey,
      // drawer: HiddenMenu(),
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        navBarHeight: 60,
        margin: EdgeInsets.only(bottom: 10),
        confineInSafeArea: true,
        backgroundColor: Colors.white,
        // Default is Colors.white.
        handleAndroidBackButtonPress: true,
        // Default is true.
        resizeToAvoidBottomInset: true,
        // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
        stateManagement: true,
        // Default is true.
        hideNavigationBarWhenKeyboardShows: true,
        // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.black12, width: 1),
          colorBehindNavBar: Colors.white,
        ),
        popAllScreensOnTapOfSelectedTab: true,

        selectedTabScreenContext: (v) {

          if (_controller.index == 2) {
            provider_Data.getCart(context);
          }
          // if (_controller.index == 0) {
          //     _scrollController.animateTo(
          //         _scrollController.position.minScrollExtent,
          //         duration: const Duration(milliseconds: 400),
          //         curve: Curves.fastOutSlowIn);
          //          }
        },
        onItemSelected: (i){
          if (i == 0) {
            _scrollController.animateTo(
                _scrollController.position.minScrollExtent,
                duration: const Duration(milliseconds: 400),
                curve: Curves.fastOutSlowIn);
          }        },
        popActionScreens: PopActionScreensType.once,
        itemAnimationProperties: ItemAnimationProperties(
          // Navigation Bar's items animation properties.
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),

        screenTransitionAnimation: ScreenTransitionAnimation(
          // Screen transition animation on change of selected tab.
          animateTabTransition: false,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
        navBarStyle:
            NavBarStyle.style6, // Choose the nav bar style with this property.
      ),
    );
  }

  Widget HomePage() {
    final themeColor = Provider.of<Provider_control>(context);
    final provider_data = Provider.of<Provider_Data>(context);

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          AppBarCustom(),
          // 1 = approved
          // 2 = rejected
          // 3 = declined
          // 4 = pending
          themeColor.Complete == 1
              ?  Container()
              : themeColor.Complete == 2
              ? Padding(
            padding: const EdgeInsets.only(top: 22,bottom: 10, right: 10, left: 10),
            child: InkWell(
              onTap: () {
                Nav.route(context, VendorInfo());
              },
              child: Row(
                children: [
                  SvgPicture.asset(
                    "assets/icons/Attention.svg",
                    color: Colors.orange,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(width: ScreenUtil.getWidth(context)/1.2,
                    child: Text(
                      '${getTransrlate(context, 'invalidvendor')}',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ):themeColor.Complete == 3?Center(
            child: Container(
              width: ScreenUtil.getWidth(context) / 1.2,
              child:  Row(
                crossAxisAlignment:
                CrossAxisAlignment.center,
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.remove_circle_outline,
                    color: Colors.red,
                    size: 35,
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width:
                    ScreenUtil.getWidth(context) /
                        1.5,
                    child: Text(
                      '${getTransrlate(context, 'rejectvendor')}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 20),
                    ),
                  ),
                ],
              ),

            ),
          ):themeColor.Complete == 4?Padding(
                  padding: const EdgeInsets.only(top: 22,bottom: 10, right: 10, left: 10),
                  child: InkWell(
                    onTap: () {
                      Nav.route(context, VendorInfo());
                    },
                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.center,
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                          size: 30,
                        ),
                        SizedBox(width: 10),
                        SizedBox(
                          width:
                          ScreenUtil.getWidth(context) /
                              1.5,
                          child: Text(
                            '${getTransrlate(context, 'incompletvendor')}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ) : Container(),
          Expanded(
            child: RefreshIndicator(color: themeColor.getColor(),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        "???????????? ???????? ???? ",
                        maxLines: 3,
                        textAlign: TextAlign.center,
                        textDirection:
                        TextDirection.ltr,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                            FontWeight.w500,
                            color: Colors.black),
                      ),
                    ),
                    cartype == null
                        ? Container()
                        : ResponsiveGridList(
                            desiredItemWidth: ScreenUtil.getWidth(context)/2.4,
                            minSpacing: 10,
                            rowMainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            scroll: false,
                            children: cartype
                                .map((e) {
                              final selected=checkboxType==cartype.indexOf(e);
                             return InkWell(
                               onTap: () {
                                 setState(() {
                                   checkboxType = cartype.indexOf(e);
                                   provider_data.product = null;
                                   provider_data.productMostView = null;
                                   provider_data.productMostSale = null;
                                   provider_data.Mostcategories = null;
                                 });
                                 themeColor.setCar_type(e.id);
                                 themeColor.setCar_index(cartype.indexOf(e));
                                 print(e.typeName);
                                 getData(checkboxType==0?1:3);
                               },
                               child: Container(
                                 height:
                                 ScreenUtil.getHeight(context) /
                                     7,
                                // width: ScreenUtil.getWidth(context) / 2.5,
                                 decoration: BoxDecoration(
                                   border: Border.all(
                                       width: 3.0,
                                       color: selected
                                           ? Colors.orange
                                           : Colors.black12),
                                   image: DecorationImage(
                                       image: CachedNetworkImageProvider(
                                           "${e.image}"),
                                       fit: BoxFit.cover),
                                   borderRadius: themeColor.local ==
                                       'ar'
                                       ? cartype.indexOf(e).isEven
                                       ? BorderRadius.only(
                                       topRight: Radius.circular(
                                           15.0),
                                       bottomRight:
                                       Radius.circular(
                                           15.0))
                                       : BorderRadius.only(
                                       topLeft: Radius.circular(
                                           15.0),
                                       bottomLeft:
                                       Radius.circular(
                                           15.0))
                                       : cartype.indexOf(e).isEven
                                       ? BorderRadius.only(
                                       topLeft: Radius.circular(
                                           15.0),
                                       bottomLeft:
                                       Radius.circular(
                                           15.0))
                                       : BorderRadius.only(
                                       topRight:
                                       Radius.circular(15.0),
                                       bottomRight: Radius.circular(15.0)),
                                 ),
                                 child: Align(
                                   alignment: Alignment.bottomCenter,
                                   child: Card(
                                     color: Colors.black12,
                                     child: Padding(
                                       padding:
                                       const EdgeInsets.all(4.0),
                                       child: AutoSizeText(
                                           "${themeColor.getlocal()=='ar'? e.typeName:e.name_en}",
                                           maxLines: 1,
                                           maxFontSize: 18,
                                           minFontSize: 10,
                                           style: TextStyle(
                                               color: Colors.white,
                                               fontWeight:
                                               FontWeight.bold)),
                                     ),
                                   ),
                                 ),
                               ),
                             );
                            })
                                .toList()),
                    provider_data.Mostcategories == null
                        ?  Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Custom_Loading(),
                    )
                        : Container(child: list_category_navbar(themeColor)),
                    ads == null
                        ? Container()
                        : Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: CarouselSlider(
                        items: ads.carousel
                            .map((item) => Banner_item(
                          item: item.photo.image,
                        ))
                            .toList(),
                        options: CarouselOptions(
                            height: ScreenUtil.getHeight(context) / 5,
                            aspectRatio: 16 / 9,
                            viewportFraction: 0.8,
                            initialPage: 0,
                            enableInfiniteScroll: true,
                            reverse: false,
                            autoPlay: true,
                            autoPlayInterval: Duration(seconds: 3),
                            autoPlayAnimationDuration:
                            Duration(milliseconds: 800),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enlargeCenterPage: true,
                            //onPageChanged: callbackFunction,
                            scrollDirection: Axis.horizontal,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _carouselCurrentPage = index;
                              });
                            }),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ads == null
                        ? Container()
                        : SliderDotAds(
                        _carouselCurrentPage, ads.carousel),
                    SizedBox(
                      height: 20,
                    ),
              provider_data.productMostView == null
                        ?Container()
                        : Container(child: list_category(themeColor)),
                    provider_data.product == null
                        ? Container()
                        : provider_data.product.isEmpty
                            ? Container()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  cartype==null?Container(): cartype.isEmpty?Container(): ProductListTitleBar(
                                    themeColor: themeColor,
                                    title: getTransrlate(context, 'offers'),
                                    description: getTransrlate(context, 'showAll'),
                                    url:
                                        'ahmed/new/products?cartype_id=${cartype[checkboxType].id}&per_page=50',
                                  ),
                                  list_product(themeColor, provider_data.product),
                                ],
                              ),
                    ads == null
                        ? Container()
                        : ListView.builder(
                      primary: false,
                      shrinkWrap: true,
                      padding: EdgeInsets.all(1),
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: ads.bottom.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Banner_item(item: ads.bottom[index].photo.image),
                        );
                      },
                    ),
                    provider_data.productMostSale == null
                        ? Container()
                        : provider_data.productMostSale.isEmpty
                            ? Container()
                            :cartype==null
                            ? Container()
                            :cartype.isEmpty
                            ? Container()
                            : Column(
                                children: [
                                  ProductListTitleBar(
                                    themeColor: themeColor,
                                    title: getTransrlate(context, 'moresale'),
                                    description: getTransrlate(context, 'showAll'),
                                    url: 'ahmed/best/seller/products?cartype_id=${cartype[checkboxType].id}&per_page=50',
                                  ),
                                  list_product(themeColor,provider_data.productMostSale),
                                  SizedBox(
                                    height: 10,
                                  )
                                ],
                              ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
              onRefresh: _refreshLocalGallery,

            ),
          ),
        ],
      ),
    );
  }
  Future<Null> _refreshLocalGallery() async{
    getData(checkboxType==0?1:3);

  }
  Widget list_category(
    Provider_control themeColor,
  ) {
    final provider_data = Provider.of<Provider_Data>(context);

    return provider_data.productMostView.isEmpty
        ? Container()
        : Column(
          children: [
            Text(
                "${getTransrlate(context, 'DescOpportunities')}",
                maxLines: 1,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                )),
            Center(
                child: ResponsiveGridList(
                  scroll: false,
                  desiredItemWidth: 100,
                  rowMainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  minSpacing: 10,
                  children: provider_data.productMostView
                      .map((product) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: CategoryCard(
                              themeColor: themeColor,
                              product: product,
                            ),
                          ))
                      .toList(),
                ),
              ),
          ],
        );
  }
  Widget list_category_navbar(
    Provider_control themeColor,
  ) {
    final provider_data = Provider.of<Provider_Data>(context);

    return provider_data.Mostcategories.isEmpty
        ? Container()
        : Center(
            child: ResponsiveGridList(
              scroll: false,
              desiredItemWidth: 100,
              rowMainAxisAlignment: MainAxisAlignment.spaceEvenly,
              minSpacing: 10,
              children: provider_data.Mostcategories
                  .map((product) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Container(
                          margin: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: InkWell(
                            onTap: () {
                              Nav.route(
                                  context,
                                  Products_Page(
                                    id: product.id,
                                    name: "${ themeColor.getlocal()=='ar'? product.name??product.nameEn :product.nameEn??product.name}",
                                    Url: 'ahmed/allcategories/products/${product.id}?cartype_id=${themeColor.car_type}',
                                    Istryers: product.id==1711||product.id==682,
                                    Category: true,
                                    Category_id: product.id,
                                  ));
                            },
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black26),
                                      color: Colors.white),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: CachedNetworkImage(
                                      height: ScreenUtil.getHeight(context) / 12,
                                      width: ScreenUtil.getWidth(context) / 3.2,
                                      imageUrl: (product.photo == null)
                                          ? 'http://arabimagefoundation.com/images/defaultImage.png'
                                          : product.photo.image,
                                      errorWidget: (context, url, error) => Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Image.asset(
                                          'assets/images/alt_img_category.png',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                AutoSizeText(
                                  "${ themeColor.getlocal()=='ar'? product.name??product.nameEn :product.nameEn??product.name}",
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          );
  }
  Widget list_product(Provider_control themeColor,
      List<Product> product) {
    return product.isEmpty
        ? Container()
        : ResponsiveGridList(
      scroll: false,

      desiredItemWidth: 150,
      minSpacing: 10,

      children: product.map((e) => Center(
        child: Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 8),
          child: ProductCard(
            themeColor: themeColor,
            product:e,
          ),
        ),
      )).toList(),
          );
  }
}
