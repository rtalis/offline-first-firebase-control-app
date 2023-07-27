import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:it_control/main.dart';
import 'package:it_control/models/person.dart';
import 'package:it_control/utils/string_utils.dart';
import 'package:provider/provider.dart';

class CreatePersonScreen extends StatefulWidget {
  const CreatePersonScreen({Key? key}) : super(key: key);

  @override
  State<CreatePersonScreen> createState() => _CreatePersonScreenState();
}

class _CreatePersonScreenState extends State<CreatePersonScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _registrationController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    List<Person> peopleList = appState.basePeople;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Person'),
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
                        return 'Please enter the name';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Name',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    controller: _roleController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the role';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Role',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    controller: _registrationController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text("Write 0 if there's no registration"),
                          ),
                        );
                        return 'Please enter the registration';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Registration',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      var id =
                          'person-${DateFormat("yyyy_MM_dd-HH_mm_ss.SS").format(DateTime.now())}-${getRandomString(10)}';
                      Person newPerson = Person(
                          id: id,
                          role: _roleController.text,
                          name: _nameController.text,
                          registration: _registrationController.text,
                          nameID: "${_nameController.text} - $id");

                      if (objectExist(
                          _registrationController.text, peopleList)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Person already exists'),
                          ),
                        );
                        _registrationController.text = '';
                      } else {
                        appState.storage.insertPerson(newPerson);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.lightGreen,
                            content: Text('Created Successfully!'),
                          ),
                        );
                        appState.basePeople.add(newPerson);
                        Future.delayed(const Duration(seconds: 3)).then((_) {
                          Navigator.pop(context);
                        });
                      }
                    }
                  },
                  child: const Text('Create Person'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
