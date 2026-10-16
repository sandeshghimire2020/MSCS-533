using SQLite;

namespace LocationTracker.Models;

/// <summary>
/// A single GPS reading captured while tracking. Each row in the
/// SQLite "LocationPoints" table is one of these.
/// </summary>
[Table("LocationPoints")]
public class LocationPoint
{
    /// <summary>Auto-incrementing primary key.</summary>
    [PrimaryKey, AutoIncrement]
    public int Id { get; set; }

    /// <summary>Latitude in decimal degrees.</summary>
    public double Latitude { get; set; }

    /// <summary>Longitude in decimal degrees.</summary>
    public double Longitude { get; set; }

    /// <summary>Reported horizontal accuracy in meters, if the platform provides it.</summary>
    public double? Accuracy { get; set; }

    /// <summary>When the reading was taken (UTC).</summary>
    [Indexed]
    public DateTime TimestampUtc { get; set; }
}
