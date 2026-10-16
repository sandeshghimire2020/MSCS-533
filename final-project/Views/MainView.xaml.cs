using System.ComponentModel;
using LocationTracker.ViewModels;

namespace LocationTracker.Views;

/// <summary>
/// Code-behind for the main screen. Kept to view-only concerns: loading data
/// when shown, framing the map, and confirming before data is deleted.
/// </summary>
public partial class MainView : ContentPage
{
    private readonly MainViewModel _viewModel;

    // The map is framed around the points once; after that the user's own
    // panning and zooming is left alone.
    private bool _hasFramedPoints;

    public MainView(MainViewModel viewModel)
    {
        InitializeComponent();
        _viewModel = viewModel;
        BindingContext = viewModel;
        _viewModel.PropertyChanged += OnViewModelPropertyChanged;
    }

    protected override async void OnAppearing()
    {
        base.OnAppearing();
        await _viewModel.LoadAsync();
    }

    protected override void OnDisappearing()
    {
        base.OnDisappearing();
        _viewModel.StopTracking();
    }

    /// <summary>Frames the map the first time there is something to show.</summary>
    private void OnViewModelPropertyChanged(object? sender, PropertyChangedEventArgs e)
    {
        if (e.PropertyName != nameof(MainViewModel.Points))
        {
            return;
        }

        if (_viewModel.Points.Count == 0)
        {
            // After a clear, frame the next new points again.
            _hasFramedPoints = false;
        }
        else if (!_hasFramedPoints)
        {
            HeatMapView.ZoomToPoints();
            _hasFramedPoints = true;
        }
    }

    /// <summary>Asks for confirmation, then deletes every saved location.</summary>
    private async void OnClearClicked(object? sender, EventArgs e)
    {
        bool confirmed = await DisplayAlertAsync(
            "Clear heat map",
            "Delete all saved locations? This cannot be undone.",
            "Delete",
            "Cancel");

        if (confirmed)
        {
            await _viewModel.ClearAsync();
        }
    }
}
