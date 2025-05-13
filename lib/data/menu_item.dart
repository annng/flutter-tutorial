/// YApi QuickType插件生成，具体参考文档:https://plugins.jetbrains.com/plugin/18847-yapi-quicktype/documentation

import 'dart:convert';

MenuItem menuItemFromJson(String str) => MenuItem.fromJson(json.decode(str));

String menuItemToJson(MenuItem data) => json.encode(data.toJson());

class MenuItem {
  MenuItem({required this.title, required this.slug, required this.route});

  String title;
  String slug;
  String route;

  factory MenuItem.fromJson(Map<dynamic, dynamic> json) =>
      MenuItem(title: json["title"], slug: json["slug"], route: json["route"]);

  Map<dynamic, dynamic> toJson() => {"title": title, "slug": slug};
}
