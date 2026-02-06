# WEMAKE - El Sistema Operativo para Makers

> "La vida no se desea. Se construye."

WEMAKE es una super app que combina fitness, nutricion, productividad y habitos en una sola experiencia gamificada.

## Filosofia

**Make Today Count.** - Para hacedores que construyen su vida dia a dia.

## Caracteristicas Implementadas

### Core Features
- 🏋️ **Training** - Rutinas inteligentes con sugerencia de peso progresivo (+2.5kg), tracking de sets con RPE, timer de descanso
- 🥗 **Nutrition** - Tracking de macros con analisis de fotos por IA (simulado), registro manual de comidas
- ✅ **Habits** - Sistema de habitos con 3 tipos: check simple, cuantitativo, y con evidencia fotografica
- 💧 **Hydration** - Tracking de agua en "botellas" (no litros), con recordatorios configurables
- 📊 **Daily Flow** - Timeline lineal del dia (no dashboard), mostrando todos los items pendientes/completados

### Gamification
- 🎮 **XP & Coins** - Dual currency system (XP para ranking, Coins para gastar)
- 🔥 **Dual Streak** - Light (60%+) y Perfect (90%+) con streak freezes
- 🛒 **Cosmetics Store** - Avatares, marcos, badges, titulos y temas comprables
- 🏆 **Achievements** - Sistema de logros con notificaciones

### Intelligence
- 🧠 **Correlation Engine** - Analisis automatico de patrones (sueno-rendimiento, nutricion-enfoque, etc.)
- 💡 **Smart Insights** - Recomendaciones basadas en tus datos historicos
- 📈 **Progressive Overload** - Sugerencias inteligentes de peso para entrenamiento

### Platform
- 🔔 **Notifications** - Sistema completo de recordatorios (agua, comidas, entrenamientos, habitos, streaks)
- ⚙️ **Settings** - Pantalla de configuracion completa con notificaciones personalizables
- 🎨 **Theming** - Sistema de tema con soporte para modo oscuro

## Tech Stack

- **Frontend**: Flutter 3.24+ + Riverpod
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **State**: Riverpod + Freezed
- **Navigation**: GoRouter
- **Notifications**: flutter_local_notifications + timezone
- **Local Storage**: Hive + SharedPreferences

## Estructura del Proyecto

```
lib/
├── main.dart                    # Entry point
├── core/
│   ├── constants/              # App constants, enums
│   ├── theme/                  # Design system (colors, typography)
│   ├── models/                 # Freezed data models
│   │   ├── user_models.dart    # User, Currency, Streak, DailyScore
│   │   ├── habit_models.dart   # Habit, HabitLog, DailyFlowItem
│   │   ├── nutrition_models.dart # Meal, Macro, WaterLog
│   │   └── training_models.dart  # Exercise, Routine, Session, Set
│   ├── providers/              # Global providers
│   │   ├── auth_provider.dart
│   │   └── app_router_provider.dart
│   └── services/
│       └── notification_service.dart
├── features/
│   ├── auth/
│   │   └── screens/            # Login, Splash
│   ├── onboarding/
│   │   ├── models/             # OnboardingState
│   │   ├── providers/          # OnboardingNotifier
│   │   ├── screens/            # OnboardingScreen (10 steps)
│   │   └── widgets/            # step_name, step_basic_data, etc.
│   ├── home/
│   │   ├── providers/          # DailyFlowProvider
│   │   ├── screens/            # HomeScreen
│   │   └── widgets/            # DailyHeader, DailyFlowTimeline, QuickActions
│   ├── habits/
│   │   ├── providers/          # HabitsProvider
│   │   ├── screens/            # HabitsScreen, AddHabitScreen
│   │   └── widgets/            # HabitCard, HabitStatsHeader
│   ├── nutrition/
│   │   ├── providers/          # NutritionProvider
│   │   └── screens/            # NutritionScreen, AddMealScreen
│   ├── training/
│   │   ├── providers/          # TrainingProvider
│   │   └── screens/            # TrainingScreen, WorkoutSessionScreen
│   ├── gamification/
│   │   ├── providers/          # GamificationProvider
│   │   └── screens/            # StoreScreen
│   ├── insights/
│   │   ├── providers/          # CorrelationProvider
│   │   └── screens/            # InsightsScreen
│   ├── profile/
│   │   └── screens/            # ProfileScreen
│   └── settings/
│       └── screens/            # NotificationSettingsScreen
└── shared/
    └── widgets/                # MainShell, reusable components
```

## Setup

### Prerrequisitos

- Flutter SDK (>= 3.2.0)
- Cuenta de Supabase

### Instalacion

1. **Clonar el repositorio**
   ```bash
   git clone <repo-url>
   cd wemake/app
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Configurar Supabase**

   Crea un archivo `.env` basado en `.env.example`:
   ```
   SUPABASE_URL=https://tu-proyecto.supabase.co
   SUPABASE_ANON_KEY=tu-anon-key
   ```

4. **Ejecutar migraciones en Supabase**

   Ve a tu proyecto de Supabase → SQL Editor y ejecuta:
   ```
   supabase/migrations/001_initial_schema.sql
   ```

5. **Generar codigo Freezed**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

6. **Ejecutar la app**
   ```bash
   flutter run
   ```

## Rutas Disponibles

| Ruta | Pantalla | Descripcion |
|------|----------|-------------|
| `/` | Splash | Loading inicial |
| `/login` | Login | Autenticacion |
| `/onboarding` | Onboarding | 10 pasos de setup |
| `/home` | Home | Daily Flow timeline |
| `/nutrition` | Nutrition | Tracking de comidas |
| `/nutrition/add` | AddMeal | Registrar comida |
| `/training` | Training | Lista de rutinas |
| `/training/session` | WorkoutSession | Sesion activa |
| `/habits` | Habits | Lista de habitos |
| `/habits/add` | AddHabit | Crear habito |
| `/profile` | Profile | Perfil de usuario |
| `/store` | Store | Tienda de cosmeticos |
| `/insights` | Insights | Correlation Engine |
| `/settings` | Settings | Configuracion |
| `/settings/notifications` | Notifications | Config de notificaciones |

## Neuro-Onboarding (10 pasos)

1. **Nombre** - Nombre de usuario
2. **Datos Basicos** - Edad, sexo, estatura, peso
3. **Tipo de Cuerpo** - Ectomorfo, mesomorfo, endomorfo
4. **Lesiones** - Lesiones o limitaciones fisicas
5. **Equipamiento** - Gym, casa, sin equipo
6. **Nivel de Actividad** - Sedentario a muy activo
7. **Objetivos** - Perder grasa, ganar musculo, etc.
8. **Perfil Cognitivo** - Problemas de atencion, enfoque
9. **Hidratacion** - Tamano de botella preferido
10. **Compromiso** - Nivel de dedicacion

## Gamificacion

### Monedas
- **XP**: Experiencia para subir de nivel (ranking semanal/mensual)
- **Coins**: Moneda para comprar cosmeticos

### Streaks
- **Streak Light**: 60%+ de completado diario
- **Streak Perfect**: 90%+ de completado diario
- **Streak Freeze**: Congela tu racha por un dia

### Tienda de Cosmeticos
- Avatares
- Marcos (frames)
- Badges
- Titulos
- Temas de color

## Correlation Engine

El motor de correlaciones analiza tus datos para encontrar patrones como:

- Sueno vs Rendimiento de entrenamiento
- Nutricion vs Concentracion
- Timing de comidas vs Adherencia a dieta
- Carbohidratos vs Performance
- Hidratacion vs Energia
- Patrones de habitos por dia de semana

Genera insights con:
- Titulo descriptivo
- Explicacion del patron
- Sugerencia de accion
- Nivel de confianza
- Fuerza de correlacion

## Comandos Utiles

```bash
# Instalar dependencias
flutter pub get

# Generar codigo (Freezed, JSON)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode para desarrollo
flutter pub run build_runner watch --delete-conflicting-outputs

# Analizar codigo
flutter analyze

# Correr tests
flutter test

# Build para Android
flutter build apk

# Build para iOS
flutter build ios
```

## Proximos Pasos

- [ ] Integrar API real de AI para analisis de fotos de comida
- [ ] Conectar con HealthKit/Google Fit para pasos y sueno
- [ ] Implementar sistema de ligas semanales
- [ ] Agregar widgets para iOS/Android home screen
- [ ] Implementar sync offline-first
- [ ] Agregar integracion con Toggl/ClickUp para productividad

## Licencia

Propiedad de WEMAKE. Todos los derechos reservados.

---

**Make Today Count.** 🚀
