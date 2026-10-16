using LocationTracker.Models;
using Microsoft.Maui.Maps;
using MapCircle = Microsoft.Maui.Controls.Maps.Circle;
using MauiMap = Microsoft.Maui.Controls.Maps.Map;

namespace LocationTracker.Controls;

/// <summary>
/// A <see cref="MauiMap"/> that can draw a heat map. Saved locations are
/// grouped into small square grid cells; each cell is drawn as a circle
/// whose color shows how many readings fell inside it, from blue (few)
/// to red (many).
/// </summary>
public class HeatMap : MauiMap
{
    // Roughly how many meters one degree of latitude spans.
    private const double MetersPerDegreeLatitude = 111_320;

    // Gradient stops from "cold" to "hot": blue, cyan, green, yellow, red.
    private static readonly Color[] Gradient =
    [
        Color.FromArgb("#2B5BFF"),
        Color.FromArgb("#00C8FF"),
        Color.FromArgb("#2EE65A"),
        Color.FromArgb("#FFE100"),
        Color.FromArgb("#FF2E2E"),
    ];

    /// <summary>The readings to visualize. Setting this redraws the heat map.</summary>
    public static readonly BindableProperty PointsProperty = BindableProperty.Create(
        nameof(Points),
        typeof(IReadOnlyList<LocationPoint>),
        typeof(HeatMap),
        defaultValue: null,
        propertyChanged: (bindable, _, _) => ((HeatMap)bindable).Redraw());

    /// <summary>Width of one grid cell in meters. Smaller cells give a finer map.</summary>
    public static readonly BindableProperty CellSizeMetersProperty = BindableProperty.Create(
        nameof(CellSizeMeters),
        typeof(double),
        typeof(HeatMap),
        defaultValue: 20.0,
        propertyChanged: (bindable, _, _) => ((HeatMap)bindable).Redraw());

    public IReadOnlyList<LocationPoint>? Points
    {
        get => (IReadOnlyList<LocationPoint>?)GetValue(PointsProperty);
        set => SetValue(PointsProperty, value);
    }

    public double CellSizeMeters
    {
        get => (double)GetValue(CellSizeMetersProperty);
        set => SetValue(CellSizeMetersProperty, value);
    }

    /// <summary>
    /// Moves the camera so every saved point is visible. Does nothing if
    /// there are no points yet.
    /// </summary>
    public void ZoomToPoints()
    {
        var points = Points;
        if (points is null || points.Count == 0)
        {
            return;
        }

        double minLat = points.Min(p => p.Latitude);
        double maxLat = points.Max(p => p.Latitude);
        double minLon = points.Min(p => p.Longitude);
        double maxLon = points.Max(p => p.Longitude);

        var center = new Location((minLat + maxLat) / 2, (minLon + maxLon) / 2);

        // Add 20% padding and never zoom in tighter than about 500 m across.
        double latSpan = Math.Max((maxLat - minLat) * 1.2, 0.005);
        double lonSpan = Math.Max((maxLon - minLon) * 1.2, 0.005);

        MoveToRegion(new MapSpan(center, latSpan, lonSpan));
    }

    /// <summary>
    /// Rebuilds the circles drawn on the map from <see cref="Points"/>.
    /// </summary>
    private void Redraw()
    {
        MapElements.Clear();

        var points = Points;
        if (points is null || points.Count == 0)
        {
            return;
        }

        var cells = BuildCells(points, CellSizeMeters);
        int maxCount = cells.Max(c => c.Count);

        // Draw cold cells first so hot cells end up on top where circles overlap.
        foreach (var cell in cells.OrderBy(c => c.Count))
        {
            // 0.0 = coldest cell, 1.0 = hottest. With one visit everywhere, all cells are cold.
            double intensity = maxCount == 1 ? 0 : (cell.Count - 1) / (double)(maxCount - 1);
            var color = ColorFor(intensity);

            MapElements.Add(new MapCircle
            {
                Center = cell.Center,
                Radius = Distance.FromMeters(CellSizeMeters * 0.75),
                FillColor = color.WithAlpha(0.6f),
                StrokeColor = color.WithAlpha(0.9f),
                StrokeWidth = 1,
            });
        }
    }

    /// <summary>
    /// Groups points into square cells about <paramref name="cellSizeMeters"/>
    /// wide and returns each non-empty cell's average position and point count.
    /// </summary>
    private static List<HeatCell> BuildCells(IReadOnlyList<LocationPoint> points, double cellSizeMeters)
    {
        // Convert the cell size from meters to degrees. A degree of longitude
        // shrinks toward the poles, so scale it by the cosine of the latitude.
        double referenceLat = points.Average(p => p.Latitude);
        double cellLatDeg = cellSizeMeters / MetersPerDegreeLatitude;
        double cellLonDeg = cellSizeMeters /
            (MetersPerDegreeLatitude * Math.Cos(referenceLat * Math.PI / 180));

        return points
            .GroupBy(p => (Row: (long)Math.Floor(p.Latitude / cellLatDeg),
                           Col: (long)Math.Floor(p.Longitude / cellLonDeg)))
            .Select(g => new HeatCell(
                new Location(g.Average(p => p.Latitude), g.Average(p => p.Longitude)),
                g.Count()))
            .ToList();
    }

    /// <summary>
    /// Maps an intensity from 0 to 1 onto the blue-to-red gradient by
    /// blending the two nearest gradient stops.
    /// </summary>
    private static Color ColorFor(double intensity)
    {
        double scaled = Math.Clamp(intensity, 0, 1) * (Gradient.Length - 1);
        int lower = (int)Math.Floor(scaled);
        int upper = Math.Min(lower + 1, Gradient.Length - 1);
        float t = (float)(scaled - lower);

        Color a = Gradient[lower];
        Color b = Gradient[upper];
        return new Color(
            a.Red + (b.Red - a.Red) * t,
            a.Green + (b.Green - a.Green) * t,
            a.Blue + (b.Blue - a.Blue) * t);
    }

    /// <summary>One grid cell: where it is drawn and how many readings it holds.</summary>
    private sealed record HeatCell(Location Center, int Count);
}
