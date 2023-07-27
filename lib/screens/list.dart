import 'package:flutter/material.dart';
import 'package:it_control/main.dart';
import 'package:it_control/models/input.dart';
import 'package:it_control/models/local.dart';
import 'package:it_control/models/object.dart';
import 'package:it_control/models/person.dart';
import 'package:it_control/src/data/storage.dart';
import 'package:it_control/utils/string_utils.dart';
import 'package:provider/provider.dart';

class TabbedScreen extends StatefulWidget {
  const TabbedScreen({super.key});

  @override
  State<TabbedScreen> createState() => _TabbedScreenState();
}

class _TabbedScreenState extends State<TabbedScreen> {
  late List<Local> localList;
  late List<Person> peopleList;
  late List<Input> inputList;
  late List<ObjectEv> objectList;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var storage = appState.storage;
    localList = appState.baseLocal;
    peopleList = appState.basePeople;
    inputList = appState.baseInput;
    objectList = appState.baseObjects;
    return Scaffold(
      body: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Local'),
              Tab(text: 'People'),
              Tab(text: 'Input'),
              Tab(text: 'Objects'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                LocalTab(localList,storage),
                PeopleTab(peopleList, storage),
                InputTab(inputList, storage),
                ObjectTab(objectList,storage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LocalTab extends StatelessWidget {
  final List<Local> localList;
  final FirebaseStorage storage;
  const LocalTab(this.localList, this.storage, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: localList.length,
      itemBuilder: (context, index) {
        final local = localList[index];
        return ListTile(
          title: Text(local.name!),
          subtitle: Text(local.id!),
          onTap: () {
         Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LocalDetailsPage(
                    local: local, storage: storage, localList: localList),
              ),
            );
          },
        );
      },
    );
  }
}

class PeopleTab extends StatelessWidget {
  final List<Person> peopleList;
  final FirebaseStorage storage;

  const PeopleTab(this.peopleList, this.storage, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: peopleList.length,
      itemBuilder: (context, index) {
        final person = peopleList[index];
        return ListTile(
          title: Text(person.name!),
          subtitle: Text(person.role!),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PersonDetailsPage(
                    person: person, storage: storage, peopleList: peopleList),
              ),
            );
          },
        );
      },
    );
  }
}

class InputTab extends StatelessWidget {
  final List<Input> inputList;
  final FirebaseStorage storage;
  const InputTab(this.inputList, this.storage, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: inputList.length,
      itemBuilder: (context, index) {
        final input = inputList[index];
        return ListTile(
          title: Text(input.name!),
          subtitle: Text(input.id!),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InputDetailsPage(
                    input: input, storage: storage, inputList: inputList),
              ),
            );
          },
        );
      },
    );
  }
}

class ObjectTab extends StatelessWidget {
  final List<ObjectEv> objectList;
  final FirebaseStorage storage;

  const ObjectTab(this.objectList, this.storage, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: objectList.length,
      itemBuilder: (context, index) {
        final object = objectList[index];
        return ListTile(
          title: Text(object.nameRegistration!),
          subtitle: Text(object.local!),
           onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ObjectEvDetailsPage(
                    objectEv: object, storage: storage, objectEvList: objectList),
              ),
            );
          },
        );
      },
    );
  }
}

class PersonDetailsPage extends StatefulWidget {
  final Person person;
  final List<Person> peopleList;
  final FirebaseStorage storage;

  const PersonDetailsPage(
      {Key? key,
      required this.person,
      required this.storage,
      required this.peopleList})
      : super(key: key);

  @override
  State<PersonDetailsPage> createState() => _PersonDetailsPageState();
}

class _PersonDetailsPageState extends State<PersonDetailsPage> {
  late TextEditingController _roleController;
  late TextEditingController _nameController;
  late TextEditingController _registrationController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _roleController = TextEditingController(text: widget.person.role);
    _nameController = TextEditingController(text: widget.person.name);
    _registrationController =
        TextEditingController(text: widget.person.registration);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.person.name!),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              setState(() {
                if (_formKey.currentState!.validate()) {
                  // Save the edited person details
                  Person updatedPerson = Person(
                    id: widget.person.id,
                    role: _roleController.text,
                    name: _nameController.text,
                    registration: _registrationController.text,
                  );
                  widget.storage.insertPerson(updatedPerson);
                  int index = widget.peopleList
                      .indexWhere((person) => person.id == widget.person.id);
                  widget.peopleList[index] = updatedPerson;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        backgroundColor: Colors.lightGreen,
                        content: Text('Updated sucessully!')),
                  );
                  Future.delayed(const Duration(seconds: 3)).then((val) {
                    Navigator.pop(context);
                  });
                }
              });
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: 'Name',
                  floatingLabelBehavior: FloatingLabelBehavior.always),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a name.';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _roleController,
              decoration: const InputDecoration(
                  labelText: 'Role',
                  floatingLabelBehavior: FloatingLabelBehavior.always),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a role.';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _registrationController,
              decoration: const InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: 'Registration',
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a registration.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class InputDetailsPage extends StatefulWidget {
  final Input input;
  final List<Input> inputList;
  final FirebaseStorage storage;

  const InputDetailsPage({
    Key? key,
    required this.input,
    required this.inputList,
    required this.storage,
  }) : super(key: key);

  @override
  State<InputDetailsPage> createState() => _InputDetailsPageState();
}

class _InputDetailsPageState extends State<InputDetailsPage> {
  late TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.input.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.input.name!),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              setState(() {
                if (_formKey.currentState!.validate()) {
                  // Save the edited input details
                  Input updatedInput = Input(
                    id: widget.input.id,
                    name: _nameController.text,
                  );
                  widget.storage.insertInput(updatedInput);
                  int index = widget.inputList
                      .indexWhere((input) => input.id == widget.input.id);
                  widget.inputList[index] = updatedInput;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.lightGreen,
                      content: Text('Updated successfully!'),
                    ),
                  );
                  Future.delayed(const Duration(seconds: 3)).then((val) {
                    Navigator.pop(context);
                  });
                }
              });
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a name.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class LocalDetailsPage extends StatefulWidget {
  final Local local;
  final List<Local> localList;
  final FirebaseStorage storage;

  const LocalDetailsPage({
    Key? key,
    required this.local,
    required this.localList,
    required this.storage,
  }) : super(key: key);

  @override
  State<LocalDetailsPage> createState() => _LocalDetailsPageState();
}

class _LocalDetailsPageState extends State<LocalDetailsPage> {
  late TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.local.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.local.name!),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Save the edited local details
                Local updatedLocal = Local(
                  id: widget.local.id,
                  name: _nameController.text,
                );
                widget.storage.insertLocal(updatedLocal);
                int index = widget.localList
                    .indexWhere((local) => local.id == widget.local.id);
                widget.localList[index] = updatedLocal;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.lightGreen,
                    content: Text('Updated successfully!'),
                  ),
                );
                Future.delayed(const Duration(seconds: 3)).then((val) {
                  Navigator.pop(context);
                });
              }
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a name.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
class ObjectEvDetailsPage extends StatefulWidget {
  final ObjectEv objectEv;
  final List<ObjectEv> objectEvList;
  final FirebaseStorage storage;

  const ObjectEvDetailsPage({
    Key? key,
    required this.objectEv,
    required this.objectEvList,
    required this.storage,
  }) : super(key: key);

  @override
  State<ObjectEvDetailsPage> createState() => _ObjectEvDetailsPageState();
}

class _ObjectEvDetailsPageState extends State<ObjectEvDetailsPage> {
  late TextEditingController _localController;
  late TextEditingController _nameController;
  late TextEditingController _registrationController;
  late TextEditingController _typeController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _localController = TextEditingController(text: widget.objectEv.local);
    _nameController = TextEditingController(text: widget.objectEv.name);
    _registrationController =
        TextEditingController(text: widget.objectEv.registration);
    _typeController = TextEditingController(text: widget.objectEv.type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.objectEv.name!),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Save the edited objectEv details
                ObjectEv updatedObjectEv = ObjectEv(
                  id: widget.objectEv.id,
                  local: _localController.text,
                  name: _nameController.text,
                  registration: _registrationController.text,
                  type: _typeController.text,
                  nameRegistration: "${capitalize(_nameController.text)} - ${_registrationController.text}",
                );
                widget.storage.insertObject(updatedObjectEv);
                int index = widget.objectEvList
                    .indexWhere((objectEv) => objectEv.id == widget.objectEv.id);
                widget.objectEvList[index] = updatedObjectEv;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.lightGreen,
                    content: Text('Updated successfully!'),
                  ),
                );
                Future.delayed(const Duration(seconds: 3)).then((val) {
                  Navigator.pop(context);
                });
              }
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _localController,
              decoration: const InputDecoration(
                labelText: 'Local',
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a local.';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a name.';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _registrationController,
              decoration: const InputDecoration(
                labelText: 'Registration',
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a registration.';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: 'Type',
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a type.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
