# 🎬 Quick Start: Adding Real Animations

## 🚀 **Easiest Way: Add GIFs (5 minutes)**

### Step 1: Find GIFs
Search for these on [GIPHY.com](https://giphy.com):
- "fire animation" → Save as `fire_animation.gif`
- "water waves" → Save as `water_wave.gif`  
- "paper shredding" → Save as `paper_shred.gif`
- "earth burying" → Save as `earth_bury.gif`

### Step 2: Add to Xcode
1. Open your Xcode project
2. Right-click on your project → "Add Files to BurnItAway"
3. Select your GIF files
4. Make sure "Add to target: BurnItAway" is checked
5. Click "Add"

### Step 3: Test
1. Build and run your app
2. Try a ritual - it will automatically use the GIF if found!
3. If no GIF, it falls back to your current SwiftUI animations

## 🎥 **Better Quality: Add Videos (10 minutes)**

### Step 1: Find Videos
Search on [Pexels.com/videos](https://www.pexels.com/videos/):
- "fire background" → Save as `fire_background.mp4`
- "water waves" → Save as `water_background.mp4`
- "calm nature" → Save as `calm_background.mp4`

### Step 2: Optimize Videos
Use [HandBrake](https://handbrake.fr) (free):
- Format: MP4 (H.264)
- Resolution: 720p
- Duration: 10-30 seconds
- File size: < 5MB each

### Step 3: Add to Xcode
Same process as GIFs - drag and drop into your project.

## ✨ **Professional: Add Lottie (15 minutes)**

### Step 1: Install Lottie
1. In Xcode: File → Add Package Dependencies
2. Enter: `https://github.com/airbnb/lottie-ios`
3. Click "Add Package"

### Step 2: Find Lottie Animations
Go to [LottieFiles.com](https://lottiefiles.com):
- Search "fire" → Download as `fire_lottie.json`
- Search "water" → Download as `water_lottie.json`
- Search "paper" → Download as `shred_lottie.json`
- Search "earth" → Download as `bury_lottie.json`

### Step 3: Add to Project
Drag the .json files into your Xcode project.

## 🎯 **File Naming Convention**

Your app automatically detects these files:
```
fire_animation.gif     → Burn ritual
water_wave.gif         → Wash ritual  
paper_shred.gif        → Shred ritual
earth_bury.gif         → Bury ritual

fire_background.mp4    → Burn background
water_background.mp4   → Wash background
calm_background.mp4    → General background

fire_lottie.json       → Burn Lottie
water_lottie.json      → Wash Lottie
shred_lottie.json      → Shred Lottie
bury_lottie.json       → Bury Lottie
```

## 🔧 **Customization**

### Change Animation Duration:
```swift
// In RealAnimationManager.swift
static let customFireGif = AnimationSource(
    type: .gif, 
    fileName: "fire_animation", 
    duration: 8.0,  // Custom duration
    loop: false     // Don't loop
)
```

### Add Your Own Animations:
1. Add your file to Xcode
2. Update the file name in `RealAnimationManager.swift`
3. The app will automatically use it!

## 📱 **Testing**

1. **With Real Animations**: Add the files and test
2. **Without Real Animations**: Remove files and test fallback
3. **Performance**: Test on older devices
4. **File Size**: Keep total under 50MB

## 🎨 **Recommended Sources**

### Free GIFs:
- [GIPHY](https://giphy.com) - Best selection
- [Tenor](https://tenor.com) - High quality
- [Gfycat](https://gfycat.com) - Professional

### Free Videos:
- [Pexels Videos](https://www.pexels.com/videos/) - Best quality
- [Unsplash Videos](https://unsplash.com/videos) - Nature focus
- [Pixabay Videos](https://pixabay.com/videos/) - Variety

### Free Lottie:
- [LottieFiles](https://lottiefiles.com) - Largest collection
- [Lottie Community](https://lottiefiles.com/community) - User created

## 🚨 **Important Notes**

- **File Size**: Keep total app under 100MB for App Store
- **Performance**: Test on iPhone 8/SE for older device support
- **Battery**: Videos use more battery than GIFs
- **Storage**: Consider downloading animations on-demand for large files

## 🎉 **Result**

Your app will now have:
- ✅ **Realistic animations** when files are present
- ✅ **Graceful fallback** to SwiftUI animations
- ✅ **Automatic detection** - no code changes needed
- ✅ **Professional quality** - like premium apps

Just add the files and your app automatically becomes more realistic! 🚀
