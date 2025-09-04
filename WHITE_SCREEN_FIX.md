# 🚨 White Screen Fix - Step by Step

## 🔍 **Problem Diagnosis**
The white screen means the app can't find your video files. This happens when:
1. Video files aren't added to the Xcode project
2. Files aren't added to the app target
3. File names don't match exactly

## 🛠️ **Step 1: Add Video Files to Xcode Project**

### Method A: Drag & Drop (Recommended)
1. **Open Xcode** and your BurnItAway project
2. **In Project Navigator**, find `BurnItAway/Animations/Videos/`
3. **Open Finder** and navigate to your Videos folder
4. **Drag all 4 video files** into the Videos folder in Xcode
5. **IMPORTANT**: Make sure "Add to target: BurnItAway" is checked ✅
6. Click "Add"

### Method B: Add Files Menu
1. **Right-click** on Videos folder in Xcode
2. **Select** "Add Files to BurnItAway"
3. **Navigate** to your Videos folder
4. **Select all 4 files**: fire_background.mp4, shred_background.mp4, soil_background.mp4, water_background.mp4
5. **IMPORTANT**: Make sure "Add to target: BurnItAway" is checked ✅
6. Click "Add"

## 🧪 **Step 2: Test with Debug Logs**

I've added debug logging to help diagnose the issue:

1. **Build and run** your app
2. **Open Xcode Console** (View → Debug Area → Show Debug Area)
3. **Click on Fire ritual**
4. **Look for these messages** in the console:

```
🔍 Loading real animation for ritual: burn
✅ Found fire video: /path/to/fire_background.mp4
🎬 Animation source: fire_background
🎬 Show real animation: true
```

**OR if files not found:**
```
🔍 Loading real animation for ritual: burn
❌ No fire animation files found - using fallback
🎬 Animation source: none
🎬 Show real animation: false
```

## 🔧 **Step 3: Verify File Names**

Make sure your video files are named exactly:
- `fire_background.mp4` (not fire_background.MP4 or fire-background.mp4)
- `shred_background.mp4`
- `soil_background.mp4`
- `water_background.mp4`

## 🎯 **Step 4: Quick Test**

### Test 1: Check if files are in bundle
Add this temporary code to test:

```swift
// Add this to any view for testing
.onAppear {
    let files = ["fire_background.mp4", "shred_background.mp4", "soil_background.mp4", "water_background.mp4"]
    for file in files {
        if Bundle.main.path(forResource: file.replacingOccurrences(of: ".mp4", with: ""), ofType: "mp4") != nil {
            print("✅ Found: \(file)")
        } else {
            print("❌ Missing: \(file)")
        }
    }
}
```

### Test 2: Force fallback animation
If videos still don't work, the app should show your SwiftUI animations instead of a white screen.

## 🚨 **Common Issues & Solutions**

### Issue 1: Files not added to target
**Solution**: Re-add files and make sure "Add to target: BurnItAway" is checked

### Issue 2: Wrong file names
**Solution**: Rename files to match exactly: `fire_background.mp4`

### Issue 3: Files in wrong location
**Solution**: Files should be in `BurnItAway/Animations/Videos/` in Xcode

### Issue 4: Video format issues
**Solution**: Make sure videos are MP4 format (H.264 codec)

## 🎉 **Expected Result**

After fixing:
1. **Fire ritual** should show your fire video background
2. **Console logs** should show "✅ Found fire video"
3. **No white screen** - either video or SwiftUI animation

## 🆘 **Still Having Issues?**

If you're still getting white screen:
1. **Check console logs** for error messages
2. **Try a different ritual** (shred, bury, wash)
3. **Remove video files** temporarily to test SwiftUI fallback
4. **Check file sizes** - videos should be under 50MB each

The debug logs will tell us exactly what's happening! 🔍
