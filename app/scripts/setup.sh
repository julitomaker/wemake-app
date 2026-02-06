#!/bin/bash

# WEMAKE App Setup Script
# Run this script after cloning the repository

set -e

echo "🚀 WEMAKE Setup Script"
echo "======================"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed."
    echo "Please install Flutter from https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"
echo ""

# Check Flutter doctor
echo "Running Flutter doctor..."
flutter doctor
echo ""

# Navigate to app directory
cd "$(dirname "$0")/.."

# Check .env file
if [ ! -f ".env" ]; then
    echo "📝 Creating .env file from .env.example..."
    cp .env.example .env
    echo "⚠️  Please update .env with your Supabase credentials!"
    echo ""
fi

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get
echo ""

# Run build_runner to generate code
echo "🔧 Generating code (Freezed, JSON, etc.)..."
flutter pub run build_runner build --delete-conflicting-outputs
echo ""

# Download fonts (Inter font family)
echo "📥 Note: You need to download Inter font manually"
echo "   Download from: https://fonts.google.com/specimen/Inter"
echo "   Place the following files in assets/fonts/:"
echo "   - Inter-Regular.ttf"
echo "   - Inter-Medium.ttf"
echo "   - Inter-SemiBold.ttf"
echo "   - Inter-Bold.ttf"
echo ""

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Update .env with your Supabase credentials"
echo "2. Run Supabase migrations (see supabase/migrations/)"
echo "3. Download Inter font and place in assets/fonts/"
echo "4. Run: flutter run"
echo ""
echo "Happy building! 🎉"
