import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/habits_provider.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController();

  String _selectedType = 'check_simple';
  String? _selectedTime;
  String? _selectedUnit;
  int _xpValue = 10;
  int _coinsValue = 5;
  bool _isLoading = false;

  final _habitTypes = [
    ('check_simple', 'Check Simple', 'Solo marca cuando lo completes', Icons.check_circle),
    ('quantitative', 'Cuantitativo', 'Registra un numero (ej: 8 vasos de agua)', Icons.tag),
    ('evidence', 'Con Evidencia', 'Requiere foto como prueba', Icons.camera_alt),
  ];

  final _timeOptions = [
    ('morning', 'Manana', '06:00 - 12:00'),
    ('afternoon', 'Tarde', '12:00 - 18:00'),
    ('evening', 'Noche', '18:00 - 00:00'),
    ('anytime', 'Cualquier hora', 'Sin horario fijo'),
  ];

  final _unitOptions = [
    'veces',
    'minutos',
    'vasos',
    'paginas',
    'km',
    'pasos',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await ref.read(habitsProvider.notifier).createHabit(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          habitType: _selectedType,
          targetValue: _selectedType == 'quantitative'
              ? double.tryParse(_targetController.text)
              : null,
          unit: _selectedType == 'quantitative' ? _selectedUnit : null,
          timeOfDay: _selectedTime,
          xpValue: _xpValue,
          coinsValue: _coinsValue,
        );

    setState(() => _isLoading = false);

    if (success && mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Habito creado exitosamente!'),
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
        title: const Text('Nuevo Habito'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveHabit,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name field
            _buildSectionTitle('Nombre del habito'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Ej: Meditar 10 minutos',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa un nombre para el habito';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Description field
            _buildSectionTitle('Descripcion (opcional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Agrega una descripcion o motivacion',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Habit type
            _buildSectionTitle('Tipo de habito'),
            const SizedBox(height: 12),
            ...List.generate(_habitTypes.length, (index) {
              final type = _habitTypes[index];
              final isSelected = _selectedType == type.$1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _HabitTypeCard(
                  value: type.$1,
                  title: type.$2,
                  description: type.$3,
                  icon: type.$4,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedType = type.$1),
                ),
              );
            }),

            // Quantitative options
            if (_selectedType == 'quantitative') ...[
              const SizedBox(height: 24),
              _buildSectionTitle('Meta diaria'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _targetController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Cantidad',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (_selectedType == 'quantitative') {
                          if (value == null || value.isEmpty) {
                            return 'Requerido';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Numero invalido';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: InputDecoration(
                        hintText: 'Unidad',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _unitOptions
                          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedUnit = v),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // Time of day
            _buildSectionTitle('Horario preferido'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeOptions.map((time) {
                final isSelected = _selectedTime == time.$1;
                return ChoiceChip(
                  label: Text(time.$2),
                  selected: isSelected,
                  onSelected: (_) => setState(() {
                    _selectedTime = isSelected ? null : time.$1;
                  }),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Rewards
            _buildSectionTitle('Recompensas'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // XP slider
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      const Text('XP:'),
                      Expanded(
                        child: Slider(
                          value: _xpValue.toDouble(),
                          min: 5,
                          max: 50,
                          divisions: 9,
                          label: '$_xpValue XP',
                          onChanged: (v) => setState(() => _xpValue = v.round()),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '$_xpValue',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  // Coins slider
                  Row(
                    children: [
                      Icon(Icons.monetization_on, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      const Text('Coins:'),
                      Expanded(
                        child: Slider(
                          value: _coinsValue.toDouble(),
                          min: 1,
                          max: 25,
                          divisions: 24,
                          label: '$_coinsValue Coins',
                          onChanged: (v) => setState(() => _coinsValue = v.round()),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '$_coinsValue',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tip: Empieza con habitos pequenos y alcanzables. Es mejor completar 5 habitos simples que fallar en 1 dificil.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
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
}

class _HabitTypeCard extends StatelessWidget {
  final String value;
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _HabitTypeCard({
    required this.value,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.2)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
