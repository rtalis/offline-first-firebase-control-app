import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:it_control/main.dart';
import 'package:it_control/models/event.dart';
import 'package:it_control/src/data/storage.dart';
import 'package:it_control/utils/string_utils.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  String _searchText = '';
  final List<String> _selectedFilters = [];
  bool _isLoading = true; 
  bool _empty = true;// Added isLoading variable
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 4000), () {
       if (_empty) {
         setState(() {
          _isLoading = false;
        });
       }
      
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    String searchChipText = '';
    var filteredEvents = appState.baseEvents.where((event) {
      final description = event.descriptionEvent ?? '';
      final object = event.objectEvent ?? '';
      final input = event.inputEvent ?? '';
      searchChipText += " $description $object $input ";
      // Check if the event matches the search text
      bool matchesSearchText =
          description.toLowerCase().contains(_searchText.toLowerCase()) ||
              object.toLowerCase().contains(_searchText.toLowerCase()) ||
              input.toLowerCase().contains(_searchText.toLowerCase());

      // Check if the event matches any of the selected filters
      bool matchesFilters = _selectedFilters.isEmpty
          ? true
          : _selectedFilters.any((element) =>
              description.toLowerCase().contains(element.toLowerCase()) ||
              object.toLowerCase().contains(element.toLowerCase()) ||
              input.toLowerCase().contains(element.toLowerCase()));

      return matchesSearchText && matchesFilters;
    }).toList();
    filteredEvents.sort((a, b) => b.dateTime!.compareTo(a.dateTime!));
    List<String> chipStrings = recommendedStrings(searchChipText);
    if (filteredEvents.isNotEmpty || !_isLoading) {
      setState(() {
        _isLoading = false;
        _empty = false;
      });
    }
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: TextField(
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Row(
                children:
                    _isLoading // Use _isLoading to show shimmer or filter chips
                        ? List<Widget>.generate(
                            chipStrings.length,
                            (index) => _buildShimmerFilterChip(),
                          )
                        : List<Widget>.generate(
                            chipStrings.length,
                            (index) {
                              final chipString = chipStrings[index];
                              return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: FilterChip(
                                  side: BorderSide(
                                    color: Colors.grey.shade200,
                                    width: 1.0,
                                    style: BorderStyle.solid,
                                  ),
                                  label: Text(chipString),
                                  selected:
                                      _selectedFilters.contains(chipString),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedFilters.add(chipString);
                                      } else {
                                        _selectedFilters.remove(chipString);
                                      }
                                    });
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ),
          ),
        ),
        _isLoading // Use _isLoading to show shimmer or event list
            ? _buildShimmerEventList()
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final event = filteredEvents[index];
                    return ListTile(
                      title: Text(event.descriptionEvent ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.objectEvent ?? '',
                            style: const TextStyle(fontSize: 12),
                          ),
                          //Text(event.inputEvent ?? ''),
                        ],
                      ),
                      leading:
                          Icon(getIconForText(event.descriptionEvent ?? '')),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EventDetailsPage(event: event),
                          ),
                        );
                      },
                    );
                  },
                  childCount: filteredEvents.length,
                ),
              ),
      ],
    );
  }

  Widget _buildShimmerFilterChip() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 30,
          width: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerEventList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: ListTile(
              title: Container(
                height: 10,
                width: 100,
                color: Colors.white,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 10,
                    width: 200,
                    color: Colors.white,
                  ),
                  Container(
                    height: 10,
                    width: 150,
                    color: Colors.white,
                  ),
                ],
              ),
              leading: Container(
                height: 40,
                width: 40,
                color: Colors.white,
              ),
            ),
          );
        },
        childCount: 5, // Display 5 shimmer events as a placeholder
      ),
    );
  }
}

class EventDetailsPage extends StatefulWidget {
  final Event event;

  const EventDetailsPage({Key? key, required this.event}) : super(key: key);

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  late TextEditingController _typeController;
  late TextEditingController _localController;
  late TextEditingController _objectController;
  late TextEditingController _inputController;
  late TextEditingController _personController;
  late TextEditingController _descriptionController;
  bool _isEditing = false;
  FirebaseStorage storage = FirebaseStorage();

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController(text: widget.event.typeEvent);
    _localController = TextEditingController(text: widget.event.localEvent);
    _objectController = TextEditingController(text: widget.event.objectEvent);
    _inputController = TextEditingController(text: widget.event.inputEvent);
    _personController = TextEditingController(text: widget.event.personEvent);
    _descriptionController =
        TextEditingController(text: widget.event.descriptionEvent);
  }

  @override
  Widget build(BuildContext context) {
    var detailsTitleTextStyle =
        TextStyle(fontSize: 12, color: Colors.grey.shade500);
    var detailsSubtitleTextStyle = const TextStyle(fontSize: 16);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.descriptionEvent!),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
              if (_isEditing) {
                // Save the edited event details
                Event updatedEvent = Event(
                  id: widget.event.id,
                  typeEvent: _typeController.text,
                  localEvent: _localController.text,
                  objectEvent: _objectController.text,
                  inputEvent: _inputController.text,
                  personEvent: _personController.text,
                  descriptionEvent: _descriptionController.text,
                  dateTime: widget.event.dateTime,
                );

                // Call the updateEvent function to update the event in Firebase
                storage.initSettingsDoc();
                storage.insertEvent(updatedEvent);
              }
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            titleTextStyle: detailsTitleTextStyle,
            subtitleTextStyle: detailsSubtitleTextStyle,
            title: const Text('Type'),
            subtitle: TextFormField(
              controller: _typeController,
              decoration: InputDecoration(
                hintText: 'Enter type...',
                border:
                    _isEditing ? const OutlineInputBorder() : InputBorder.none,
              ),
              enabled: _isEditing,
            ),
          ),
          ListTile(
            titleTextStyle: detailsTitleTextStyle,
            subtitleTextStyle: detailsSubtitleTextStyle,
            title: const Text('Local'),
            subtitle: TextFormField(
              controller: _localController,
              decoration: InputDecoration(
                hintText: 'Enter local...',
                border:
                    _isEditing ? const OutlineInputBorder() : InputBorder.none,
              ),
              enabled: _isEditing,
            ),
          ),
          ListTile(
            titleTextStyle: detailsTitleTextStyle,
            subtitleTextStyle: detailsSubtitleTextStyle,
            title: const Text('Object'),
            subtitle: TextFormField(
              controller: _objectController,
              decoration: InputDecoration(
                hintText: 'Enter object...',
                border:
                    _isEditing ? const OutlineInputBorder() : InputBorder.none,
              ),
              enabled: _isEditing,
            ),
          ),
          ListTile(
            titleTextStyle: detailsTitleTextStyle,
            subtitleTextStyle: detailsSubtitleTextStyle,
            title: const Text('Input'),
            subtitle: TextFormField(
              controller: _inputController,
              decoration: InputDecoration(
                hintText: 'Enter input...',
                border:
                    _isEditing ? const OutlineInputBorder() : InputBorder.none,
              ),
              enabled: _isEditing,
            ),
          ),
          ListTile(
            titleTextStyle: detailsTitleTextStyle,
            subtitleTextStyle: detailsSubtitleTextStyle,
            title: const Text('Responsible'),
            subtitle: TextFormField(
              controller: _personController,
              decoration: InputDecoration(
                hintText: 'Enter person responsible...',
                border:
                    _isEditing ? const OutlineInputBorder() : InputBorder.none,
              ),
              enabled: _isEditing,
            ),
          ),
          ListTile(
            titleTextStyle: detailsTitleTextStyle,
            subtitleTextStyle: detailsSubtitleTextStyle,
            title: const Text('Date'),
            subtitle: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                style:
                    TextStyle(color: _isEditing ? Colors.black : Colors.grey),
                DateFormat('dd/MM/yyyy – kk:mm')
                    .format(widget.event.dateTime!.toDate()),
              ),
            ),
          ),
          ListTile(
            titleTextStyle: detailsTitleTextStyle,
            subtitleTextStyle: detailsSubtitleTextStyle,
            title: const Text('Description'),
            subtitle: TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Enter description...',
                border:
                    _isEditing ? const OutlineInputBorder() : InputBorder.none,
              ),
              enabled: _isEditing,
            ),
          ),
        ],
      ),
    );
  }
}

IconData getIconForText(String text) {
  if (text.toLowerCase().contains("placa mãe")) {
    return Icons.developer_board;
  } else if (text.toLowerCase().contains("nobreak")) {
    return Icons.power;
  } else if (text.toLowerCase().contains("estabilizador")) {
    return Icons.power;
  } else if (text.toLowerCase().contains("cartucho")) {
    return Icons.print;
  } else if (text.toLowerCase().contains("tinta")) {
    return Icons.format_paint;
  } else if (text.toLowerCase().contains("toner")) {
    return Icons.adf_scanner_sharp;
  } else if (text.toLowerCase().contains("monitor")) {
    return Icons.display_settings_rounded;
  } else if (text.toLowerCase().contains("mouse")) {
    return Icons.mouse;
  } else if (text.toLowerCase().contains("teclado")) {
    return Icons.keyboard;
  } else if (text.toLowerCase().contains("hdd")) {
    return Icons.disc_full;
  } else if (text.toLowerCase().contains("ssd")) {
    return Icons.sd_storage_outlined;
  } else if (text.toLowerCase().contains("memória")) {
    return Icons.memory;
  } else if (text.toLowerCase().contains("impressora")) {
    return Icons.print;
  } else if (text.toLowerCase().contains("computador")) {
    return Icons.computer_outlined;
  } else {
    return Icons.numbers_rounded;
  }
}
