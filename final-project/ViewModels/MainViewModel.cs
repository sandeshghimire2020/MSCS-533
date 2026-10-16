using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Windows.Input;
using LocationTracker.Data;
using LocationTracker.Models;
using LocationTracker.Services;

namespace LocationTracker.ViewModels;

/// <summary>
/// State and actions for <see cref="Views.MainView"/>: the saved points to
/// draw, whether tracking is on, and a short status line.
/// </summary>
public class MainViewModel : INotifyPropertyChanged
{
    private readonly LocationDatabase _database;
    private readonly LocationTrackingService _tracker;

    private IReadOnlyList<LocationPoint> _points = [];
    private string _status = "Tap Start to begin tracking";

    public event PropertyChangedEventHandler? PropertyChanged;

    public MainViewModel(LocationDatabase database, LocationTrackingService tracker)
    {
        _database = database;
        _tracker = tracker;
        _tracker.PointSaved += OnPointSaved;

        ToggleTrackingCommand = new Command(async () => await ToggleTrackingAsync());
    }

    /// <summary>All saved readings. Replaced (not mutated) so the map redraws.</summary>
    public IReadOnlyList<LocationPoint> Points
    {
        get => _points;
        private set
        {
            _points = value;
            OnPropertyChanged();
        }
    }

    /// <summary>One-line summary shown at the bottom of the screen.</summary>
    public string Status
    {
        get => _status;
        private set
        {
            _status = value;
            OnPropertyChanged();
        }
    }

    /// <summary>True while location updates are being received.</summary>
    public bool IsTracking => _tracker.IsTracking;

    /// <summary>Label for the toolbar button.</summary>
    public string ToggleText => IsTracking ? "Stop" : "Start";

    /// <summary>Starts tracking if stopped, stops it if running.</summary>
    public ICommand ToggleTrackingCommand { get; }

    /// <summary>Loads previously saved points from SQLite.</summary>
    public async Task LoadAsync()
    {
        Points = await _database.GetAllAsync();
        Status = Points.Count == 0
            ? "No saved locations yet. Tap Start to begin tracking."
            : $"{Points.Count} saved locations";
    }

    /// <summary>Deletes all saved points and clears the map.</summary>
    public async Task ClearAsync()
    {
        await _database.DeleteAllAsync();
        Points = [];
        Status = IsTracking ? "Cleared. Still tracking..." : "Cleared";
    }

    /// <summary>Stops tracking. Called when the page goes away.</summary>
    public void StopTracking()
    {
        _tracker.Stop();
        RaiseTrackingChanged();
    }

    private async Task ToggleTrackingAsync()
    {
        if (IsTracking)
        {
            _tracker.Stop();
            Status = $"Stopped. {Points.Count} saved locations";
        }
        else
        {
            bool started = await _tracker.StartAsync();
            Status = started
                ? "Tracking... move around to build the heat map"
                : "Could not start tracking. Check location permission and settings.";
        }

        RaiseTrackingChanged();
    }

    /// <summary>
    /// Adds a newly saved reading. The tracking service may raise this on a
    /// background thread, so the update is moved to the UI thread.
    /// </summary>
    private void OnPointSaved(object? sender, LocationPoint point)
    {
        MainThread.BeginInvokeOnMainThread(() =>
        {
            Points = [.. Points, point];
            Status = $"Tracking... {Points.Count} saved locations";
        });
    }

    private void RaiseTrackingChanged()
    {
        OnPropertyChanged(nameof(IsTracking));
        OnPropertyChanged(nameof(ToggleText));
    }

    private void OnPropertyChanged([CallerMemberName] string? name = null) =>
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
}
