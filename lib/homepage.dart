import 'dart:ui';
import 'package:flutter/material.dart';
import 'sql_helper.dart';
import 'diary_card.dart';
import 'drawer_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _diaries = [];
  bool _isLoading = true;
  List<bool> _selectedDiaries = [];
  bool _isDarkMode = true; // Track the current theme mode

  // Toggle between dark and light theme
  void _toggleThemeMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _refreshDiaries() async {
    final data = await SQLHelper.getDiaries();
    setState(() {
      _diaries = data.reversed.toList();
      _isLoading = false;
      _selectedDiaries = List.generate(data.length, (index) => false);
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshDiaries();
  }

  final TextEditingController _descriptionController = TextEditingController();
  String _selectedFeeling = 'Happy';
  final List<String> _feelings = [
    'Happy',
    'Sad',
    'Angry',
    'Frust',
    'Sleepy',
    'Others',
  ];

  void _showForm(int? id) async {
    if (id != null) {
      final existingDiary = _diaries.firstWhere((element) => element['id'] == id);
      setState(() {
        _selectedFeeling = existingDiary['feeling'];
        _descriptionController.text = existingDiary['description'];
      });
    } else {
      _selectedFeeling = 'Happy';
      _descriptionController.text = '';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: _isDarkMode ? Colors.black87 : Colors.grey[200],
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              15,
              15,
              15,
              MediaQuery.of(context).viewInsets.bottom + 120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedFeeling,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedFeeling = newValue!;
                    });
                  },
                  items: _feelings.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: _isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                  dropdownColor: _isDarkMode ? Colors.black : Colors.white,
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Feeling',
                    labelStyle: TextStyle(
                      color: _isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(
                      color: _isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (id == null) {
                      await _addDiary();
                    } else {
                      await _updateDiary(id);
                    }
                    _descriptionController.clear();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    id == null ? 'Create New' : 'Update',
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      _isDarkMode ? Colors.white12 : Colors.grey[300]!,
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    minimumSize: MaterialStateProperty.all<Size>(
                      Size(double.infinity, 45),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addDiary() async {
    await SQLHelper.createDiary(
      _selectedFeeling,
      _descriptionController.text,
    );
    _refreshDiaries();
  }

  Future<void> _updateDiary(int id) async {
    await SQLHelper.updateDiary(
      id,
      _selectedFeeling,
      _descriptionController.text,
    );
    _refreshDiaries();
  }

  Future<void> _deleteDiary(int id) async {
    await SQLHelper.deleteDiary(id);
    _refreshDiaries();
  }

  void _toggleDeleteDiary(int index) {
    setState(() {
      _selectedDiaries[index] = !_selectedDiaries[index];
    });
  }

  void _deleteSelectedDiaries() async {
    final selectedIds = _selectedDiaries
        .asMap()
        .entries
        .where((entry) => entry.value)
        .map((entry) => _diaries[entry.key]['id'])
        .toList();
    for (final id in selectedIds) {
      await _deleteDiary(id);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Successfully deleted a diary!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    setState(() {
      _selectedDiaries = List.generate(_diaries.length, (index) => false);
    });
  }

  String getGifImagePath(String feeling) {
    switch (feeling) {
      case 'happy':
        return 'assets/images/happy.png';
      case 'sad':
        return 'assets/images/sad.png';
      case 'angry':
        return 'assets/images/angry.png';
      case 'sleepy':
        return 'assets/images/sleepy.png';
      case 'frust':
        return 'assets/images/frust.png';
      case 'others':
        return 'assets/images/others.png';
      default:
        return '';
    }
  }

  Widget _buildDiaryCard(Map<String, dynamic> diary, int index) {
    final String feeling = diary['feeling'].toLowerCase();
    final String gifImagePath = getGifImagePath(feeling);

    return DiaryCard(
      diary: diary,
      index: index,
      isDarkMode: _isDarkMode,
      gifImagePath: gifImagePath,
      selectedDiaries: _selectedDiaries,
      onShowForm: _showForm,
      onDeleteDiary: _deleteDiary,
      onToggleDeleteDiary: _toggleDeleteDiary,
    );
  }

  Widget _buildDiaryList() {
    return ListView.builder(
      itemCount: _diaries.length,
      itemBuilder: (context, index) =>
          _buildDiaryCard(_diaries[_diaries.length - 1 - index], _diaries.length - 1 - index),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  void _refreshPage() {
    _refreshDiaries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: GestureDetector(
          onTap: _refreshPage,
          child: Text(
            "Fatih's Diary",
            style: TextStyle(
              color: _isDarkMode ? Colors.white70 : Colors.black,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: _isDarkMode ? Colors.black26 : Colors.white60,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: _isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: _isDarkMode ? AssetImage('assets/images/background.jpg') : AssetImage('assets/images/2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: _isLoading ? _buildLoadingIndicator() : _buildDiaryList(),
      ),
      floatingActionButton: _selectedDiaries.contains(true)
          ? FloatingActionButton(
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
              backgroundColor: Colors.red.withOpacity(0.5),
              elevation: 1,
              onPressed: _deleteSelectedDiaries,
            )
          : FloatingActionButton(
              child: Icon(
                Icons.add,
                color: _isDarkMode ? Colors.white70 : Colors.black45,
              ),
              backgroundColor: _isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.89),
              elevation: 1,
              onPressed: () => _showForm(null),
            ),
      drawer: DrawerMenu(
        isDarkMode: _isDarkMode,
        onToggleThemeMode: _toggleThemeMode,
      ),
    );
  }
}
