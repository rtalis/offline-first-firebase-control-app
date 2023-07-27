import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:it_control/models/event.dart';
import 'package:it_control/models/input.dart';
import 'package:it_control/models/local.dart';
import 'package:it_control/models/object.dart';
import 'package:it_control/models/person.dart';
import 'package:it_control/screens/add_input.dart';
import 'package:it_control/screens/add_local.dart';
import 'package:it_control/screens/add_person.dart';
import 'package:it_control/screens/home/events_screen.dart';
import 'package:it_control/screens/home/add_events_screen.dart';
import 'package:it_control/screens/add_objects.dart';
import 'package:it_control/screens/list.dart';
import 'package:it_control/src/data/storage.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initializeDateFormatting();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'IT Control App',
        theme: ThemeData(
          textTheme: Typography.blackCupertino,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent),
          inputDecorationTheme: InputDecorationTheme(
            hintStyle: GoogleFonts.openSans(
              color: Colors.black,
              fontSize: 16,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum Option {
  event,
  object,
  responsible,
  input,
  local,
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  Option selectedOption = Option.event;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyAppState>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleLarge?.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    Widget page;
    switch (selectedIndex) {
      case 1:
        page = const DefaultTabController(
          length: 4, // Number of tabs
          child: TabbedScreen(),
        );
        break;
      case 0:
        page = const EventsPage();
        break;

      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('IT Control App'),
        titleTextStyle: style,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Center(
        child: Container(
          color: theme.colorScheme.background,
          child: page,
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showOptionsDialog();
          },
          child: const Icon(Icons.add)),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            label: 'View',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        backgroundColor: theme.colorScheme.primary,
        selectedItemColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  void _showOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select an option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Event'),
                onTap: () {
                  setState(
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddEventPage(),
                        ),
                      );
                      selectedOption = Option.event;
                    },
                  );
                },
              ),
              ListTile(
                title: const Text('Object'),
                onTap: () {
                  setState(
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateObjectScreen(),
                        ),
                      );
                      selectedOption = Option.object;
                    },
                  );
                },
              ),
              ListTile(
                title: const Text('Person'),
                onTap: () {
                  setState(
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreatePersonScreen(),
                        ),
                      );
                      selectedOption = Option.object;
                    },
                  );
                },
              ),
              ListTile(
                title: const Text('Input'),
                onTap: () {
                  setState(
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateInputScreen(),
                        ),
                      );
                      selectedOption = Option.object;
                    },
                  );
                },
              ),
              ListTile(
                title: const Text('Local'),
                onTap: () {
                  setState(
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateLocalScreen(),
                        ),
                      );
                      selectedOption = Option.object;
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class MyAppState extends ChangeNotifier {
  final FirebaseStorage storage = FirebaseStorage();
  List<ObjectEv> baseObjects = [];
  List<Person> basePeople = [];
  List<Input> baseInput = [];
  List<Local> baseLocal = [];
  List<Event> baseEvents = [];

  Future<void> loadData() async {
    var deviceID = await storage.initSettingsDoc();
    debugPrint(deviceID);
    baseObjects = await storage.loadObjects();
    baseObjects.sort((b, a) => b.name!.compareTo(a.name!));
    basePeople = await storage.loadPeople();
    basePeople.sort((b, a) => b.name!.compareTo(a.name!));
    baseInput = await storage.loadInputs();
    baseInput.sort((b, a) => b.name!.compareTo(a.name!));
    baseLocal = await storage.loadLocals();
    baseLocal.sort((b, a) => b.name!.compareTo(a.name!));
    baseEvents = await storage.loadEvents();
    baseEvents
        .sort((a, b) => b.dateTime!.toDate().compareTo(a.dateTime!.toDate()));
    notifyListeners();
  }
}
