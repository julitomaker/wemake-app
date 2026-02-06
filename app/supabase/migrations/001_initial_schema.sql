-- WEMAKE Database Schema V1
-- "Make Today Count" - El Sistema Operativo para Makers

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ===================
-- USER DOMAIN
-- ===================

-- Bio Profile (extends Supabase auth.users)
CREATE TABLE bio_profile (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Basic Info
    weight_kg DECIMAL(5,2),
    height_cm INTEGER,
    age INTEGER,
    sex VARCHAR(10) CHECK (sex IN ('male', 'female', 'other')),

    -- Body & Fitness
    body_type VARCHAR(20) CHECK (body_type IN ('ectomorph', 'mesomorph', 'endomorph')),
    injuries JSONB DEFAULT '[]'::jsonb, -- [{area, severity, notes}]
    equipment_access VARCHAR(20) CHECK (equipment_access IN ('gym', 'home', 'minimal')),
    activity_level VARCHAR(20) CHECK (activity_level IN ('sedentary', 'light', 'moderate', 'active', 'very_active')),

    -- Cognitive Profile (from Neuro-Onboarding)
    focus_score INTEGER CHECK (focus_score >= 0 AND focus_score <= 100),
    attention_type VARCHAR(20) CHECK (attention_type IN ('starter_issue', 'maintainer_issue', 'both')),

    -- Goals
    goal_primary VARCHAR(20) CHECK (goal_primary IN ('muscle', 'fat_loss', 'maintenance', 'energy')),
    goal_urgency VARCHAR(10) CHECK (goal_urgency IN ('high', 'medium', 'low')),

    -- Calculated Targets
    tdee_calculated INTEGER, -- Total Daily Energy Expenditure
    macro_targets JSONB DEFAULT '{}'::jsonb, -- {protein_g, carbs_g, fat_g, kcal}
    water_target_ml INTEGER DEFAULT 3500,
    bottle_size_ml INTEGER DEFAULT 700, -- For UX display (botellas)
    sleep_target_hrs DECIMAL(3,1) DEFAULT 8,

    -- Onboarding
    commitment_signature TEXT, -- Digital signature from onboarding
    onboarding_completed_at TIMESTAMP WITH TIME ZONE,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===================
-- NUTRITION DOMAIN
-- ===================

-- Food Database
CREATE TABLE food (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    name_es VARCHAR(255), -- Spanish name
    brand VARCHAR(100),

    -- Per 100g
    kcal_per_100g DECIMAL(6,2) NOT NULL,
    protein_per_100g DECIMAL(5,2) NOT NULL,
    carbs_per_100g DECIMAL(5,2) NOT NULL,
    fat_per_100g DECIMAL(5,2) NOT NULL,
    fiber_per_100g DECIMAL(5,2) DEFAULT 0,
    sugar_per_100g DECIMAL(5,2) DEFAULT 0,
    sodium_per_100g DECIMAL(5,2) DEFAULT 0,

    source VARCHAR(20) DEFAULT 'custom' CHECK (source IN ('usda', 'custom', 'ai')),
    barcode VARCHAR(50),
    image_url TEXT,

    created_by UUID REFERENCES auth.users(id),
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User's Inventory (Alacena Virtual)
CREATE TABLE inventory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    estimated_days INTEGER, -- Days the current stock will last
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE inventory_item (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    inventory_id UUID NOT NULL REFERENCES inventory(id) ON DELETE CASCADE,
    food_id UUID NOT NULL REFERENCES food(id),
    quantity_g DECIMAL(7,2) NOT NULL,
    expiry_date DATE,
    added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Meal Logs
CREATE TABLE meal_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    logged_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    meal_type VARCHAR(20) NOT NULL CHECK (meal_type IN (
        'breakfast', 'morning_snack', 'lunch',
        'afternoon_snack', 'dinner', 'late_snack'
    )),

    -- Photo & AI
    photo_url TEXT,
    ai_confidence DECIMAL(3,2), -- 0.00 - 1.00
    user_verified BOOLEAN DEFAULT FALSE,

    -- Calculated Totals
    total_kcal INTEGER NOT NULL,
    total_protein DECIMAL(5,2) NOT NULL,
    total_carbs DECIMAL(5,2) NOT NULL,
    total_fat DECIMAL(5,2) NOT NULL,
    total_fiber DECIMAL(5,2) DEFAULT 0,

    -- Context
    timing_context VARCHAR(20) CHECK (timing_context IN ('pre_workout', 'post_workout', 'normal')),
    adherence_score INTEGER CHECK (adherence_score >= 0 AND adherence_score <= 100), -- vs plan
    notes TEXT,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE meal_log_item (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    meal_log_id UUID NOT NULL REFERENCES meal_log(id) ON DELETE CASCADE,
    food_id UUID NOT NULL REFERENCES food(id),
    quantity_g DECIMAL(6,2) NOT NULL,

    -- AI tracking
    ai_detected BOOLEAN DEFAULT FALSE,
    user_adjusted BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Post-meal Feedback (for Correlation Engine)
CREATE TABLE meal_feedback (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    meal_log_id UUID NOT NULL REFERENCES meal_log(id) ON DELETE CASCADE,

    energy_level INTEGER CHECK (energy_level >= 1 AND energy_level <= 10),
    satiety_level INTEGER CHECK (satiety_level >= 1 AND satiety_level <= 10),
    bloating BOOLEAN DEFAULT FALSE,
    brain_fog BOOLEAN DEFAULT FALSE,
    cravings BOOLEAN DEFAULT FALSE,
    notes TEXT,

    logged_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Daily Nutrition Summary
CREATE TABLE daily_nutrition (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,

    hunger_avg INTEGER CHECK (hunger_avg >= 1 AND hunger_avg <= 5),
    energy_avg INTEGER CHECK (energy_avg >= 1 AND energy_avg <= 5),
    digestion_score INTEGER CHECK (digestion_score >= 1 AND digestion_score <= 5),
    cravings_had BOOLEAN DEFAULT FALSE,
    adherence_self VARCHAR(10) CHECK (adherence_self IN ('high', 'medium', 'low')),

    -- AI Adjustment suggestion
    ai_adjustment JSONB, -- {kcal_delta, carb_delta, protein_delta, reason}

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(user_id, date)
);

-- ===================
-- TRAINING DOMAIN
-- ===================

-- Exercise Library
CREATE TABLE exercise (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    name_es VARCHAR(100),

    muscle_primary VARCHAR(50) NOT NULL,
    muscle_secondary JSONB DEFAULT '[]'::jsonb, -- ["biceps", "forearms"]
    equipment VARCHAR(50), -- barbell, dumbbell, machine, bodyweight, cable
    exercise_type VARCHAR(20) NOT NULL CHECK (exercise_type IN ('strength', 'isometric', 'cardio')),

    video_urls JSONB DEFAULT '[]'::jsonb, -- [youtube_url1, youtube_url2]
    cues JSONB DEFAULT '[]'::jsonb, -- ["Squeeze at top", "Control descent"]
    description TEXT,

    is_compound BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Workout Routines (Templates)
CREATE TABLE workout_routine (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    name VARCHAR(100) NOT NULL, -- "UPPER POWER A"
    routine_type VARCHAR(50), -- upper_lower, ppl, full_body, custom
    day_of_week INTEGER CHECK (day_of_week >= 0 AND day_of_week <= 6), -- 0=Sunday
    estimated_mins INTEGER,
    muscle_groups JSONB DEFAULT '[]'::jsonb, -- ["chest", "shoulders", "triceps"]

    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE routine_exercise (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    routine_id UUID NOT NULL REFERENCES workout_routine(id) ON DELETE CASCADE,
    exercise_id UUID NOT NULL REFERENCES exercise(id),

    order_index INTEGER NOT NULL,
    target_sets INTEGER NOT NULL,
    target_reps VARCHAR(20), -- "8-12" or "10" or NULL for isometric
    target_weight_kg DECIMAL(5,2), -- Auto-suggested based on history
    rest_seconds INTEGER DEFAULT 90,
    notes TEXT,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Workout Sessions (Actual workouts)
CREATE TABLE workout_session (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    routine_id UUID REFERENCES workout_routine(id),

    started_at TIMESTAMP WITH TIME ZONE NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),

    -- Location (for geofencing)
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    gym_detected BOOLEAN DEFAULT FALSE,

    -- Aggregated Stats
    total_tonnage_kg DECIMAL(10, 2),
    avg_rpe DECIMAL(3, 1),
    total_duration_mins INTEGER,

    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE exercise_set (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES workout_session(id) ON DELETE CASCADE,
    exercise_id UUID NOT NULL REFERENCES exercise(id),

    set_number INTEGER NOT NULL,
    weight_kg DECIMAL(5, 2), -- NULL for bodyweight/isometric
    reps_completed INTEGER, -- NULL for isometric
    duration_secs INTEGER, -- For isometric/cardio
    rpe INTEGER CHECK (rpe >= 1 AND rpe <= 10),

    is_warmup BOOLEAN DEFAULT FALSE,
    is_dropset BOOLEAN DEFAULT FALSE,
    technique_fail BOOLEAN DEFAULT FALSE,
    assistance_kg DECIMAL(5, 2), -- For assisted pullups (negative = assistance)

    rest_actual_secs INTEGER,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Muscle Fatigue Tracking
CREATE TABLE muscle_fatigue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    muscle_group VARCHAR(50) NOT NULL,
    fatigue_score INTEGER CHECK (fatigue_score >= 0 AND fatigue_score <= 100),
    recovery_eta_hours INTEGER, -- Estimated hours until recovered
    last_trained_at TIMESTAMP WITH TIME ZONE,

    calculated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(user_id, muscle_group)
);

-- ===================
-- PRODUCTIVITY DOMAIN
-- ===================

-- Tasks (Internal + ClickUp sync)
CREATE TABLE task (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    external_id VARCHAR(100), -- ClickUp task ID
    title VARCHAR(255) NOT NULL,
    description TEXT,

    source VARCHAR(20) DEFAULT 'internal' CHECK (source IN ('internal', 'clickup', 'calendar')),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    priority VARCHAR(10) CHECK (priority IN ('high', 'medium', 'low')),

    due_date TIMESTAMP WITH TIME ZONE,
    estimated_mins INTEGER,
    category VARCHAR(20) CHECK (category IN ('deep_work', 'shallow', 'meeting', 'personal')),

    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Work/Focus Sessions
CREATE TABLE work_session (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    task_id UUID REFERENCES task(id),

    source VARCHAR(20) DEFAULT 'internal' CHECK (source IN ('internal', 'toggl')),
    external_id VARCHAR(100), -- Toggl entry ID

    started_at TIMESTAMP WITH TIME ZONE NOT NULL,
    ended_at TIMESTAMP WITH TIME ZONE,
    planned_mins INTEGER,
    actual_mins INTEGER,

    interruptions INTEGER DEFAULT 0,
    idle_detected BOOLEAN DEFAULT FALSE,
    focus_score INTEGER CHECK (focus_score >= 0 AND focus_score <= 100),

    calendar_event_id VARCHAR(100),
    supervisor_alert_sent BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Integration Sync Status
CREATE TABLE integration_sync (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    provider VARCHAR(30) NOT NULL CHECK (provider IN ('toggl', 'clickup', 'gcal', 'healthkit', 'health_connect')),
    last_sync_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) DEFAULT 'inactive' CHECK (status IN ('active', 'inactive', 'error')),

    access_token_enc TEXT, -- Encrypted
    refresh_token_enc TEXT, -- Encrypted
    token_expires_at TIMESTAMP WITH TIME ZONE,

    settings JSONB DEFAULT '{}'::jsonb,
    error_message TEXT,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(user_id, provider)
);

-- ===================
-- HABITS DOMAIN
-- ===================

CREATE TABLE habit (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    name VARCHAR(100) NOT NULL,
    description TEXT,
    habit_type VARCHAR(20) NOT NULL CHECK (habit_type IN ('check_simple', 'quantitative', 'evidence', 'integrated')),

    -- For quantitative habits
    target_value DECIMAL(10, 2),
    unit VARCHAR(30), -- "pages", "minutes", "ml"

    -- Scheduling
    frequency VARCHAR(20) DEFAULT 'daily' CHECK (frequency IN ('daily', 'weekly', 'custom')),
    time_of_day VARCHAR(20) CHECK (time_of_day IN ('morning', 'afternoon', 'evening', 'anytime')),
    days_of_week JSONB DEFAULT '[0,1,2,3,4,5,6]'::jsonb, -- Active days

    -- Integration
    source_api VARCHAR(30), -- toggl, duolingo, etc.
    verification_type VARCHAR(20) CHECK (verification_type IN ('manual', 'screenshot', 'api')),

    -- Rewards
    xp_value INTEGER DEFAULT 10,
    coins_value INTEGER DEFAULT 5,

    is_active BOOLEAN DEFAULT TRUE,
    order_index INTEGER DEFAULT 0,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE habit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    habit_id UUID NOT NULL REFERENCES habit(id) ON DELETE CASCADE,

    date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'done', 'skipped')),

    -- For quantitative habits
    value DECIMAL(10, 2),

    -- For evidence-based habits
    evidence_url TEXT,
    evidence_valid BOOLEAN,

    -- Rewards earned
    xp_earned INTEGER DEFAULT 0,
    coins_earned INTEGER DEFAULT 0,

    logged_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(habit_id, date)
);

CREATE TABLE habit_evidence (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    habit_log_id UUID NOT NULL REFERENCES habit_log(id) ON DELETE CASCADE,

    image_url TEXT NOT NULL,
    ocr_result JSONB, -- AI extraction result
    ai_validation VARCHAR(20) CHECK (ai_validation IN ('valid', 'invalid', 'uncertain')),
    extracted_value TEXT,

    processed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===================
-- GAMIFICATION DOMAIN
-- ===================

-- User Currency & Stats
CREATE TABLE currency (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    xp_total BIGINT DEFAULT 0, -- Never decreases
    xp_weekly BIGINT DEFAULT 0, -- For leagues, resets weekly
    coins_balance INTEGER DEFAULT 0, -- Spendable

    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Streaks
CREATE TABLE streak (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    streak_type VARCHAR(20) NOT NULL CHECK (streak_type IN ('streak_light', 'streak_perfect')),
    current_count INTEGER DEFAULT 0,
    longest_count INTEGER DEFAULT 0,

    last_extended_at DATE,
    freeze_available INTEGER DEFAULT 0, -- Number of freezes owned
    frozen_today BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(user_id, streak_type)
);

-- Cosmetics (Avatar items, themes, etc.)
CREATE TABLE cosmetic (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    name VARCHAR(100) NOT NULL,
    description TEXT,
    cosmetic_type VARCHAR(30) NOT NULL CHECK (cosmetic_type IN ('avatar', 'frame', 'aura', 'theme', 'badge')),

    coin_cost INTEGER,
    xp_requirement INTEGER,
    rarity VARCHAR(20) CHECK (rarity IN ('common', 'rare', 'epic', 'legendary')),

    duration_days INTEGER, -- NULL = permanent
    streak_required INTEGER, -- Streak to maintain (for aura-type)

    image_url TEXT,
    preview_url TEXT,

    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User's owned cosmetics
CREATE TABLE user_cosmetic (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    cosmetic_id UUID NOT NULL REFERENCES cosmetic(id),

    acquired_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE, -- NULL = permanent
    is_equipped BOOLEAN DEFAULT FALSE,

    UNIQUE(user_id, cosmetic_id)
);

-- Currency Transactions (Audit log)
CREATE TABLE currency_tx (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    currency_type VARCHAR(10) NOT NULL CHECK (currency_type IN ('xp', 'coins')),
    amount INTEGER NOT NULL, -- Positive = earn, negative = spend
    balance_after INTEGER NOT NULL,

    reason VARCHAR(100) NOT NULL,
    reference_type VARCHAR(30), -- habit, workout, purchase, chest
    reference_id UUID,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Chests (Loot boxes)
CREATE TABLE chest (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    chest_type VARCHAR(20) NOT NULL CHECK (chest_type IN ('daily', 'streak', 'achievement', 'purchase')),
    coins_amount INTEGER NOT NULL,
    item_won_id UUID REFERENCES cosmetic(id),

    opened_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===================
-- SOCIAL DOMAIN
-- ===================

CREATE TABLE user_group (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    name VARCHAR(100) NOT NULL,
    description TEXT,
    invite_code VARCHAR(20) UNIQUE NOT NULL,
    max_members INTEGER DEFAULT 10,

    created_by UUID NOT NULL REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE group_member (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_id UUID NOT NULL REFERENCES user_group(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    role VARCHAR(20) DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member')),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    audit_permission BOOLEAN DEFAULT FALSE, -- Can see others' detailed data

    UNIQUE(group_id, user_id)
);

CREATE TABLE challenge (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_id UUID REFERENCES user_group(id) ON DELETE CASCADE,

    name VARCHAR(100) NOT NULL,
    description TEXT,
    challenge_type VARCHAR(20) NOT NULL CHECK (challenge_type IN ('individual', 'group_goal', 'pvp')),

    metric VARCHAR(50) NOT NULL, -- steps, focus_minutes, workouts, habit_completion
    target_value DECIMAL(10, 2),

    starts_at TIMESTAMP WITH TIME ZONE NOT NULL,
    ends_at TIMESTAMP WITH TIME ZONE NOT NULL,

    created_by UUID NOT NULL REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE challenge_member (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    challenge_id UUID NOT NULL REFERENCES challenge(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    progress DECIMAL(10, 2) DEFAULT 0,
    rank INTEGER,

    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(challenge_id, user_id)
);

-- Boss Raids (Habitica-style)
CREATE TABLE boss_raid (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_id UUID NOT NULL REFERENCES user_group(id) ON DELETE CASCADE,

    boss_name VARCHAR(100) NOT NULL,
    boss_image_url TEXT,
    boss_hp_total INTEGER NOT NULL,
    boss_hp_current INTEGER NOT NULL,

    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ends_at TIMESTAMP WITH TIME ZONE NOT NULL,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'won', 'lost')),

    loot_pool JSONB DEFAULT '[]'::jsonb, -- [{cosmetic_id, chance}]

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE boss_raid_member (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    raid_id UUID NOT NULL REFERENCES boss_raid(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    damage_dealt INTEGER DEFAULT 0,
    healing_caused INTEGER DEFAULT 0, -- From failures

    UNIQUE(raid_id, user_id)
);

-- Leagues
CREATE TABLE league (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    name VARCHAR(50) NOT NULL, -- Bronze, Silver, Gold, Diamond
    tier INTEGER NOT NULL, -- 1=Bronze, 2=Silver, etc.
    week_start DATE NOT NULL,
    week_end DATE NOT NULL,

    UNIQUE(tier, week_start)
);

CREATE TABLE league_placement (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    league_id UUID NOT NULL REFERENCES league(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    xp_earned BIGINT DEFAULT 0,
    rank INTEGER,
    promoted BOOLEAN DEFAULT FALSE,
    demoted BOOLEAN DEFAULT FALSE,

    UNIQUE(league_id, user_id)
);

-- ===================
-- CORRELATION & INSIGHTS
-- ===================

-- Daily Score (Aggregated for Correlation Engine)
CREATE TABLE daily_score (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,

    -- Sleep
    sleep_hours DECIMAL(4, 2),
    sleep_quality INTEGER CHECK (sleep_quality >= 1 AND sleep_quality <= 10),
    sleep_debt_hrs DECIMAL(4, 2),

    -- Nutrition
    kcal_consumed INTEGER,
    kcal_burned INTEGER,
    protein_g INTEGER,
    carbs_g INTEGER,
    fat_g INTEGER,
    water_ml INTEGER,
    macro_adherence INTEGER CHECK (macro_adherence >= 0 AND macro_adherence <= 100),

    -- Activity
    steps INTEGER,
    active_minutes INTEGER,
    workout_done BOOLEAN DEFAULT FALSE,
    workout_tonnage DECIMAL(10, 2),
    workout_avg_rpe DECIMAL(3, 1),

    -- Focus
    focus_minutes INTEGER,
    tasks_completed INTEGER,
    interruptions INTEGER,

    -- Habits
    habits_total INTEGER,
    habits_completed INTEGER,
    completion_pct INTEGER CHECK (completion_pct >= 0 AND completion_pct <= 100),

    -- Self-reported
    energy_reported INTEGER CHECK (energy_reported >= 1 AND energy_reported <= 10),
    mood_reported INTEGER CHECK (mood_reported >= 1 AND mood_reported <= 10),

    -- Composite
    daily_score INTEGER CHECK (daily_score >= 0 AND daily_score <= 100),

    calculated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(user_id, date)
);

-- AI-Generated Insights
CREATE TABLE insight (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    insight_type VARCHAR(50) NOT NULL, -- sleep_workout, nutrition_focus, etc.
    title VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,

    variables JSONB NOT NULL, -- [{name, correlation_coef}]
    confidence DECIMAL(3, 2) CHECK (confidence >= 0 AND confidence <= 1),
    sample_size INTEGER,

    dismissed BOOLEAN DEFAULT FALSE,
    acted_upon BOOLEAN DEFAULT FALSE,

    generated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===================
-- INDEXES
-- ===================

-- Bio Profile
CREATE INDEX idx_bio_profile_user_id ON bio_profile(user_id);

-- Nutrition
CREATE INDEX idx_meal_log_user_date ON meal_log(user_id, logged_at);
CREATE INDEX idx_meal_log_item_meal ON meal_log_item(meal_log_id);
CREATE INDEX idx_food_name ON food(name);
CREATE INDEX idx_food_barcode ON food(barcode) WHERE barcode IS NOT NULL;

-- Training
CREATE INDEX idx_workout_session_user_date ON workout_session(user_id, started_at);
CREATE INDEX idx_exercise_set_session ON exercise_set(session_id);
CREATE INDEX idx_routine_exercise_routine ON routine_exercise(routine_id);

-- Productivity
CREATE INDEX idx_work_session_user_date ON work_session(user_id, started_at);
CREATE INDEX idx_task_user_status ON task(user_id, status);

-- Habits
CREATE INDEX idx_habit_user ON habit(user_id);
CREATE INDEX idx_habit_log_habit_date ON habit_log(habit_id, date);

-- Gamification
CREATE INDEX idx_currency_user ON currency(user_id);
CREATE INDEX idx_streak_user ON streak(user_id);
CREATE INDEX idx_currency_tx_user_date ON currency_tx(user_id, created_at);

-- Social
CREATE INDEX idx_group_member_user ON group_member(user_id);
CREATE INDEX idx_challenge_member_user ON challenge_member(user_id);

-- Correlation
CREATE INDEX idx_daily_score_user_date ON daily_score(user_id, date);
CREATE INDEX idx_insight_user ON insight(user_id);

-- ===================
-- ROW LEVEL SECURITY (RLS)
-- ===================

ALTER TABLE bio_profile ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_log_item ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_session ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercise_set ENABLE ROW LEVEL SECURITY;
ALTER TABLE habit ENABLE ROW LEVEL SECURITY;
ALTER TABLE habit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE currency ENABLE ROW LEVEL SECURITY;
ALTER TABLE streak ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_score ENABLE ROW LEVEL SECURITY;
ALTER TABLE insight ENABLE ROW LEVEL SECURITY;

-- Policies: Users can only access their own data
CREATE POLICY "Users can view own bio_profile" ON bio_profile FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own bio_profile" ON bio_profile FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own bio_profile" ON bio_profile FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own meal_log" ON meal_log FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own meal_log" ON meal_log FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own meal_log" ON meal_log FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own workout_session" ON workout_session FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own workout_session" ON workout_session FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own workout_session" ON workout_session FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own habit" ON habit FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own habit" ON habit FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own currency" ON currency FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can view own streak" ON streak FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can view own daily_score" ON daily_score FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can view own insight" ON insight FOR SELECT USING (auth.uid() = user_id);

-- Public read for exercises and cosmetics
ALTER TABLE exercise ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view exercises" ON exercise FOR SELECT USING (true);

ALTER TABLE cosmetic ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view cosmetics" ON cosmetic FOR SELECT USING (true);

ALTER TABLE food ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view food" ON food FOR SELECT USING (true);
CREATE POLICY "Users can create custom food" ON food FOR INSERT WITH CHECK (auth.uid() = created_by);

-- ===================
-- FUNCTIONS
-- ===================

-- Function to calculate TDEE
CREATE OR REPLACE FUNCTION calculate_tdee(
    p_weight_kg DECIMAL,
    p_height_cm INTEGER,
    p_age INTEGER,
    p_sex VARCHAR,
    p_activity_level VARCHAR
) RETURNS INTEGER AS $$
DECLARE
    bmr DECIMAL;
    multiplier DECIMAL;
BEGIN
    -- Mifflin-St Jeor Equation
    IF p_sex = 'male' THEN
        bmr := (10 * p_weight_kg) + (6.25 * p_height_cm) - (5 * p_age) + 5;
    ELSE
        bmr := (10 * p_weight_kg) + (6.25 * p_height_cm) - (5 * p_age) - 161;
    END IF;

    -- Activity multiplier
    multiplier := CASE p_activity_level
        WHEN 'sedentary' THEN 1.2
        WHEN 'light' THEN 1.375
        WHEN 'moderate' THEN 1.55
        WHEN 'active' THEN 1.725
        WHEN 'very_active' THEN 1.9
        ELSE 1.55
    END;

    RETURN ROUND(bmr * multiplier);
END;
$$ LANGUAGE plpgsql;

-- Function to update daily score
CREATE OR REPLACE FUNCTION update_daily_score(p_user_id UUID, p_date DATE)
RETURNS VOID AS $$
DECLARE
    v_habits_total INTEGER;
    v_habits_completed INTEGER;
    v_completion_pct INTEGER;
    v_daily_score INTEGER;
BEGIN
    -- Count habits
    SELECT COUNT(*), COUNT(*) FILTER (WHERE hl.status = 'done')
    INTO v_habits_total, v_habits_completed
    FROM habit h
    LEFT JOIN habit_log hl ON h.id = hl.habit_id AND hl.date = p_date
    WHERE h.user_id = p_user_id AND h.is_active = true;

    -- Calculate completion percentage
    v_completion_pct := CASE
        WHEN v_habits_total > 0 THEN ROUND((v_habits_completed::DECIMAL / v_habits_total) * 100)
        ELSE 0
    END;

    -- Calculate daily score (weighted average)
    v_daily_score := v_completion_pct; -- Simplified for MVP

    -- Upsert daily_score
    INSERT INTO daily_score (user_id, date, habits_total, habits_completed, completion_pct, daily_score)
    VALUES (p_user_id, p_date, v_habits_total, v_habits_completed, v_completion_pct, v_daily_score)
    ON CONFLICT (user_id, date) DO UPDATE SET
        habits_total = EXCLUDED.habits_total,
        habits_completed = EXCLUDED.habits_completed,
        completion_pct = EXCLUDED.completion_pct,
        daily_score = EXCLUDED.daily_score,
        calculated_at = NOW();
END;
$$ LANGUAGE plpgsql;

-- Function to update streak
CREATE OR REPLACE FUNCTION update_streak(p_user_id UUID, p_date DATE)
RETURNS VOID AS $$
DECLARE
    v_completion_pct INTEGER;
    v_current_streak_light INTEGER;
    v_current_streak_perfect INTEGER;
    v_last_date DATE;
BEGIN
    -- Get today's completion
    SELECT completion_pct INTO v_completion_pct
    FROM daily_score
    WHERE user_id = p_user_id AND date = p_date;

    IF v_completion_pct IS NULL THEN
        RETURN;
    END IF;

    -- Light streak (60%+)
    SELECT current_count, last_extended_at INTO v_current_streak_light, v_last_date
    FROM streak
    WHERE user_id = p_user_id AND streak_type = 'streak_light';

    IF v_completion_pct >= 60 THEN
        IF v_last_date = p_date - 1 OR v_last_date IS NULL THEN
            -- Extend streak
            INSERT INTO streak (user_id, streak_type, current_count, longest_count, last_extended_at)
            VALUES (p_user_id, 'streak_light', 1, 1, p_date)
            ON CONFLICT (user_id, streak_type) DO UPDATE SET
                current_count = streak.current_count + 1,
                longest_count = GREATEST(streak.longest_count, streak.current_count + 1),
                last_extended_at = p_date,
                updated_at = NOW();
        END IF;
    ELSE
        -- Check for freeze
        UPDATE streak SET
            current_count = CASE WHEN freeze_available > 0 AND NOT frozen_today THEN current_count ELSE 0 END,
            freeze_available = CASE WHEN freeze_available > 0 AND NOT frozen_today THEN freeze_available - 1 ELSE freeze_available END,
            frozen_today = CASE WHEN freeze_available > 0 THEN true ELSE frozen_today END,
            updated_at = NOW()
        WHERE user_id = p_user_id AND streak_type = 'streak_light';
    END IF;

    -- Similar logic for perfect streak (90%+)
    IF v_completion_pct >= 90 THEN
        INSERT INTO streak (user_id, streak_type, current_count, longest_count, last_extended_at)
        VALUES (p_user_id, 'streak_perfect', 1, 1, p_date)
        ON CONFLICT (user_id, streak_type) DO UPDATE SET
            current_count = streak.current_count + 1,
            longest_count = GREATEST(streak.longest_count, streak.current_count + 1),
            last_extended_at = p_date,
            updated_at = NOW();
    ELSE
        UPDATE streak SET current_count = 0, updated_at = NOW()
        WHERE user_id = p_user_id AND streak_type = 'streak_perfect'
        AND last_extended_at < p_date;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Trigger to create currency record on user signup
CREATE OR REPLACE FUNCTION create_user_records()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO currency (user_id) VALUES (NEW.id);
    INSERT INTO streak (user_id, streak_type) VALUES (NEW.id, 'streak_light');
    INSERT INTO streak (user_id, streak_type) VALUES (NEW.id, 'streak_perfect');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION create_user_records();
