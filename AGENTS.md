# WEMAKE - Contexto para Agentes IA

## Descripción del Proyecto
WEMAKE es una "Super App" de fitness, nutrición, hábitos y productividad. Combina lo mejor de apps como Hevy, MyFitnessPal, Habitify y Cal AI en una sola experiencia unificada.

## Stack Técnico
- **Framework**: Flutter 3.x (Web + Mobile)
- **State Management**: Riverpod (StateNotifierProvider)
- **Backend**: Supabase (Auth, Database, Storage)
- **Deployment**: VPS en app.powernax.com

## Estructura del Proyecto
```
app/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── core/                        # Tema, constantes, utilidades
│   │   └── theme/app_theme.dart     # Tema oscuro unificado
│   ├── features/                    # Módulos por feature
│   │   ├── home/                    # Dashboard principal
│   │   ├── training/                # Entrenamientos (Rest Timer, PRs)
│   │   ├── nutrition/               # Nutrición estilo Cal AI
│   │   ├── habits/                  # Hábitos con calendario
│   │   ├── stats/                   # Estadísticas y Strength Score
│   │   ├── gamification/            # Badges y logros
│   │   ├── auth/                    # Autenticación
│   │   └── onboarding/              # Flujo inicial
│   └── shared/                      # Widgets compartidos
└── pubspec.yaml
```

## Estilo Visual
- **Tema**: Dark mode (#0D0D0F background)
- **Colores por módulo**:
  - Verde (#10B981): Nutrición, éxito
  - Lima (#B8FF00): Entrenamiento
  - Púrpura (#6366F1): Estadísticas
  - Naranja (#F97316): Hábitos
  - Azul (#3B82F6): Agua, general

## Patrones de Código

### State Management con Riverpod
```dart
// Provider inline en el mismo archivo de la pantalla
final myDataProvider = StateNotifierProvider<MyNotifier, MyState>((ref) {
  return MyNotifier();
});

class MyNotifier extends StateNotifier<MyState> {
  MyNotifier() : super(MyState.initial());

  void updateData() {
    state = state.copyWith(/* changes */);
  }
}
```

### Estructura de Pantallas
```dart
class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: SafeArea(
        child: // contenido
      ),
    );
  }
}
```

### Tarjetas con Estilo Unificado
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: const Color(0xFF1A1A1C),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withOpacity(0.05)),
  ),
  child: // contenido
)
```

## Convenciones
- Idioma del código: Inglés para clases/variables, Español para UI text
- Cada feature es autocontenida en su carpeta
- Providers definidos inline en los archivos de screen (no separados)
- CustomPainters para gráficos circulares y charts
- Iconos: phosphor_flutter como librería principal

## Features Implementadas
1. **Home**: Dashboard con resumen diario, XP, accesos rápidos
2. **Training**: Ejercicios con sets, Rest Timer, PR tracking, volumen
3. **Nutrition**: Calorías circular, macros, agua, comidas (estilo Cal AI)
4. **Habits**: Calendario semanal, rachas, categorías
5. **Stats**: Strength Score, gráficas de progreso
6. **Gamification**: 20+ badges en 6 categorías con rareza

## Comandos Útiles
```bash
# Desarrollo
cd /Users/juliosnyk/Documents/WEMAKE/app
flutter run -d chrome

# Build producción
flutter build web --release

# Deploy a VPS
rsync -avz --delete build/web/ root@72.60.157.10:/var/www/wemake/
```

## URLs
- **Producción**: https://app.powernax.com
- **Repo**: (conectar GitHub)

## Notas para el Agente
- Mantener el estilo visual consistente (tema oscuro, colores por módulo)
- Usar Riverpod para todo el state management
- No crear archivos separados para providers simples
- Preferir widgets inline sobre abstracciones prematuras
- El proyecto está en español (México) para el usuario final
