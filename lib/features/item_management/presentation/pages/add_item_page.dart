import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/widgets/common/custom_app_bar.dart';
import '../../domain/models/item_model.dart';
import '../providers/item_provider.dart';

class AddItemPage extends ConsumerStatefulWidget {
  const AddItemPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends ConsumerState<AddItemPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String _selectedCategory = 'Electronics';

  final List<String> _categories = [
    'Electronics',
    'Furniture',
    'Stationery',
    'Clothing',
    'Food & Beverage',
    'Others',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
        appBar: const CustomAppBar(title: 'Add New Item'),
        body: SingleChildScrollView(
          padding: ResponsiveConstants.getResponsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item Details',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveConstants.getResponsiveFontSize(context, 18.0),
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
      
                    CustomTextField(
                      controller: _nameController,
                      hint: 'Enter item name',
                      label: 'Item Name',
                      hasError: false,
                    ),
                    const SizedBox(height: 16),
      
                    _buildCategoryDropdown(isDarkMode),
                    const SizedBox(height: 16),
      
                    _buildQuantityField(isDarkMode),
                    const SizedBox(height: 32),
      
                    CustomButton(
                      label: 'Add Item',
                      onPressed: _addItem,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 600 ? 12.0 : 14.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: fontSize,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[700] : Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!, 
              width: 1.0,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              style: TextStyle(
                fontSize: fontSize,
                color: isDarkMode ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: isDarkMode ? Colors.grey[700] : Colors.white,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                size: 20,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
              items: _categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(value).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          _getCategoryIcon(value),
                          color: _getCategoryColor(value),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        value,
                        style: GoogleFonts.inter(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Icons.devices;
      case 'furniture':
        return Icons.chair;
      case 'stationery':
        return Icons.edit;
      case 'clothing':
        return Icons.checkroom;
      case 'food & beverage':
        return Icons.restaurant;
      case 'others':
        return Icons.category;
      default:
        return Icons.inventory;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Colors.blue;
      case 'furniture':
        return Colors.brown;
      case 'stationery':
        return Colors.green;
      case 'clothing':
        return Colors.purple;
      case 'food & beverage':
        return Colors.orange;
      case 'others':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildQuantityField(bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 600 ? 12.0 : 14.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: fontSize,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            // Decrease button
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                border: Border.all(color: Colors.grey[300]!, width: 1.0),
              ),
              child: IconButton(
                onPressed: () {
                  int currentValue = int.tryParse(_quantityController.text) ?? 0;
                  if (currentValue > 0) {
                    _quantityController.text = (currentValue - 1).toString();
                  }
                },
                icon: const Icon(Icons.remove),
                iconSize: 20,
              ),
            ),
            
            // Number input field
            Expanded(
              child: TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(fontSize: fontSize - 1, color: Colors.grey[500]),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: screenWidth < 600 ? 12.0 : 14.0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: const BorderSide(color: Color(0xFF011936), width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                onChanged: (value) {
                  // Only allow numbers
                  if (value.isNotEmpty && int.tryParse(value) == null) {
                    _quantityController.text = value.replaceAll(RegExp(r'[^0-9]'), '');
                    _quantityController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _quantityController.text.length),
                    );
                  }
                },
              ),
            ),
            
            // Increase button
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                border: Border.all(color: Colors.grey[300]!, width: 1.0),
              ),
              child: IconButton(
                onPressed: () {
                  int currentValue = int.tryParse(_quantityController.text) ?? 0;
                  _quantityController.text = (currentValue + 1).toString();
                },
                icon: const Icon(Icons.add),
                iconSize: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _addItem() {
    if (_nameController.text.isEmpty || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity (minimum 1)')),
      );
      return;
    }

    final newItem = Item(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      category: _selectedCategory,
      quantity: quantity,
      createdAt: DateTime.now(),
    );

    ref.read(itemProvider.notifier).addItem(newItem);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item added successfully!')),
    );

    Navigator.pop(context);
  }
}
