import 'package:flutter/material.dart';
import 'package:flutter_pos/screens/product/products_page.dart';
import 'package:flutter_pos/utils/Provider/provider.dart';
import 'package:flutter_pos/utils/navigator.dart';

class ProductListTitleBar extends StatelessWidget {
  const ProductListTitleBar({
    Key key,
    @required this.themeColor,
    this.title,
    this.description,
    this.url,
  }) : super(key: key);

  final Provider_control themeColor;
  final String title;
  final String description;
  final String url;

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.only(bottom: 8.0,top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
            ),
            child: Text(
              "$title",
              maxLines: 1,
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          InkWell(
            onTap: (){
              Nav.route(context, Products_Page(Url:url,name:"$title" ,));
            },
            child: Padding(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              child: Text(
                "${description ?? ' '}",
                maxLines: 1,
                style: TextStyle(
                  fontSize: 15,
                  decoration: TextDecoration.underline,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
