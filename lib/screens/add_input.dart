import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:it_control/main.dart';
import 'package:it_control/models/input.dart';
import 'package:it_control/utils/string_utils.dart';
import 'package:provider/provider.dart';

class CreateInputScreen extends StatefulWidget {
  const CreateInputScreen({Key? key}) : super(key: key);

  @override
  State<CreateInputScreen> createState() => _CreateInputScreenState();
}

class _CreateInputScreenState extends State<CreateInputScreen> {
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    List<Input> inputList = appState.baseInput;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Input'),
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
                        return 'Please enter the input name';
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
                          'input-${DateFormat("yyyy_MM_dd-HH_mm_ss.SS").format(DateTime.now())}-${getRandomString(10)}';
                      Input newInput = Input(
                        id: id,
                        name: _nameController.text,
                      );

                      if (inputList.any((input) =>
                          input.name!.toLowerCase() ==
                          _nameController.text.toLowerCase())) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Input already exists'),
                          ),
                        );
                      } else {
                        appState.storage.insertInput(newInput);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.lightGreen,
                            content: Text('Created Successfully!'),
                          ),
                        );
                        appState.baseInput.add(newInput);
                        Future.delayed(const Duration(seconds: 3)).then((_) {
                          Navigator.pop(context);
                        });
                      }
                    }
                  },
                  child: const Text('Create Input'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
