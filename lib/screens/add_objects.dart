import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:it_control/main.dart';
import 'package:it_control/models/object.dart';
import 'package:it_control/utils/string_utils.dart';
import 'package:provider/provider.dart';

class CreateObjectScreen extends StatefulWidget {
  const CreateObjectScreen({super.key});
  @override
  State<CreateObjectScreen> createState() => _CreateObjectScreenState();
}

class _CreateObjectScreenState extends State<CreateObjectScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  final TextEditingController _registrationController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _selectedLocal;
  List<ObjectEv> objects = [];
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    objects = appState.baseObjects;
    return Builder(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Create New Object'),
          ),
          body: SingleChildScrollView(
            child: Container(
              color: Theme.of(context).canvasColor,
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<String>(
                        value: _selectedLocal,
                        onChanged: (value) {
                          setState(() {
                            _selectedLocal = value;
                          });
                        },
                        items: appState.baseLocal.map((local) {
                          return DropdownMenuItem<String>(
                            value: local.name,
                            child: Text(local.name!),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Local',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
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
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _typeController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the type';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Type',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _registrationController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(
                                      "Write 0 if there's no registration")),
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
                              'object-${DateFormat("yyyy_MM_dd-HH_mm_ss.SS").format(DateTime.now())}-${getRandomString(10)}';
                          ObjectEv newObject = ObjectEv(
                              id: id,
                              local: _selectedLocal,
                              name: _nameController.text,
                              registration: _registrationController.text,
                              type: _typeController.text,
                              nameRegistration:
                                  "${capitalize(_nameController.text)} - ${_registrationController.text}");
                          if (objectExist(
                              _registrationController.text, objects)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text('Object already exist')),
                            );
                            _registrationController.text = "";
                          } else {
                            appState.storage.insertObject(newObject);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  backgroundColor: Colors.lightGreen,
                                  content: Text('Created Sucessfully!')),
                            );
                            appState.baseObjects.add(newObject);
                            Future.delayed(const Duration(seconds: 3))
                                .then((val) {
                              Navigator.pop(context);
                            });
                          }
                        }
                      },
                      child: const Text('Create Object'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
