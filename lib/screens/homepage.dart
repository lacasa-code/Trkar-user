import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos/SearchOverlay.dart';
import 'package:flutter_pos/model/car_type.dart';
import 'package:flutter_pos/model/category_model.dart';
import 'package:flutter_pos/model/product_model.dart';
import 'package:flutter_pos/screens/myCars.dart';
import 'package:flutter_pos/utils/Provider/provider.dart';
import 'package:flutter_pos/utils/navigator.dart';
import 'package:flutter_pos/utils/screen_size.dart';
import 'package:flutter_pos/utils/service/API.dart';
import 'package:flutter_pos/widget/category/category_card.dart';
import 'package:flutter_pos/widget/hidden_menu.dart';
import 'package:flutter_pos/widget/product/product_card.dart';
import 'package:flutter_pos/widget/product/product_list_titlebar.dart';
import 'package:flutter_pos/widget/slider/Banner.dart';
import 'package:flutter_pos/widget/slider/slider_dot.dart';
import 'package:flutter_svg/svg.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Products> product;
  List<Products> productMostSale;
  List<Category> categories;
  List<CarType> cartype;

  PersistentTabController _controller;
  final navigatorKey = GlobalKey<NavigatorState>();

  List<Widget> _buildScreens() {
    return [HomePage(), Container(), Container(), Container()];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.home),
        title: ("الرئيسية"),
        activeColorPrimary: CupertinoColors.activeOrange,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.apps),
        title: ("الفئات"),
        activeColorPrimary: CupertinoColors.activeOrange,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.person),
        title: ("حسابى"),
        activeColorPrimary: CupertinoColors.activeOrange,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.cart),
        title: ("العربة"),
        activeColorPrimary: CupertinoColors.activeOrange,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }

  @override
  void initState() {
    _controller = PersistentTabController(initialIndex: 0);

    API(context).get('site/new/products').then((value) {
      if (value != null) {
        setState(() {
          product = Product_model.fromJson(value).data;
        });
      }
    });
    API(context).get('best/seller/products').then((value) {
      if (value != null) {
        setState(() {
          productMostSale = Product_model.fromJson(value).data;
        });
      }
    });
    API(context).get('fetch/categories/nested/part').then((value) {
      if (value != null) {
        setState(() {
          categories = Category_model.fromJson(value).data;
        });
      }
    });
    API(context).get('car/types/list').then((value) {
      if (value != null) {
        setState(() {
          cartype = Car_type.fromJson(value).data;
        });
      }
    });

    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Photo> sliders = [
    Photo(
        image:
            'https://cdn-sharing.adobecc.com/content/storage/id/urn:aaid:sc:US:642cddc5-5583-433a-92cc-56baee945e76;revision=0?component_id=996ae476-b356-4c68-b9d4-3d9b6b6e9416&api_key=CometServer1&access_token=1620676996_urn%3Aaaid%3Asc%3AUS%3A642cddc5-5583-433a-92cc-56baee945e76%3Bpublic_1c61409196c095dd29fd1e92f122a1deb24e63e9'),
    Photo(
        image:
            'https://i.pinimg.com/originals/0f/36/17/0f361741bf7c35e0aa795ea76c750a75.jpg'),
    Photo(
        image:
            'https://www.uniquefbcovers.com/covers/thumbs/bmw_m6_dark_knight_black_forest_fog_front_bumper_100117_1600x900.jpg')
  ];
  int _carouselCurrentPage = 0;
  String pathImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: HiddenMenu(),
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        confineInSafeArea: true,
        backgroundColor: Colors.white, // Default is Colors.white.
        handleAndroidBackButtonPress: true, // Default is true.
        resizeToAvoidBottomInset:
            true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
        stateManagement: true, // Default is true.
        hideNavigationBarWhenKeyboardShows:
            true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(10.0),
          colorBehindNavBar: Colors.white,
        ),
        popAllScreensOnTapOfSelectedTab: true,
        popActionScreens: PopActionScreensType.all,
        itemAnimationProperties: ItemAnimationProperties(
          // Navigation Bar's items animation properties.
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimation(
          // Screen transition animation on change of selected tab.
          animateTabTransition: true,
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

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: themeColor.getColor(),
            padding: const EdgeInsets.only(top: 35),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: ScreenUtil.getHeight(context) / 10,
                    width: ScreenUtil.getWidth(context) / 3,
                    fit: BoxFit.contain,
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    Nav.route(context, MyCars());
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/car2.svg',
                        fit: BoxFit.contain,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(themeColor.getCar_made())
                    ],
                  ),
                  color: Color(0xffE4E4E4),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                        context: context, builder: (_) => SearchOverlay());
                  },
                  icon: Icon(
                    Icons.search,
                    size: 30,
                  ),
                  color: Color(0xffE4E4E4),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          cartype == null
              ? Container()
              : GridView.builder(
                  primary: false,
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 1.3,
                    crossAxisCount: 2,
                  ),
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: cartype.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            CachedNetworkImage(
                              imageUrl:
                                  'https://cdn-sharing.adobecc.com/content/storage/id/urn:aaid:sc:US:642cddc5-5583-433a-92cc-56baee945e76;revision=0?component_id=be330167-fef4-4331-99a4-b679292092ee&api_key=CometServer1&access_token=1620676996_urn%3Aaaid%3Asc%3AUS%3A642cddc5-5583-433a-92cc-56baee945e76%3Bpublic_1c61409196c095dd29fd1e92f122a1deb24e63e9',
                              height: ScreenUtil.getHeight(context) / 10,
                              width: ScreenUtil.getWidth(context) / 2.5,
                              fit: BoxFit.contain,
                            ),
                            Text(cartype[index].typeName,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          CarouselSlider(
            items: sliders
                .map((item) => Banner_item(
                      item: item.image,
                    ))
                .toList(),
            options: CarouselOptions(
                autoPlay: true,
                height: 175,
                viewportFraction: 1.0,
                enlargeCenterPage: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    _carouselCurrentPage = index;
                  });
                }),
          ),
          SliderDot(_carouselCurrentPage, sliders),
          categories == null ? Container() : list_category(themeColor),
          ProductListTitleBar(
            themeColor: themeColor,
            title: 'وصل حديثاٌ',
            description: 'المزيد',
          ),
          product == null ? Container() : list_product(themeColor, product),
          Banner_item(
            item:
                'https://cdn-sharing.adobecc.com/content/storage/id/urn:aaid:sc:US:642cddc5-5583-433a-92cc-56baee945e76;revision=0?component_id=5e9637db-920d-4383-8c7c-a07baf8b03cb&api_key=CometServer1&access_token=1620676996_urn%3Aaaid%3Asc%3AUS%3A642cddc5-5583-433a-92cc-56baee945e76%3Bpublic_1c61409196c095dd29fd1e92f122a1deb24e63e9',
          ),
          Banner_item(
            item:
                'https://cdn-sharing.adobecc.com/content/storage/id/urn:aaid:sc:US:642cddc5-5583-433a-92cc-56baee945e76;revision=0?component_id=8e823848-272a-4a3c-a1e0-d769d6d98807&api_key=CometServer1&access_token=1620676996_urn%3Aaaid%3Asc%3AUS%3A642cddc5-5583-433a-92cc-56baee945e76%3Bpublic_1c61409196c095dd29fd1e92f122a1deb24e63e9',
          ),
          Banner_item(
            item:
                'https://cdn-sharing.adobecc.com/content/storage/id/urn:aaid:sc:US:642cddc5-5583-433a-92cc-56baee945e76;revision=0?component_id=996ae476-b356-4c68-b9d4-3d9b6b6e9416&api_key=CometServer1&access_token=1620676996_urn%3Aaaid%3Asc%3AUS%3A642cddc5-5583-433a-92cc-56baee945e76%3Bpublic_1c61409196c095dd29fd1e92f122a1deb24e63e9',
          ),
          ProductListTitleBar(
            themeColor: themeColor,
            title: 'الأكثر مبيعا',
            description: 'المزيد',
          ),
          productMostSale == null
              ? Container()
              : list_product(themeColor, productMostSale),
        ],
      ),
    );
  }

  Widget list_category(
    Provider_control themeColor,
  ) {
    return GridView.builder(
      primary: false,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 0.99,
        crossAxisCount: 3,
      ),
      itemCount: categories.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: CategoryCard(
            themeColor: themeColor,
            product: categories[index],
          ),
        );
      },
    );
  }

  Widget list_product(Provider_control themeColor, List<Products> product) {
    return GridView.builder(
      primary: false,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 0.77,
        crossAxisCount: 2,
      ),
      itemCount: product.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: ProductCard(
            themeColor: themeColor,
            product: product[index],
          ),
        );
      },
    );
  }
}
