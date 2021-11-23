import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          const DrawerHeader(child: Text('Drawer Header')),
          const Divider(),
          ListTile(
            title: Text("Home"),
            onTap: () => Get.offAndToNamed("/home"),
          ),
          ListTile(
            title: Text("Lesson"),
            onTap: () => Get.offAndToNamed("/lesson"),
          ),
        ],
      ),
    );
  }
}
