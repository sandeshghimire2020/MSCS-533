using LocationTracker.Views;

namespace LocationTracker;

/// <summary>
/// The application object. Shows <see cref="MainView"/> inside a
/// NavigationPage so it gets the purple title bar from the reference design.
/// </summary>
public partial class App : Application
{
    private readonly MainView _mainView;

    public App(MainView mainView)
    {
        InitializeComponent();
        _mainView = mainView;
    }

    protected override Window CreateWindow(IActivationState? activationState)
    {
        var navigation = new NavigationPage(_mainView)
        {
            BarBackgroundColor = Color.FromArgb("#512BD4"),
            BarTextColor = Colors.White,
        };

        return new Window(navigation);
    }
}
