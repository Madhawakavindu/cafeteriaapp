import 'package:flutter/material.dart';
import 'package:cafeteria/core/constants/app_colors.dart';
import 'package:cafeteria/features/auth/core/models/menu_item.dart';
import 'package:cafeteria/features/auth/presentation/menu/data/menu_repository.dart';

class AddMenuItemScreen extends StatefulWidget {
  final String canteenId;

  const AddMenuItemScreen({required this.canteenId, super.key});

  @override
  State<AddMenuItemScreen> createState() => _AddMenuItemScreenState();
}

class _AddMenuItemScreenState extends State<AddMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = MenuRepository();

  late TextEditingController _mainFoodController;
  late TextEditingController _vegetablesController;

  String _selectedMealType = 'Vegetarian';
  String _selectedMealTime = 'Lunch';
  DateTime _selectedDate = DateTime.now();
  final List<String> _selectedVegetables = [];

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _mainFoodController = TextEditingController();
    _vegetablesController = TextEditingController();
  }

  @override
  void dispose() {
    _mainFoodController.dispose();
    _vegetablesController.dispose();
    super.dispose();
  }

  void _addVegetable() {
    if (_vegetablesController.text.isNotEmpty &&
        !_selectedVegetables.contains(_vegetablesController.text)) {
      setState(() {
        _selectedVegetables.add(_vegetablesController.text);
      });
      _vegetablesController.clear();
    }
  }

  void _removeVegetable(String vegetable) {
    setState(() {
      _selectedVegetables.remove(vegetable);
    });
  }

  Future<void> _saveMenuItem() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedVegetables.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one vegetable')),
        );
        return;
      }

      final menuItem = MenuItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        mainFood: _mainFoodController.text,
        vegetables: _selectedVegetables,
        mealType: _selectedMealType,
        mealTime: _selectedMealTime,
        date: _formatDate(_selectedDate),
      );

      await _repository.addMenuItem(widget.canteenId, menuItem);

      if (mounted) {
        Navigator.pop(context, menuItem);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu item added successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Menu Item'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Food Field
              const Text(
                'Main Food Item',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _mainFoodController,
                decoration: InputDecoration(
                  hintText: 'e.g., Paneer Tikka',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter main food item';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Meal Time
              const Text(
                'Meal Time',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  underline: const SizedBox(),
                  value: _selectedMealTime,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedMealTime = newValue;
                      });
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'Breakfast',
                      child: Row(
                        children: const [
                          Icon(
                            Icons.wb_sunny_outlined,
                            color: Colors.orange,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text('Breakfast (Ude Aharaya)'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Lunch',
                      child: Row(
                        children: const [
                          Icon(Icons.wb_sunny, color: Colors.amber, size: 18),
                          SizedBox(width: 8),
                          Text('Lunch (Dawal Aharaya)'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Dinner',
                      child: Row(
                        children: const [
                          Icon(
                            Icons.nights_stay,
                            color: Colors.indigo,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text('Dinner (Rathri Aharaya)'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Meal Type
              const Text(
                'Meal Type',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  underline: const SizedBox(),
                  value: _selectedMealType,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedMealType = newValue;
                      });
                    }
                  },
                  items: ['Vegetarian', 'Non-Vegetarian']
                      .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      })
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Menu Date
              const Text(
                'Menu Date',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        _formatDate(_selectedDate),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const Spacer(),
                      const Text('Select'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Vegetables
              const Text(
                'Vegetables',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _vegetablesController,
                      decoration: InputDecoration(
                        hintText: 'Add vegetables',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addVegetable,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Selected Vegetables
              if (_selectedVegetables.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: _selectedVegetables
                      .map(
                        (vegetable) => Chip(
                          label: Text(vegetable),
                          onDeleted: () => _removeVegetable(vegetable),
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveMenuItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Save Menu Item',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
