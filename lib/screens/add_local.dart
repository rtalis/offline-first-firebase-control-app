import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:it_control/main.dart';
import 'package:it_control/models/local.dart';
import 'package:it_control/utils/string_utils.dart';
import 'package:provider/provider.dart';

class CreateLocalScreen extends StatefulWidget {
  const CreateLocalScreen({Key? key}) : super(key: key);

  @override
  State<CreateLocalScreen> createState() => _CreateLocalScreenState();
}

class _CreateLocalScreenState extends State<CreateLocalScreen> {
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    List<Local> localList = appState.baseLocal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Local'),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Theme.of(context).canvasColor,
          padding: const EdgeInsets.all(8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the local name';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Name',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      var id =
                          'local-${DateFormat("yyyy_MM_dd-HH_mm_ss.SS").format(DateTime.now())}-${getRandomString(10)}';
                      Local newLocal = Local(
                        id: id,
                        name: _nameController.text,
                      );

                      if (localList.any((local) =>
                          local.name!.toLowerCase() ==
                          _nameController.text.toLowerCase())) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Local already exists'),
                          ),
                        );
                      } else {
                        appState.storage.insertLocal(newLocal);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.lightGreen,
                            content: Text('Created Successfully!'),
                          ),
                        );
                        appState.baseLocal.add(newLocal);
                        Future.delayed(const Duration(seconds: 3)).then((_) {
                          Navigator.pop(context);
                        });
                      }
                    }
                  },
                  child: const Text('Create Local'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
