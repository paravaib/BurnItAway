# BurnItAway - iOS App

A calming, ritualistic iOS app built with SwiftUI that helps users release their worries and grow positivity through two therapeutic rituals.

## 🌙 Features

### Burn Your Thought (Free)
- Write down your worries
- Watch them burn away with beautiful particle-based fire animation
- 150+ fire particles cover the screen with realistic movement
- Fire crackle sounds and haptic feedback for immersive experience
- Nothing is saved - completely ephemeral
- Calming completion message

### Grow Positivity (Premium)
- Write positive thoughts
- Watch them transform into glowing seeds/lanterns
- Thoughts are saved locally using CoreData
- View your "Garden of Positivity" anytime

## 🎨 Design

- **Dark, calming UI** with indigo-to-black gradient backgrounds
- **Glowing buttons** with pulsing animations
- **Smooth, slow animations** (6-second cycles)
- **Particle effects** using SwiftUI Canvas
- **High contrast text** for accessibility

## 📱 User Flow

### Burn Ritual
1. Home → "🔥 Burn Your Thought" button
2. Enter worry text → "Release" button
3. Watch text burn with ash particles
4. "It's released. Rest now." completion screen
5. Option to "Do it again" or return home

### Grow Ritual
1. Home → "🌱 Grow Positivity" button
2. Enter positive thought → "Grow" button
3. Watch text transform into glowing orb with lantern particles
4. Thought saved to CoreData
5. Navigate to "Garden of Positivity" list view

## 🏗️ Architecture

```
BurnItAway/
├── BurnItAwayApp.swift              # App entry point with CoreData setup
├── ContentView.swift                # Home screen with ritual buttons
│
├── Views/
│   ├── BurnView.swift              # Burn ritual input screen
│   ├── BurnAnimationView.swift     # Text burning animation
│   ├── BurnCompleteView.swift      # Completion screen
│   ├── StoreView.swift             # Grow ritual input screen
│   ├── StoreAnimationView.swift    # Text transformation animation
│   └── StoredListView.swift        # Garden of saved thoughts
│
├── Components/
│   ├── GlowingButton.swift         # Reusable glowing button component
│   ├── GlowingButtonStyle.swift    # Custom button style for NavigationLink
│   ├── FireAnimation.swift         # Beautiful particle-based fire animation
│   ├── FireSoundManager.swift      # Fire crackle sounds and haptic feedback
│   ├── AshParticles.swift          # Particle system for burn effect
│   └── LanternParticles.swift      # Particle system for store effect
│
├── Persistence/
│   └── PersistenceController.swift # CoreData setup and management
│
└── BurnItAway.xcdatamodeld/        # CoreData model file
```

## 🛠️ Technical Stack

- **SwiftUI** for UI framework
- **CoreData** for local persistence
- **SwiftUI Canvas** for particle animations
- **Core Animation** for smooth transitions
- **Offline-first** architecture

## 🚀 Getting Started

1. Open `BurnItAway.xcodeproj` in Xcode
2. Select your target device/simulator
3. Build and run the project
4. The app will work completely offline

## 📊 CoreData Schema

### PositiveThought Entity
- `id: UUID` - Unique identifier
- `text: String` - The positive thought content
- `date: Date` - When the thought was saved

## 🎯 Future Enhancements (Phase 2)

- **Soundscapes**: Fire crackle with realistic audio processing
- **Alternative animations**: Water dissolve, wind, floating lanterns
- **Settings**: Sound + haptics toggles
- **Monetization**: $2.99/month or $19.99/year subscription
- **Enhanced particles**: More sophisticated SpriteKit integration

## 🎨 Design Guidelines

- **Colors**: Deep indigo, black, orange (burn), green (store)
- **Typography**: Large, white, softly glowing text
- **Animations**: Slow, smooth (.easeInOut, 6-second duration)
- **Accessibility**: High contrast + Dynamic Type support
- **Haptics**: Subtle feedback on button taps

## 📱 App Requirements

- **iOS 15.0+** (SwiftUI 3.0 features)
- **Offline functionality** - no internet required
- **CoreData persistence** for positive thoughts
- **Particle animations** for visual effects
- **Navigation flow** between all screens

## 🔧 Development Notes

- All animations use SwiftUI's native animation system
- Particle effects are implemented using Canvas for performance
- CoreData is set up with proper error handling
- Navigation uses NavigationView with programmatic navigation
- The app follows MVVM patterns with SwiftUI best practices

---

*BurnItAway - Helping you release worries and grow positivity* 🔥🌱
