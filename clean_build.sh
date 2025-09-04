#!/bin/bash

echo "🧹 Cleaning BurnItAway project..."

# Clean Xcode derived data
echo "Removing Xcode derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/BurnItAway-*

# Clean any build artifacts
echo "Removing build artifacts..."
rm -rf BurnItAway/build
rm -rf BurnItAway/DerivedData

# Check for duplicate CoreData models
echo "Checking CoreData models..."
find . -name "*.xcdatamodeld" -type d

echo "✅ Clean complete!"
echo ""
echo "Next steps:"
echo "1. Open BurnItAway.xcodeproj in Xcode"
echo "2. Go to Product → Clean Build Folder (Cmd+Shift+K)"
echo "3. Build the project (Cmd+B)"
echo ""
echo "The CoreData model should now generate properly without conflicts."
