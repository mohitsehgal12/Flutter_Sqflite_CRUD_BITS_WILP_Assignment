import 'package:assignment_bits_wilp/sql_helper.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove the debug banner
      debugShowCheckedModeBanner: false,
      title: 'BITS_WILP_ASSIGNMENT_Application',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Montserrat',
        textTheme: const TextTheme(
          headline6: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          subtitle1: TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        cardTheme: const CardTheme(
          color: Colors.deepPurpleAccent,
          elevation: 5,
          margin: EdgeInsets.all(15),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.deepPurple,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _persondetails = [];

  bool _isLoading = true;

  // This function is used to fetch all data from the database
  void _refreshpersondetails() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _persondetails = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshpersondetails(); // Loading the diary when the app starts
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingpersondetail = _persondetails.firstWhere((element) => element['id'] == id);
      _titleController.text = existingpersondetail['title'];
      _descriptionController.text = existingpersondetail['description'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => SingleChildScrollView(
      child: Container(
      padding: EdgeInsets.only(
      top: 15,
      left: 15,
      right: 15,
      bottom: MediaQuery.of(context).viewInsets.bottom + 120,
    ),
    child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
    TextField(
    controller: _titleController,
    decoration: InputDecoration(
    hintText: 'Person Name',
    filled: true,
    fillColor: Colors.grey[200],
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    ),
    ),
    const SizedBox(
    height: 10,
    ),
    TextField(
      controller: _descriptionController,
      decoration: InputDecoration(
        hintText: 'Person Age',
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    ),
      const SizedBox(
        height: 20,
      ),
      ElevatedButton(
        onPressed: () async {
          // Save new persondetail
          if (id == null) {
            await _addItem();
          }

          if (id != null) {
            await _updateItem(id);
          }

          // Clear the text fields
          _titleController.text = '';
          _descriptionController.text = '';

          // Close the bottom sheet
          Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.deepPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
        child: Text(
          id == null ? 'Create Person Entry' : 'Update',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ],
    ),
      ),
        ),
    );
  }

  // Insert a new persondetail to the database
  Future<void> _addItem() async {
    await SQLHelper.createItem(
      _titleController.text,
      _descriptionController.text,
    );
    _refreshpersondetails();
  }

  // Update an existing persondetail
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
      id,
      _titleController.text,
      _descriptionController.text,
    );
    _refreshpersondetails();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully deleted Person Details'),
      ),
    );
    _refreshpersondetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Person List (BITS Pilani WILP)'),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Person Name')),
            DataColumn(label: Text('Person Age')),
            DataColumn(label: Text('Actions')),
          ],
          rows: _persondetails.map((item) {
            final int id = item['id'];
            final String title = item['title'];
            final String description = item['description'];

            return DataRow(
              cells: [
                DataCell(Text(title)),
                DataCell(Text(description)),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showForm(id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteItem(id),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
