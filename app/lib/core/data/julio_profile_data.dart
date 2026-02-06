/// Datos reales del usuario Julio Chipayo - Paciente 0
/// Basado en bioimpedancia SmartFit Body del 20/01/2026

class JulioProfileData {
  // ===== DATOS PERSONALES =====
  static const String nombre = 'Julio Chipayo';
  static const String sexo = 'Masculino';
  static const int edad = 26;
  static final DateTime fechaNacimiento = DateTime(1999, 1, 1); // Aproximado
  static final DateTime fechaBioimpedancia = DateTime(2026, 1, 20);

  // ===== MEDIDAS CORPORALES (Bioimpedancia 20/01/2026) =====
  static const double pesoInicial = 72.8; // kg en bioimpedancia
  static const double pesoActual = 75.3; // kg actualizado
  static const double imc = 23.24;
  static const double grasaCorporal = 16.9; // %
  static const double masaLibreGrasa = 56.13; // kg
  static const double agua = 41.09; // L
  static const double grasaVisceral = 5.0; // %
  static const double metabolismoBasal = 1775; // kcal
  static const double masaMuscularEsqueletica = 34.69; // kg

  // Rangos ideales para referencia
  static const double pesoIdealMin = 58.0;
  static const double pesoIdealMax = 78.0;
  static const double imcIdealMin = 18.0;
  static const double imcIdealMax = 24.0;
  static const double grasaIdealMin = 8.0;
  static const double grasaIdealMax = 19.0;

  // ===== COMPOSICION SEGMENTARIA - MASA LIBRE DE GRASA =====
  static const double mlgBrazoIzq = 3.73; // kg
  static const double mlgBrazoDer = 3.77; // kg
  static const double mlgTronco = 29.49; // kg
  static const double mlgPiernaIzq = 9.58; // kg
  static const double mlgPiernaDer = 9.56; // kg

  // Variaciones (+ es ganancia)
  static const double mlgBrazoIzqVar = 0.02;
  static const double mlgBrazoDerVar = 0.06;
  static const double mlgTroncoVar = 0.58;
  static const double mlgPiernaIzqVar = 0.17;
  static const double mlgPiernaDerVar = 0.15;

  // ===== COMPOSICION SEGMENTARIA - GRASA =====
  static const double grasaBrazoIzq = 0.29; // kg
  static const double grasaBrazoDer = 0.25; // kg
  static const double grasaTronco = 9.07; // kg
  static const double grasaPiernaIzq = 1.34; // kg
  static const double grasaPiernaDer = 1.35; // kg

  // Variaciones (- es perdida, bueno en volumen controlado)
  static const double grasaBrazoIzqVar = -0.31;
  static const double grasaBrazoDerVar = -0.35;
  static const double grasaTroncoVar = 1.87;
  static const double grasaPiernaIzqVar = -0.46;
  static const double grasaPiernaDerVar = -0.45;

  // ===== HISTORIAL DE PESO =====
  static const List<Map<String, dynamic>> pesosHistoricos = [
    {'fecha': '2025-12-01', 'peso': 72.8, 'nota': 'Bioimpedancia inicial'},
    {'fecha': '2025-12-15', 'peso': 73.5, 'nota': 'Inicio bulking'},
    {'fecha': '2026-01-01', 'peso': 74.2, 'nota': 'Progreso sostenido'},
    {'fecha': '2026-01-15', 'peso': 74.8, 'nota': 'Subiendo bien'},
    {'fecha': '2026-01-20', 'peso': 75.3, 'nota': 'Peso actual'},
  ];

  // ===== OBJETIVOS =====
  static const String objetivoActual = 'Volumen limpio';
  static const double pesoObjetivo = 78.0; // kg
  static const String descripcionObjetivo =
      'Ganancia de masa muscular maximizada con Upper/Lower Power';

  // ===== MACROS CALCULADOS PARA VOLUMEN =====
  // Basado en: peso actual 75.3kg, metabolismo basal 1775kcal
  // TDEE estimado: 1775 * 1.55 (actividad moderada-alta) = 2751 kcal
  // Superavit 10-15%: ~3000 kcal
  static const int caloriasObjetivo = 3000;
  static const int proteinaObjetivo = 165; // g (2.2g/kg peso)
  static const int carbohidratosObjetivo = 375; // g (5g/kg peso)
  static const int grasaObjetivo = 83; // g (1.1g/kg peso)

  // Distribucion por comida (5 comidas)
  static const Map<String, Map<String, int>> distribucionComidas = {
    'desayuno': {'calorias': 600, 'proteina': 35, 'carbs': 75, 'grasa': 17},
    'almuerzo': {'calorias': 750, 'proteina': 45, 'carbs': 90, 'grasa': 22},
    'merienda': {'calorias': 400, 'proteina': 25, 'carbs': 50, 'grasa': 11},
    'preEntreno': {'calorias': 450, 'proteina': 25, 'carbs': 65, 'grasa': 10},
    'postEntreno': {'calorias': 500, 'proteina': 35, 'carbs': 70, 'grasa': 12},
    'cena': {'calorias': 300, 'proteina': 0, 'carbs': 25, 'grasa': 11},
  };

  // ===== SUPLEMENTACION =====
  static const List<Map<String, dynamic>> suplementos = [
    {'nombre': 'Creatina monohidrato', 'dosis': '5g', 'momento': 'Post-entreno'},
    {'nombre': 'Maca', 'dosis': '5g', 'momento': 'Desayuno'},
  ];

  // ===== PROGRESO DE PESO =====
  static List<Map<String, dynamic>> get historialPeso => [
    {'fecha': DateTime(2026, 1, 20), 'peso': 72.8, 'nota': 'Bioimpedancia inicial'},
    {'fecha': DateTime(2026, 1, 27), 'peso': 74.7, 'nota': '+1.9kg primera semana'},
    {'fecha': DateTime(2026, 2, 3), 'peso': 75.3, 'nota': 'Peso actual'},
  ];

  // ===== GAMIFICACION =====
  static const int nivel = 7;
  static const int xpTotal = 3850;
  static const int xpParaSiguienteNivel = 4500;
  static const int coins = 285;
  static const int rachaActual = 15;
}

/// Rutinas Upper/Lower Power de Julio
class JulioTrainingData {
  // ===== PROGRAMA: UPPER/LOWER POWER =====
  static const String programaNombre = 'Upper/Lower Power';
  static const String programaDescripcion =
      'Programa de 4 dias enfocado en fuerza e hipertrofia';
  static const int diasPorSemana = 4;

  // Estructura semanal
  static const Map<String, String> estructuraSemanal = {
    'Lunes': 'Upper A (Fuerza)',
    'Martes': 'Lower A (Fuerza)',
    'Miercoles': 'Descanso',
    'Jueves': 'Upper B (Hipertrofia)',
    'Viernes': 'Lower B (Hipertrofia)',
    'Sabado': 'Descanso',
    'Domingo': 'Descanso',
  };

  // ===== UPPER A - FUERZA (LUNES) =====
  static List<Map<String, dynamic>> get upperAFuerza => [
    {
      'orden': 1,
      'nombre': 'Press Banca Plano - Barra',
      'grupoMuscular': 'Pecho',
      'prioridad': 1,
      'objetivo': 'Fuerza + densidad pectoral',
      'peso': 65.0,
      'series': 5,
      'reps': 5,
      'tempo': '2-0-1',
      'descanso': 150, // segundos (2:30)
      'rpeObjetivo': 8,
      'notas': 'Completado en 7min. Buen rendimiento.',
      'completado': true,
      'tiempoReal': 420, // 7 min en segundos
    },
    {
      'orden': 2,
      'nombre': 'Remo con Barra',
      'grupoMuscular': 'Espalda',
      'objetivo': 'Espalda media + transferencia al press',
      'peso': 60.0,
      'series': 4,
      'reps': 6,
      'tempo': '2-1-1',
      'descanso': 120,
      'rpeObjetivo': 8,
      'notas': 'Tecnica 6/10. Costo mantener inclinacion con el peso.',
      'completado': true,
      'tiempoReal': 420,
    },
    {
      'orden': 3,
      'nombre': 'Press Militar de Pie - Barra',
      'grupoMuscular': 'Hombros',
      'objetivo': 'Deltoide anterior + estabilidad core',
      'peso': 34.0,
      'series': 4,
      'reps': 5,
      'tempo': '2-0-1',
      'descanso': 135,
      'rpeObjetivo': 8,
      'notas': 'Baje de 40kg a 34kg. Con 34 puedo pero cuesta.',
      'completado': true,
      'tiempoReal': 600,
    },
    {
      'orden': 4,
      'nombre': 'Dominadas Lastradas',
      'grupoMuscular': 'Espalda',
      'objetivo': 'Fuerza dorsal + biceps',
      'peso': 10.0, // kg adicional
      'series': 4,
      'reps': 6,
      'tempo': '2-1-1',
      'descanso': 120,
      'rpeObjetivo': 8,
      'notas': 'Ultima serie solo 2 bien. Serie 3 malas. Termine sin peso.',
      'completado': true,
      'tiempoReal': 540,
    },
    {
      'orden': 5,
      'nombre': 'Press Inclinado Mancuernas',
      'grupoMuscular': 'Pecho',
      'objetivo': 'Upper chest sin fatigar SNC',
      'peso': 20.0, // por mancuerna
      'series': 3,
      'reps': 10,
      'tempo': '2-1-1',
      'descanso': 90,
      'rpeObjetivo': 8,
      'notas': 'Ultima serie solo 6 reps.',
      'completado': true,
      'tiempoReal': 420,
    },
    {
      'orden': 6,
      'nombre': 'Face Pulls',
      'grupoMuscular': 'Hombros',
      'objetivo': 'Salud hombro - compensar empuje',
      'peso': 17.0,
      'series': 3,
      'reps': 15,
      'tempo': '2-1-1',
      'descanso': 60,
      'rpeObjetivo': 7,
      'notas': 'Tecnica 7/10. Varie peso entre series.',
      'completado': true,
    },
    {
      'orden': 7,
      'nombre': 'Curl Biceps Polea',
      'grupoMuscular': 'Biceps',
      'objetivo': 'Finisher opcional',
      'peso': 15.0,
      'series': 3,
      'reps': 15,
      'descanso': 60,
      'rpeObjetivo': 8,
      'completado': true,
    },
  ];

  // ===== LOWER A - FUERZA (MARTES) =====
  static List<Map<String, dynamic>> get lowerAFuerza => [
    {
      'orden': 1,
      'nombre': 'Prensa Inclinada',
      'grupoMuscular': 'Cuadriceps',
      'prioridad': 1,
      'objetivo': 'Sobrecarga segura de cuadriceps',
      'peso': 100.0,
      'series': 4,
      'reps': 12,
      'tempo': '2-1-1',
      'descanso': 135,
      'rpeObjetivo': 8,
      'notas': 'Buen rendimiento. Tiempo total ~10min.',
      'completado': true,
    },
    {
      'orden': 2,
      'nombre': 'Sentadilla Hack',
      'grupoMuscular': 'Cuadriceps',
      'objetivo': 'Desarrollo cuadriceps sin carga axial',
      'peso': 20.0,
      'series': 3,
      'reps': 12,
      'tempo': '2-1-1',
      'descanso': 120,
      'rpeObjetivo': 8,
      'completado': true,
    },
    {
      'orden': 3,
      'nombre': 'Extensiones de Cuadriceps',
      'grupoMuscular': 'Cuadriceps',
      'objetivo': 'Estimulo directo sin carga axial',
      'peso': 50.0,
      'series': 3,
      'reps': 10,
      'tempo': '2-1-1',
      'descanso': 80,
      'rpeObjetivo': 8,
      'notas': 'Pausa 1seg arriba. Quema mucho.',
      'completado': true,
    },
    {
      'orden': 4,
      'nombre': 'Peso Muerto Rumano',
      'grupoMuscular': 'Isquiotibiales',
      'objetivo': 'Isquios y gluteos - NO es dia de fuerza',
      'peso': 50.0,
      'series': 3,
      'reps': 8,
      'tempo': '3-1-1',
      'descanso': 120,
      'rpeObjetivo': 7,
      'completado': true,
    },
    {
      'orden': 5,
      'nombre': 'Gemelos en Prensa',
      'grupoMuscular': 'Gemelos',
      'objetivo': 'Desarrollo pantorrillas',
      'peso': 120.0,
      'series': 4,
      'reps': 15,
      'tempo': '2-1-1',
      'descanso': 65,
      'rpeObjetivo': 8,
      'notas': 'Pausa 1-2seg arriba.',
      'completado': true,
    },
    {
      'orden': 6,
      'nombre': 'Plancha Abdominal',
      'grupoMuscular': 'Core',
      'objetivo': 'Estabilidad core',
      'peso': 0.0,
      'series': 3,
      'reps': 60, // segundos
      'descanso': 45,
      'rpeObjetivo': 7,
      'esIsometrico': true,
      'completado': true,
    },
    {
      'orden': 7,
      'nombre': 'Abs Cortos en Piso',
      'grupoMuscular': 'Core',
      'objetivo': 'Recto abdominal',
      'peso': 0.0,
      'series': 3,
      'reps': 35,
      'descanso': 45,
      'rpeObjetivo': 7,
      'completado': true,
    },
  ];

  // ===== UPPER B - HIPERTROFIA (JUEVES) =====
  static List<Map<String, dynamic>> get upperBHipertrofia => [
    {
      'orden': 1,
      'nombre': 'Press Inclinado con Barra',
      'grupoMuscular': 'Pecho',
      'prioridad': 1,
      'objetivo': 'Upper chest - hipertrofia',
      'peso': 55.0,
      'series': 4,
      'reps': 10,
      'tempo': '2-1-1',
      'descanso': 90,
      'rpeObjetivo': 8,
      'notas': 'Ultima serie falle en rep 6. Cadena molestaba.',
      'completado': true,
    },
    {
      'orden': 2,
      'nombre': 'Remo en Maquina',
      'grupoMuscular': 'Espalda',
      'objetivo': 'Espalda - volumen',
      'peso': 65.0,
      'series': 4,
      'reps': 10,
      'tempo': '2-1-1',
      'descanso': 90,
      'rpeObjetivo': 8,
      'notas': 'Ultimas series rapidas, menos tecnica.',
      'completado': true,
    },
    {
      'orden': 3,
      'nombre': 'Aperturas con Mancuernas',
      'grupoMuscular': 'Pecho',
      'objetivo': 'Estiramiento pectoral',
      'peso': 16.0, // por mancuerna (el 116kg era error)
      'series': 3,
      'reps': 10,
      'tempo': '3-1-1',
      'descanso': 75,
      'rpeObjetivo': 8,
      'notas': 'Ejercicio nuevo. Costo adaptar tecnica.',
      'completado': true,
    },
    {
      'orden': 4,
      'nombre': 'Jalon al Pecho',
      'grupoMuscular': 'Espalda',
      'objetivo': 'Dorsales - agarre prono',
      'peso': 47.0,
      'series': 3,
      'reps': 12,
      'tempo': '2-1-1',
      'descanso': 90,
      'rpeObjetivo': 8,
      'notas': 'Pausa 1seg abajo. Barra al menton 95%.',
      'completado': true,
    },
    {
      'orden': 5,
      'nombre': 'Elevaciones Laterales',
      'grupoMuscular': 'Hombros',
      'objetivo': 'Deltoide lateral - clave del dia',
      'peso': 12.0,
      'series': 4,
      'reps': 15,
      'tempo': '2-1-2',
      'descanso': 60,
      'rpeObjetivo': 9,
      'notas': 'Ultimas 6 reps con impulso. Tecnica de botella.',
      'completado': true,
    },
    {
      'orden': 6,
      'nombre': 'Curl Biceps Polea',
      'grupoMuscular': 'Biceps',
      'objetivo': 'Superset brazos',
      'peso': 17.5,
      'series': 3,
      'reps': 15,
      'descanso': 15, // superset
      'rpeObjetivo': 8,
      'esSuperset': true,
      'supersetCon': 'Extension Triceps Cuerda',
      'completado': true,
    },
    {
      'orden': 7,
      'nombre': 'Extension Triceps Cuerda',
      'grupoMuscular': 'Triceps',
      'objetivo': 'Superset brazos',
      'peso': 17.5,
      'series': 3,
      'reps': 15,
      'descanso': 60,
      'rpeObjetivo': 8,
      'esSuperset': true,
      'supersetCon': 'Curl Biceps Polea',
      'completado': true,
    },
    {
      'orden': 8,
      'nombre': 'Face Pulls',
      'grupoMuscular': 'Hombros',
      'objetivo': 'Salud + postura',
      'peso': 13.75,
      'series': 3,
      'reps': 15,
      'tempo': '2-1-1',
      'descanso': 60,
      'rpeObjetivo': 7,
      'notas': 'Pausa 1seg atras.',
      'completado': true,
    },
  ];

  // ===== LOWER B - HIPERTROFIA (VIERNES) =====
  static List<Map<String, dynamic>> get lowerBHipertrofia => [
    {
      'orden': 1,
      'nombre': 'Sentadilla Goblet',
      'grupoMuscular': 'Cuadriceps',
      'objetivo': 'Activacion y tecnica',
      'peso': 24.0,
      'series': 3,
      'reps': 12,
      'tempo': '2-1-1',
      'descanso': 90,
      'rpeObjetivo': 7,
      'completado': false,
    },
    {
      'orden': 2,
      'nombre': 'Prensa Horizontal',
      'grupoMuscular': 'Cuadriceps',
      'objetivo': 'Volumen cuadriceps',
      'peso': 80.0,
      'series': 4,
      'reps': 15,
      'tempo': '2-1-1',
      'descanso': 90,
      'rpeObjetivo': 8,
      'completado': false,
    },
    {
      'orden': 3,
      'nombre': 'Zancadas con Mancuernas',
      'grupoMuscular': 'Cuadriceps',
      'objetivo': 'Unilateral + estabilidad',
      'peso': 14.0, // por mancuerna
      'series': 3,
      'reps': 10, // por pierna
      'descanso': 90,
      'rpeObjetivo': 8,
      'completado': false,
    },
    {
      'orden': 4,
      'nombre': 'Curl Femoral Acostado',
      'grupoMuscular': 'Isquiotibiales',
      'objetivo': 'Aislamiento isquios',
      'peso': 35.0,
      'series': 4,
      'reps': 12,
      'tempo': '2-1-1',
      'descanso': 75,
      'rpeObjetivo': 8,
      'completado': false,
    },
    {
      'orden': 5,
      'nombre': 'Hip Thrust',
      'grupoMuscular': 'Gluteos',
      'objetivo': 'Fuerza gluteo',
      'peso': 60.0,
      'series': 3,
      'reps': 12,
      'tempo': '2-1-1',
      'descanso': 90,
      'rpeObjetivo': 8,
      'completado': false,
    },
    {
      'orden': 6,
      'nombre': 'Elevacion de Gemelos de Pie',
      'grupoMuscular': 'Gemelos',
      'objetivo': 'Pantorrillas - rango completo',
      'peso': 40.0,
      'series': 4,
      'reps': 15,
      'tempo': '2-2-1',
      'descanso': 60,
      'rpeObjetivo': 8,
      'completado': false,
    },
    {
      'orden': 7,
      'nombre': 'Crunch en Polea',
      'grupoMuscular': 'Core',
      'objetivo': 'Recto abdominal con carga',
      'peso': 25.0,
      'series': 3,
      'reps': 15,
      'descanso': 60,
      'rpeObjetivo': 8,
      'completado': false,
    },
  ];

  // Obtener rutina del dia
  static List<Map<String, dynamic>> getRutinaDelDia(int diaSemana) {
    switch (diaSemana) {
      case DateTime.monday:
        return upperAFuerza;
      case DateTime.tuesday:
        return lowerAFuerza;
      case DateTime.thursday:
        return upperBHipertrofia;
      case DateTime.friday:
        return lowerBHipertrofia;
      default:
        return []; // Dia de descanso
    }
  }

  static String getNombreRutinaDelDia(int diaSemana) {
    switch (diaSemana) {
      case DateTime.monday:
        return 'Upper A - Fuerza';
      case DateTime.tuesday:
        return 'Lower A - Fuerza';
      case DateTime.thursday:
        return 'Upper B - Hipertrofia';
      case DateTime.friday:
        return 'Lower B - Hipertrofia';
      default:
        return 'Dia de Descanso';
    }
  }

  static bool esDiaDeEntreno(int diaSemana) {
    return [DateTime.monday, DateTime.tuesday, DateTime.thursday, DateTime.friday]
        .contains(diaSemana);
  }
}

/// Plan de comidas de Julio
class JulioNutritionData {
  // ===== MACROS DIARIOS OBJETIVO =====
  static const int caloriasObjetivo = 3000;
  static const int proteinaObjetivo = 165; // g
  static const int carbsObjetivo = 375; // g
  static const int grasaObjetivo = 83; // g

  // ===== PLAN DE COMIDAS EJEMPLO =====
  static List<Map<String, dynamic>> get planComidas => [
    {
      'nombre': 'Desayuno',
      'hora': '08:00',
      'alimentos': [
        {'nombre': 'Huevos fritos', 'cantidad': '4 unidades', 'calorias': 312, 'proteina': 24, 'carbs': 2, 'grasa': 24},
        {'nombre': 'Pan integral', 'cantidad': '2 rebanadas', 'calorias': 160, 'proteina': 8, 'carbs': 28, 'grasa': 2},
        {'nombre': 'Yogur griego', 'cantidad': '170g', 'calorias': 100, 'proteina': 17, 'carbs': 6, 'grasa': 0},
        {'nombre': 'Banana', 'cantidad': '1 mediana', 'calorias': 105, 'proteina': 1, 'carbs': 27, 'grasa': 0},
      ],
      'totalCalorias': 677,
      'totalProteina': 50,
      'totalCarbs': 63,
      'totalGrasa': 26,
      'completado': true,
    },
    {
      'nombre': 'Almuerzo',
      'hora': '12:30',
      'alimentos': [
        {'nombre': 'Pechuga de pollo', 'cantidad': '200g', 'calorias': 330, 'proteina': 62, 'carbs': 0, 'grasa': 7},
        {'nombre': 'Arroz integral', 'cantidad': '150g cocido', 'calorias': 165, 'proteina': 4, 'carbs': 35, 'grasa': 1},
        {'nombre': 'Brocoli', 'cantidad': '100g', 'calorias': 34, 'proteina': 3, 'carbs': 7, 'grasa': 0},
        {'nombre': 'Aceite de oliva', 'cantidad': '1 cda', 'calorias': 120, 'proteina': 0, 'carbs': 0, 'grasa': 14},
      ],
      'totalCalorias': 649,
      'totalProteina': 69,
      'totalCarbs': 42,
      'totalGrasa': 22,
      'completado': false,
    },
    {
      'nombre': 'Pre-Entreno',
      'hora': '15:00',
      'alimentos': [
        {'nombre': 'Avena', 'cantidad': '80g', 'calorias': 303, 'proteina': 11, 'carbs': 54, 'grasa': 5},
        {'nombre': 'Whey protein', 'cantidad': '30g', 'calorias': 120, 'proteina': 24, 'carbs': 3, 'grasa': 1},
        {'nombre': 'Miel', 'cantidad': '1 cda', 'calorias': 64, 'proteina': 0, 'carbs': 17, 'grasa': 0},
      ],
      'totalCalorias': 487,
      'totalProteina': 35,
      'totalCarbs': 74,
      'totalGrasa': 6,
      'completado': false,
    },
    {
      'nombre': 'Post-Entreno',
      'hora': '17:30',
      'alimentos': [
        {'nombre': 'Batido proteico', 'cantidad': '40g whey + banana + leche', 'calorias': 380, 'proteina': 35, 'carbs': 45, 'grasa': 5},
        {'nombre': 'Creatina', 'cantidad': '5g', 'calorias': 0, 'proteina': 0, 'carbs': 0, 'grasa': 0},
      ],
      'totalCalorias': 380,
      'totalProteina': 35,
      'totalCarbs': 45,
      'totalGrasa': 5,
      'completado': false,
    },
    {
      'nombre': 'Cena',
      'hora': '20:00',
      'alimentos': [
        {'nombre': 'Salmon', 'cantidad': '180g', 'calorias': 367, 'proteina': 40, 'carbs': 0, 'grasa': 22},
        {'nombre': 'Batata', 'cantidad': '200g', 'calorias': 172, 'proteina': 3, 'carbs': 40, 'grasa': 0},
        {'nombre': 'Espinaca salteada', 'cantidad': '100g', 'calorias': 23, 'proteina': 3, 'carbs': 4, 'grasa': 0},
      ],
      'totalCalorias': 562,
      'totalProteina': 46,
      'totalCarbs': 44,
      'totalGrasa': 22,
      'completado': false,
    },
    {
      'nombre': 'Snack Nocturno',
      'hora': '22:00',
      'alimentos': [
        {'nombre': 'Queso cottage', 'cantidad': '200g', 'calorias': 206, 'proteina': 28, 'carbs': 6, 'grasa': 8},
        {'nombre': 'Almendras', 'cantidad': '20g', 'calorias': 116, 'proteina': 4, 'carbs': 4, 'grasa': 10},
      ],
      'totalCalorias': 322,
      'totalProteina': 32,
      'totalCarbs': 10,
      'totalGrasa': 18,
      'completado': false,
    },
  ];

  // Totales del plan
  static Map<String, int> get totalesPlan {
    int calorias = 0, proteina = 0, carbs = 0, grasa = 0;
    for (var comida in planComidas) {
      calorias += comida['totalCalorias'] as int;
      proteina += comida['totalProteina'] as int;
      carbs += comida['totalCarbs'] as int;
      grasa += comida['totalGrasa'] as int;
    }
    return {
      'calorias': calorias,
      'proteina': proteina,
      'carbs': carbs,
      'grasa': grasa,
    };
  }

  // Comidas de hoy (simuladas con algunas completadas)
  static List<Map<String, dynamic>> get comidasDeHoy {
    final ahora = DateTime.now();
    return planComidas.map((comida) {
      final horaComida = int.parse(comida['hora'].split(':')[0]);
      return {
        ...comida,
        'completado': ahora.hour >= horaComida + 1,
      };
    }).toList();
  }
}

/// Habitos de Julio
class JulioHabitsData {
  static List<Map<String, dynamic>> get habitos => [
    {
      'id': 'hab_1',
      'nombre': 'Tomar creatina',
      'descripcion': '5g post-entreno',
      'icono': 'fitness_center',
      'color': 0xFF6C63FF,
      'frecuencia': 'diaria',
      'horaRecordatorio': '17:30',
      'racha': 15,
      'completadoHoy': true,
    },
    {
      'id': 'hab_2',
      'nombre': 'Tomar maca',
      'descripcion': '5g con desayuno',
      'icono': 'eco',
      'color': 0xFF4CAF50,
      'frecuencia': 'diaria',
      'horaRecordatorio': '08:00',
      'racha': 15,
      'completadoHoy': true,
    },
    {
      'id': 'hab_3',
      'nombre': 'Caminata al gym',
      'descripcion': '10min ida + 10min vuelta',
      'icono': 'directions_walk',
      'color': 0xFFFF9800,
      'frecuencia': 'dias_entreno',
      'horaRecordatorio': '14:00',
      'racha': 8,
      'completadoHoy': false, // Pendiente
    },
    {
      'id': 'hab_4',
      'nombre': 'Dormir 7-8 horas',
      'descripcion': 'Acostarse antes de las 23:00',
      'icono': 'bedtime',
      'color': 0xFF3F51B5,
      'frecuencia': 'diaria',
      'horaRecordatorio': '22:30',
      'racha': 5,
      'completadoHoy': false,
    },
    {
      'id': 'hab_5',
      'nombre': 'Registrar comidas',
      'descripcion': 'Trackear todas las comidas del dia',
      'icono': 'restaurant',
      'color': 0xFFE91E63,
      'frecuencia': 'diaria',
      'horaRecordatorio': '21:00',
      'racha': 12,
      'completadoHoy': false,
    },
    {
      'id': 'hab_6',
      'nombre': 'Hidratacion',
      'descripcion': 'Minimo 2.5L de agua',
      'icono': 'water_drop',
      'color': 0xFF00BCD4,
      'frecuencia': 'diaria',
      'horaRecordatorio': '20:00',
      'racha': 10,
      'completadoHoy': true,
    },
  ];

  static int get habitosCompletadosHoy =>
      habitos.where((h) => h['completadoHoy'] == true).length;

  static int get totalHabitos => habitos.length;

  static int get rachaMaxima =>
      habitos.map((h) => h['racha'] as int).reduce((a, b) => a > b ? a : b);
}
