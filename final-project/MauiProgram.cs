using LocationTracker.Data;
using LocationTracker.Services;
using LocationTracker.ViewModels;
using LocationTracker.Views;
using Microsoft.Extensions.Logging;

namespace LocationTracker;

/// <summary>
/// App entry point shared by every platform: registers the map handler,
/// fonts and the app's services with dependency injection.
/// </summary>
public static class MauiProgram
{
    public static MauiApp CreateMauiApp()
    {
        var builder = MauiApp.CreateBuilder();
        builder
            .UseMauiApp<App>()
            .UseMauiMaps() // Required for the Map control (and so for HeatMap).
            .ConfigureFonts(fonts =>
            {
                fonts.AddFont("OpenSans-Regular.ttf", "OpenSansRegular");
                fonts.AddFont("OpenSans-Semibold.ttf", "OpenSansSemibold");
            });

        // One database connection and one tracker for the whole app.
        builder.Services.AddSingleton<LocationDatabase>();
        builder.Services.AddSingleton(Geolocation.Default);
        builder.Services.AddSingleton<LocationTrackingService>();

        builder.Services.AddTransient<MainViewModel>();
        builder.Services.AddTransient<MainView>();

#if DEBUG
        builder.Logging.AddDebug();
#endif

        return builder.Build();
    }
}
