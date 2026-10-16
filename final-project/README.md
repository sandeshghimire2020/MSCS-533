# Location Heat Map

A .NET MAUI app written in C# that tracks your location, saves each reading to a local SQLite database, and shows where you have been as a heat map on the map.

Built for MSCS-533 Software Engineering and Multiplatform App Development.


## How it works

1. Tap **Start**. The app asks for location permission, then listens for location updates (about one every 5 seconds).
2. Each reading is saved as a row in SQLite (`locations.db3` in the app's data folder).
3. The map draws the saved readings as a heat map. Readings are grouped into grid cells about 20 m wide, and each cell is drawn as a circle coloured by how many readings it holds:

   blue (few) → cyan → green → yellow → red (many)

4. Saved locations are loaded again the next time the app opens. **Clear** deletes them all.

## Project structure

| Path | Purpose |
|---|---|
| `Controls/HeatMap.cs` | Custom control that extends the MAUI `Map` and draws the heat map circles |
| `Services/LocationTrackingService.cs` | Requests permission, listens for location changes, saves each reading |
| `Data/LocationDatabase.cs` | SQLite access: save, load all, delete all |
| `Models/LocationPoint.cs` | One saved reading (latitude, longitude, accuracy, time) |
| `ViewModels/MainViewModel.cs` | Screen state and the Start/Stop action |
| `Views/MainView.xaml` | The screen: full-screen map, toolbar buttons, status line |
| `MauiProgram.cs` | Startup: enables Maps and registers services for dependency injection |
| `Platforms/Android/AndroidManifest.xml` | Android permissions and Google Maps API key |
| `Platforms/iOS/Info.plist` | iOS location permission message |
| `Platforms/MacCatalyst/` | Mac location permission and entitlement |

## Requirements

- macOS with Xcode 26.x
- .NET 10 SDK with the MAUI workload (`dotnet workload install maui`)
- For Android: Android SDK, JDK 17, and a Google Maps API key

## Running the app (iOS Simulator)

```bash
./run.sh
```

This opens the iPhone 17 Pro simulator, grants location permission, builds the app, and launches it. The first build takes about a minute. Press Ctrl+C to stop.

To see the heat map without walking around:

1. In the Simulator menu choose **Features → Location → Freeway Drive**.
2. Tap **Start** in the app.
3. Wait a minute or two while circles build up along the route.

### Running manually

```bash
dotnet build -f net10.0-ios -t:Run
```

### Android

1. Get an API key from the [Google Cloud Console](https://console.cloud.google.com) with **Maps SDK for Android** enabled.
2. Replace `YOUR_GOOGLE_MAPS_API_KEY` in `Platforms/Android/AndroidManifest.xml`.
3. Start an Android emulator, then run:

```bash
dotnet build -f net10.0-android -t:Run
```

Without the key the app still runs, but the map area stays blank.

## Troubleshooting

| Problem | Fix |
|---|---|
| `requires Xcode 27.0` | The MAUI workload is newer than your Xcode. Run `dotnet workload update --version 10.0.401`, or install Xcode 27. |
| `Could not resolve SDK "Microsoft.Maui.Sdk"` | The MAUI workload is missing. Run `dotnet workload install maui`. |
| Status says "Could not start tracking" | Location permission was denied. Allow it in Settings → Privacy → Location Services. |
| No circles appear in the simulator | Set a simulated location under **Features → Location**, then tap Start. |

