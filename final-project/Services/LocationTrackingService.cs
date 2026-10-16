using LocationTracker.Data;
using LocationTracker.Models;
using Microsoft.Extensions.Logging;

namespace LocationTracker.Services;

/// <summary>
/// Listens for location changes from the device, saves each reading to
/// SQLite, and notifies subscribers so the map can redraw.
/// </summary>
public class LocationTrackingService
{
    // Ask the OS for an update at most every 5 seconds with high accuracy.
    private static readonly GeolocationListeningRequest ListeningRequest =
        new(GeolocationAccuracy.Best, TimeSpan.FromSeconds(5));

    private readonly LocationDatabase _database;
    private readonly IGeolocation _geolocation;
    private readonly ILogger<LocationTrackingService> _logger;

    /// <summary>Raised after a new reading has been saved to the database.</summary>
    public event EventHandler<LocationPoint>? PointSaved;

    /// <summary>True while the app is receiving location updates.</summary>
    public bool IsTracking => _geolocation.IsListeningForeground;

    public LocationTrackingService(
        LocationDatabase database,
        IGeolocation geolocation,
        ILogger<LocationTrackingService> logger)
    {
        _database = database;
        _geolocation = geolocation;
        _logger = logger;
    }

    /// <summary>
    /// Requests "when in use" location permission if needed, then starts
    /// listening. Returns false if permission was denied or listening failed.
    /// </summary>
    public async Task<bool> StartAsync()
    {
        if (IsTracking)
        {
            return true;
        }

        var status = await Permissions.CheckStatusAsync<Permissions.LocationWhenInUse>();
        if (status != PermissionStatus.Granted)
        {
            status = await Permissions.RequestAsync<Permissions.LocationWhenInUse>();
        }

        if (status != PermissionStatus.Granted)
        {
            _logger.LogWarning("Location permission was not granted ({Status}).", status);
            return false;
        }

        _geolocation.LocationChanged += OnLocationChanged;

        try
        {
            return await _geolocation.StartListeningForegroundAsync(ListeningRequest);
        }
        catch (Exception ex) when (ex is FeatureNotSupportedException or FeatureNotEnabledException)
        {
            // Location services are off or the device has no GPS.
            _logger.LogError(ex, "Could not start location updates.");
            _geolocation.LocationChanged -= OnLocationChanged;
            return false;
        }
    }

    /// <summary>Stops listening for location updates.</summary>
    public void Stop()
    {
        if (!IsTracking)
        {
            return;
        }

        _geolocation.StopListeningForeground();
        _geolocation.LocationChanged -= OnLocationChanged;
    }

    /// <summary>
    /// Called by the platform for each new reading. Saves it and raises
    /// <see cref="PointSaved"/>. async void is acceptable here because this
    /// is an event handler; every exception is caught so none can escape.
    /// </summary>
    private async void OnLocationChanged(object? sender, GeolocationLocationChangedEventArgs e)
    {
        try
        {
            var point = new LocationPoint
            {
                Latitude = e.Location.Latitude,
                Longitude = e.Location.Longitude,
                Accuracy = e.Location.Accuracy,
                TimestampUtc = e.Location.Timestamp.UtcDateTime
            };

            await _database.SaveAsync(point);
            PointSaved?.Invoke(this, point);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to save a location reading.");
        }
    }
}
