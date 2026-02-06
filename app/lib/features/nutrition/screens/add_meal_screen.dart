import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/nutrition_provider.dart';

class AddMealScreen extends ConsumerStatefulWidget {
  final String? mealType;

  const AddMealScreen({super.key, this.mealType});

  @override
  ConsumerState<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends ConsumerState<AddMealScreen> {
  final _descriptionController = TextEditingController();

  String _selectedMealType = 'lunch';
  XFile? _selectedImage;
  bool _isAnalyzing = false;
  bool _isManualEntry = false;

  // Manual entry controllers
  final _kcalController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  // AI Analysis result
  Map<String, dynamic>? _analysisResult;

  final _mealTypes = [
    ('breakfast', 'Desayuno', Icons.wb_sunny, Colors.orange),
    ('lunch', 'Almuerzo', Icons.wb_cloudy, Colors.blue),
    ('dinner', 'Cena', Icons.nightlight, Colors.indigo),
    ('snack', 'Snack', Icons.cookie, Colors.brown),
  ];

  // Check if we're on a mobile platform
  bool get _isMobile {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
           defaultTargetPlatform == TargetPlatform.android;
  }

  // Check if camera is available
  bool get _hasCameraSupport => _isMobile;

  @override
  void initState() {
    super.initState();
    if (widget.mealType != null) {
      _selectedMealType = widget.mealType!;
    }
    // On desktop/web, start with manual entry
    if (!_isMobile) {
      _isManualEntry = true;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _kcalController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (!_hasCameraSupport && source == ImageSource.camera) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camara no disponible en esta plataforma')),
      );
      return;
    }

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _analysisResult = null;
        });
        _analyzeImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() => _isAnalyzing = true);

    // Simulate AI analysis (in production, this would call an API)
    await Future.delayed(const Duration(seconds: 2));

    // Mock result - in production this comes from AI
    setState(() {
      _isAnalyzing = false;
      _analysisResult = {
        'foods': [
          {'name': 'Pollo a la plancha', 'portion': '150g', 'kcal': 248, 'protein': 46, 'carbs': 0, 'fat': 5},
          {'name': 'Arroz integral', 'portion': '100g', 'kcal': 111, 'protein': 3, 'carbs': 23, 'fat': 1},
          {'name': 'Ensalada mixta', 'portion': '80g', 'kcal': 15, 'protein': 1, 'carbs': 3, 'fat': 0},
        ],
        'totals': {'kcal': 374, 'protein': 50, 'carbs': 26, 'fat': 6},
        'confidence': 0.85,
      };
    });
  }

  Future<void> _saveMeal() async {
    int kcal, protein, carbs, fat;

    if (_isManualEntry || _analysisResult == null) {
      kcal = int.tryParse(_kcalController.text) ?? 0;
      protein = int.tryParse(_proteinController.text) ?? 0;
      carbs = int.tryParse(_carbsController.text) ?? 0;
      fat = int.tryParse(_fatController.text) ?? 0;

      if (kcal == 0 && protein == 0 && carbs == 0 && fat == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingresa al menos las calorias')),
        );
        return;
      }
    } else {
      final totals = _analysisResult!['totals'] as Map<String, dynamic>;
      kcal = totals['kcal'] as int;
      protein = totals['protein'] as int;
      carbs = totals['carbs'] as int;
      fat = totals['fat'] as int;
    }

    final success = await ref.read(nutritionProvider.notifier).logMeal(
      mealType: _selectedMealType,
      description: _descriptionController.text.trim(),
      kcal: kcal,
      protein: protein,
      carbs: carbs,
      fat: fat,
      imageFile: null, // On web, we skip the file for now
    );

    if (success && mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comida registrada! +15 XP'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Comida'),
        actions: [
          TextButton(
            onPressed: _saveMeal,
            child: const Text('Guardar'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Meal type selector
          _buildSectionTitle('Tipo de comida'),
          const SizedBox(height: 12),
          Row(
            children: _mealTypes.map((type) {
              final isSelected = _selectedMealType == type.$1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: type.$1 != 'snack' ? 8 : 0),
                  child: _MealTypeChip(
                    label: type.$2,
                    icon: type.$3,
                    color: type.$4,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedMealType = type.$1),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Photo section (only show on mobile or if image already selected)
          if (_isMobile || _selectedImage != null) ...[
            _buildSectionTitle('Foto de tu comida'),
            const SizedBox(height: 12),
            if (_selectedImage == null)
              _buildImagePicker(theme)
            else
              _buildImagePreview(theme),
            const SizedBox(height: 24),
          ],

          // Analysis result or manual entry
          if (_isAnalyzing)
            _buildAnalyzingIndicator(theme)
          else if (_analysisResult != null)
            _buildAnalysisResult(theme)
          else
            _buildManualEntry(theme),

          const SizedBox(height: 24),

          // Description
          _buildSectionTitle('Descripcion (opcional)'),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Agrega notas sobre tu comida...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildImagePicker(ThemeData theme) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt,
            size: 48,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_hasCameraSupport) ...[
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camara'),
                ),
                const SizedBox(width: 12),
              ],
              OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Galeria'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(ThemeData theme) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: FutureBuilder<Uint8List>(
            future: _selectedImage?.readAsBytes(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Image.memory(
                  snapshot.data!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
              }
              return Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: CircleAvatar(
            backgroundColor: Colors.black54,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => setState(() {
                _selectedImage = null;
                _analysisResult = null;
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzingIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Analizando tu comida con IA...',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Detectando alimentos y calculando macros',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResult(ThemeData theme) {
    final foods = _analysisResult!['foods'] as List;
    final totals = _analysisResult!['totals'] as Map<String, dynamic>;
    final confidence = _analysisResult!['confidence'] as double;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Confidence indicator
        Row(
          children: [
            Icon(
              confidence > 0.8 ? Icons.check_circle : Icons.info,
              color: confidence > 0.8 ? Colors.green : Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Confianza: ${(confidence * 100).round()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: confidence > 0.8 ? Colors.green : Colors.orange,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => setState(() => _isManualEntry = true),
              child: const Text('Editar manual'),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Foods list
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ...foods.map((food) => ListTile(
                    dense: true,
                    title: Text(food['name']),
                    subtitle: Text(food['portion']),
                    trailing: Text(
                      '${food['kcal']} kcal',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _MacroChip(
                      label: 'Kcal',
                      value: '${totals['kcal']}',
                      color: Colors.purple,
                    ),
                    _MacroChip(
                      label: 'Prot',
                      value: '${totals['protein']}g',
                      color: Colors.red,
                    ),
                    _MacroChip(
                      label: 'Carbs',
                      value: '${totals['carbs']}g',
                      color: Colors.amber,
                    ),
                    _MacroChip(
                      label: 'Grasa',
                      value: '${totals['fat']}g',
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManualEntry(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Macros'),
            if (_selectedImage != null)
              TextButton(
                onPressed: _analyzeImage,
                child: const Text('Analizar con IA'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MacroInput(
                controller: _kcalController,
                label: 'Kcal',
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MacroInput(
                controller: _proteinController,
                label: 'Prot (g)',
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MacroInput(
                controller: _carbsController,
                label: 'Carbs (g)',
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MacroInput(
                controller: _fatController,
                label: 'Grasa (g)',
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MealTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _MealTypeChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _MacroInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Color color;

  const _MacroInput({
    required this.controller,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: color, fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
