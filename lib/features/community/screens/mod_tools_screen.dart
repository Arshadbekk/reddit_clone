import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class ModToolScreen extends StatelessWidget {
  final String name;
  const ModToolScreen({super.key,required this.name});
  void navigateToModTools(BuildContext context){Routemaster.of(context).push("/edit-community/$name");

  }
  void navigateToAddModTools(BuildContext context){Routemaster.of(context).push("/add-mods/$name");

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mod Tools"),
      ),
      body: Column(
        children: [
          ListTile(
            leading: Icon(Icons.add_moderator),
            title: Text('Add Moderators'),
            onTap: () {
              navigateToAddModTools(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit Community'),
            onTap: () {
                navigateToModTools(context);
            },
          ),
        ],
      ),
    );
  }
}
