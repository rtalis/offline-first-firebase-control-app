import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:it_control/main.dart';
import 'package:it_control/models/event.dart';
import 'package:it_control/models/input.dart';
import 'package:it_control/models/local.dart';
import 'package:it_control/models/object.dart';
import 'package:it_control/models/person.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:it_control/utils/string_utils.dart';
import 'package:provider/provider.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});
  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final formKey = GlobalKey<FormState>();
  Event event = Event();
  TimeOfDay time = TimeOfDay.now();

  List<String> eventList = [
    "Atendimento com insumo",
    "Atendimento sem insumo",
    "Hardware enviado para...",
    "Hardware recebido em...",
  ];

  String? selectedEvent;
  DateTime datetime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    event.dateTime = Timestamp.fromDate(DateTime.now());
    var appState = context.watch<MyAppState>();
    var objectsList = appState.baseObjects;
    var peopleList = appState.basePeople;
    var localList = appState.baseLocal;
    var inputList = appState.baseInput;

    return Builder(
      builder: (context) {
        return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.indigo.shade100,
              title: const Text('Create New Event'),
            ),
            body: Container(
              color: Theme.of(context).canvasColor,
              child: Form(
                key: formKey,
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextDateTime(
                              event: event,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownTypeEvent(
                                event: event, eventList: eventList),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownLocalEvent(
                                event: event, localList: localList),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SearchObject(
                                event: event, objectList: objectsList),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:
                                SearchInput(event: event, inputList: inputList),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SearchPeople(
                                event: event, peopleList: peopleList),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormDetails(event: event),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                event.id =
                                    'event-${DateFormat("yyyy_MM_dd-HH_mm_ss.SS").format(DateTime.now())}-${getRandomString(10)}';
                                appState.storage.insertEvent(event);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      backgroundColor: Colors.lightGreen,
                                      content:
                                          Text('Event created sucessully!')),
                                );
                                Future.delayed(const Duration(seconds: 3))
                                    .then((val) {
                                  Navigator.pop(context);
                                });
                              }
                            },
                            child: const Text("Create"),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }
}

class DropdownTypeEvent extends StatefulWidget {
  const DropdownTypeEvent({
    super.key,
    required this.event,
    required this.eventList,
  });

  final Event event;
  final List<String> eventList;

  @override
  State<DropdownTypeEvent> createState() => _DropdownTypeEventState();
}

class _DropdownTypeEventState extends State<DropdownTypeEvent> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      //value: widget,
      onChanged: (String? value) {
        setState(
          () {
            widget.event.typeEvent = value;
            if (value != widget.eventList[0]) {
              widget.event.inputEvent = "Nenhum";
            }
          },
        );
      },
      items: widget.eventList.map((String event) {
        return DropdownMenuItem<String>(
          value: event,
          child: Text(event),
        );
      }).toList(),
      decoration: const InputDecoration(
        labelText: 'Type',
      ),
    );
  }
}

class TextDateTime extends StatefulWidget {
  const TextDateTime({
    super.key,
    required this.event,
  });

  final Event event;

  @override
  State<TextDateTime> createState() => _TextDateTimeState();
}

class _TextDateTimeState extends State<TextDateTime> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final selectedDateTime = await pickDateTime(context);
        setState(() {
          widget.event.dateTime = Timestamp.fromDate(selectedDateTime);
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Text(
              "New event in ${DateFormat.yMMMMEEEEd().format(DateTime.now())} at ${TimeOfDay.now().format(context)}",
              style: GoogleFonts.openSans(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          const Icon(Icons.edit),
        ],
      ),
    );
  }
}

class DropdownLocalEvent extends StatefulWidget {
  const DropdownLocalEvent({
    super.key,
    required this.event,
    required this.localList,
  });

  final Event event;
  final List<Local> localList;

  @override
  State<DropdownLocalEvent> createState() => _DropdownLocalEventState();
}

class _DropdownLocalEventState extends State<DropdownLocalEvent> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: 24,
      elevation: 10,
      onChanged: (String? newValue) {
        setState(() {
          widget.event.setLocalEvent = newValue;
        });
      },
      onSaved: (String? newValue) {
        widget.event.setLocalEvent = newValue;
      },
      items: widget.localList.map<DropdownMenuItem<String>>((Local value) {
        return DropdownMenuItem<String>(
          value: value.name ?? '',
          child: Text(value.name ?? ''),
        );
      }).toList(),
      decoration: const InputDecoration(
        labelText: 'Local',
      ),
    );
  }
}

class TextFormDetails extends StatelessWidget {
  const TextFormDetails({
    super.key,
    required this.event,
  });

  final Event event;

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return TextFormField(
      style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
      decoration: const InputDecoration(
        label: Text(
          "Descrição do evento",
        ),
      ),
      controller: controller,
      validator: (value) {
        // Check if the value is null or empty
        if (value!.isEmpty) {
          return "Please enter a description";
        }
        if (value.length < 5) {
          return "Please enter at least 5 characters";
        }
        event.descriptionEvent = controller.text;
        return null;
      },
    );
  }
}

class SearchObject extends StatefulWidget {
  const SearchObject({
    super.key,
    required this.event,
    required this.objectList,
  });
  final Event event;
  final List<ObjectEv> objectList;

  @override
  State<SearchObject> createState() => _SearchObjectState();
}

class _SearchObjectState extends State<SearchObject>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final TextEditingController _controller =
      TextEditingController(); // create a controller for the textfield
  @override
  Widget build(BuildContext context) {
    super.build(context);
    List<String> list =
        List.from(widget.objectList.map((map) => map.nameRegistration));
    list.sort();
    return TextFormField(
      style: TextStyle(
        color: Theme.of(context).colorScheme.onBackground,
      ),
      controller: _controller, // assign the controller to the textfield
      decoration: const InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        errorStyle: TextStyle(color: Colors.red),
        labelText: 'Objeto do evento',
        hintText: 'Objeto do evento',
        suffixIcon: Icon(Icons.search),
      ),
      onTap: () async {
        final result = await showSearch(
          context: context,
          delegate: DataSearch(list),
        );
        if (result != null) {
          widget.event.objectEvent = result;
          _controller.text = result; // set the textfield value to the result
        }
      },
      validator: (value) {
        // Check if the value is null or empty
        if (value!.isEmpty) {
          return "Please select an object";
        }
        if (value.length < 3) {
          return "Please enter at least 3 characters";
        }
        return null;
      },
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  final List<String> list;

  DataSearch(this.list);

  @override
  List<Widget> buildActions(BuildContext context) {
    //Actions for app bar
    return [
      IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    //leading icon on the left of the app bar
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: () {
          close(context, "");
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    // show some result based on the selection
    return Center(
      child: Text(query),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // show when someone searches for something
    final suggestionList = query.isEmpty
        ? list
        : list.where((String element) {
            return element.toLowerCase().contains(query.toLowerCase());
          }).toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          close(
              context,
              suggestionList[
                  index]); // close the search with the selected item as argument
        },
        //trailing: Icon(Icons.remove_red_eye),
        title: RichText(
          text: TextSpan(
              text: suggestionList[index].substring(0, query.length),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                    text: suggestionList[index].substring(query.length),
                    style: const TextStyle(color: Colors.grey))
              ]),
        ),
      ),
      itemCount: suggestionList.length,
    );
  }
}

class SearchPeople extends StatefulWidget {
  const SearchPeople(
      {super.key, required this.peopleList, required this.event});
  final List<Person> peopleList;
  final Event event;
  @override
  State<SearchPeople> createState() => _SearchPeopleState();
}

class _SearchPeopleState extends State<SearchPeople>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final TextEditingController _controller =
      TextEditingController(); // create a controller for the textfield
  @override
  Widget build(BuildContext context) {
    super.build(context);
    List<String> list = List.from(widget.peopleList.map((map) => map.nameID));
    list.sort();
    return TextFormField(
      style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
      controller: _controller, // assign the controller to the textfield
      decoration: const InputDecoration(
        labelText: 'Responsável do evento',
        hintText: 'Responsável do evento',
        suffixIcon: Icon(Icons.search),
      ),
      onTap: () async {
        final result = await showSearch(
          // await for the result from showSearch
          context: context,
          delegate: DataSearch(list),
        );
        if (result != null) {
          // if result is not null
          widget.event.personEvent = result;
          _controller.text = result; // set the textfield value to the result
        }
      },
      validator: (value) {
        // Check if the value is null or empty
        if (value!.isEmpty) {
          return "Please select a person";
        }
        if (value.length < 3) {
          return "Please enter at least 3 characters";
        }
        return null;
      },
    );
  }
}

class SearchInput extends StatefulWidget {
  const SearchInput(
      {super.key,
      required this.inputList,
      required this.event,
      primaryColorDark});
  final List<Input> inputList;
  final Event event;

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    List<String> list = List.from(widget.inputList.map((map) => map.name));
    list.sort();
    return TextFormField(
      style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
      controller: _controller,
      //initialValue: widget.event.inputEvent,
      decoration: const InputDecoration(
        labelText: 'Insumo utilizado',
        hintText: 'Insumo utilizado',
        suffixIcon: Icon(Icons.search),
      ),
      onTap: () async {
        if (widget.event.typeEvent != "Atendimento com insumo") {
          setState(() {
            _controller.text = widget.event.inputEvent!;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  backgroundColor: Colors.yellow,
                  content: Text(
                      style: TextStyle(color: Colors.black),
                      'Não há insumo para este tipo de evento')),
            );
          });
        } else {
          final result = await showSearch(
            // await for the result from showSearch
            context: context,
            delegate: DataSearch(list),
          );
          if (result != null) {
            // if result is not null
            widget.event.inputEvent = result;
            _controller.text = result; // set the textfield value to the result
          }
        }
      },
      validator: (value) {
        // Check if the value is null or empty
        if (value!.isEmpty) {
          return "Please select an input";
        }
        if (value.length < 3) {
          return "Please enter at least 3 characters";
        }
        return null;
      },
    );
  }
}

Future<DateTime> pickDateTime(context) async {
  var dateTime = DateTime.now();
  var time = TimeOfDay.now();
  final selectedDate = await showDatePicker(
    initialDate: dateTime,
    firstDate: DateTime(2000),
    lastDate: DateTime(2030),
    context: context,
  );

  if (selectedDate != null) {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: time,
    );

    if (selectedTime != null) {
      dateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      time = selectedTime;
    }
  }
  return dateTime;
}
