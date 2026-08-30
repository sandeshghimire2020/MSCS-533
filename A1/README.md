# Unit Converter — Flutter (MSCS-533 Assignment 1)

A small Flutter app that converts between metric and imperial measures:
length, weight, temperature and volume.

## What it does

- Pick a measure family (Length, Weight, Temperature, Volume) from a chip row.
- Choose a **From** and a **To** unit.
- Type a value; the result updates as you type.
- A swap button flips the two units.

Length, weight and volume convert through a base unit (metres, kilograms,
litres). Temperature is special-cased because the scales have different zero
points.


## Setting up on macOS (iOS build)


1. **Install Xcode 15 or newer.** Flutter refuses to build for iOS on
   anything older, and `flutter doctor` will say so explicitly.

   Which version you can install depends on your macOS release: Xcode 16
   requires macOS 14.5 or later, so on macOS 14.3 the newest usable release is
   **Xcode 15.4**. The App Store only ever offers the latest Xcode, so older
   releases come from <https://developer.apple.com/download/all> (a free
   Apple ID is enough). Download the `.xip`, unpack it, and move `Xcode.app`
   into `/Applications`.

   Then register it:

   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   sudo xcodebuild -license accept
   ```

2. **Install CocoaPods** (Flutter uses it for iOS plugins):

   ```bash
   brew install cocoapods
   ```

3. **Install the Flutter SDK**:

   ```bash
   brew install --cask flutter
   flutter --version
   ```

   If you would rather not use Homebrew, download the SDK from
   <https://docs.flutter.dev/get-started/install/macos> and add
   `<sdk>/bin` to your `PATH`.

4. **Check the toolchain**:

   ```bash
   flutter doctor
   ```

   Everything under "Xcode" and "iOS toolchain" should be a green check. The
   Android section can stay red — those warnings do not affect iOS builds, so
   there is no need to install the Android cmdline-tools or accept the
   Android SDK licences for this assignment.

5. **Fetch packages and run it**:

   ```bash
   cd unit_converter
   flutter pub get
   open -a Simulator
   flutter run
   ```

   `flutter devices` lists whatever is connected if the simulator is not
   picked up automatically. If the build fails during `pod install`, run
   `flutter clean` first — stale artefacts from an older Xcode are the usual
   cause.

## Running the tests

```bash
cd unit_converter
flutter test
```

## Taking the screenshot for the report

With the simulator focused, press **Cmd + S** to save a screenshot to the
Desktop, or run:

```bash
xcrun simctl io booted screenshot ~/Desktop/converter.png
```

## Notes

- Lints come from `flutter_lints` plus a few extras in
  `analysis_options.yaml`; run `flutter analyze` before committing.
- Conversion factors use the exact international definitions
  (1 in = 0.0254 m, 1 lb = 0.45359237 kg, 1 US gal = 3.785411784 L).
