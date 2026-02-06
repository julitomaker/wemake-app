import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/onboarding_provider.dart';

class StepBasicData extends ConsumerStatefulWidget {
  const StepBasicData({super.key});

  @override
  ConsumerState<StepBasicData> createState() => _StepBasicDataState();
}

class _StepBasicDataState extends ConsumerState<StepBasicData> {
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  String? _selectedSex;

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingProvider);
    _ageController = TextEditingController(
      text: state.age?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: state.weightKg?.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: state.heightCm?.toString() ?? '',
    );
    _selectedSex = state.sex;
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _updateData() {
    ref.read(onboardingProvider.notifier).setBasicData(
          age: int.tryParse(_ageController.text),
          sex: _selectedSex,
          weightKg: double.tryParse(_weightController.text),
          heightCm: int.tryParse(_heightController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(onboardingProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          // Title
          Text(
            'Hola, ${state.name ?? ""}!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Necesitamos algunos datos para calcular tus metas.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 32),

          // Sex selection
          Text(
            'Sexo biologico',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SexButton(
                  label: 'Masculino',
                  icon: Icons.male,
                  isSelected: _selectedSex == 'male',
                  onTap: () {
                    setState(() => _selectedSex = 'male');
                    _updateData();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SexButton(
                  label: 'Femenino',
                  icon: Icons.female,
                  isSelected: _selectedSex == 'female',
                  onTap: () {
                    setState(() => _selectedSex = 'female');
                    _updateData();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Age
          _buildInputField(
            label: 'Edad',
            controller: _ageController,
            suffix: 'anos',
            keyboardType: TextInputType.number,
            onChanged: (_) => _updateData(),
          ),

          const SizedBox(height: 24),

          // Weight & Height row
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: 'Peso',
                  controller: _weightController,
                  suffix: 'kg',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => _updateData(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField(
                  label: 'Altura',
                  controller: _heightController,
                  suffix: 'cm',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _updateData(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Info box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lock_outline,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Esta informacion es privada y se usa unicamente para calcular tus metas de nutricion y entrenamiento.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String suffix,
    required TextInputType keyboardType,
    required Function(String) onChanged,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          onChanged: onChanged,
          decoration: InputDecoration(
            suffixText: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _SexButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SexButton({
    required this.label,
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
        padding: const EdgeInsets.symmetric(vertical: 16),
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
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
