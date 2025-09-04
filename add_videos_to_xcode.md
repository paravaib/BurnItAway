# 🎥 How to Add Your Video Files to Xcode

## ✅ **Your Video Files Are Ready!**

I can see you've added these video files:
- `fire_background.mp4` - For Burn ritual
- `shred_background.mp4` - For Shred ritual  
- `soil_background.mp4` - For Bury ritual
- `water_background.mp4` - For Wash ritual

## 🚀 **Next Steps: Add to Xcode Project**

### Method 1: Drag & Drop (Easiest)
1. **Open Xcode** and your BurnItAway project
2. **Navigate to** `BurnItAway/Animations/Videos/` in the project navigator
3. **Drag the 4 video files** from Finder into the Videos folder in Xcode
4. **Make sure** "Add to target: BurnItAway" is checked
5. **Click** "Add"

### Method 2: Add Files Menu
1. **Right-click** on the Videos folder in Xcode
2. **Select** "Add Files to BurnItAway"
3. **Navigate to** your Videos folder
4. **Select all 4 video files**
5. **Make sure** "Add to target: BurnItAway" is checked
6. **Click** "Add"

## 🔧 **Code is Already Updated!**

I've already updated your code to:
- ✅ **Detect your video files** automatically
- ✅ **Prioritize videos** over GIFs for better quality
- ✅ **Use the correct file names** you've added
- ✅ **Set appropriate durations** for each ritual

## 🎯 **File Mapping**

Your videos will be used as follows:
```
fire_background.mp4  → Burn ritual (10 seconds, loops)
shred_background.mp4 → Shred ritual (8 seconds, loops)  
soil_background.mp4  → Bury ritual (12 seconds, loops)
water_background.mp4 → Wash ritual (10 seconds, loops)
```

## 🧪 **Testing**

After adding to Xcode:
1. **Build and run** your app
2. **Try each ritual** - you should see your video backgrounds!
3. **If videos don't show**, check that files are added to the target
4. **Fallback works** - if videos fail, SwiftUI animations will show

## 🎨 **Expected Result**

Your rituals will now have:
- 🔥 **Realistic fire background** for burning
- 🪓 **Paper shredding background** for shredding  
- 🌱 **Soil/earth background** for burying
- 💧 **Water waves background** for washing

## 🚨 **Troubleshooting**

### If videos don't appear:
1. **Check file names** - must match exactly
2. **Check file format** - must be MP4
3. **Check target** - files must be added to BurnItAway target
4. **Check file size** - keep under 10MB each for performance

### If app crashes:
1. **Check file paths** - videos must be in correct location
2. **Check file format** - use H.264 MP4
3. **Test on device** - videos work better on device than simulator

## 🎉 **You're All Set!**

Once you add the files to Xcode, your app will automatically use these beautiful video backgrounds for a truly immersive ritual experience!

The code is ready - just add the files to Xcode and you're done! 🚀
