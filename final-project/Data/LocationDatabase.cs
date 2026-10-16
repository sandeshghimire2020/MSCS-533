using LocationTracker.Models;
using SQLite;

namespace LocationTracker.Data;

/// <summary>
/// Thin wrapper around an async SQLite connection that stores and reads
/// <see cref="LocationPoint"/> rows. The connection is created lazily the
/// first time it is needed so app startup stays fast.
/// </summary>
public class LocationDatabase
{
    private const string DatabaseFileName = "locations.db3";

    // Open the file read/write, create it if missing, and allow use from multiple threads.
    private const SQLiteOpenFlags OpenFlags =
        SQLiteOpenFlags.ReadWrite | SQLiteOpenFlags.Create | SQLiteOpenFlags.SharedCache;

    private static readonly string DatabasePath =
        Path.Combine(FileSystem.AppDataDirectory, DatabaseFileName);

    private SQLiteAsyncConnection? _connection;

    /// <summary>
    /// Returns the open connection, creating the database and table on first use.
    /// </summary>
    private async Task<SQLiteAsyncConnection> GetConnectionAsync()
    {
        if (_connection is not null)
        {
            return _connection;
        }

        _connection = new SQLiteAsyncConnection(DatabasePath, OpenFlags);
        await _connection.CreateTableAsync<LocationPoint>();
        return _connection;
    }

    /// <summary>Inserts a new location reading.</summary>
    public async Task<int> SaveAsync(LocationPoint point)
    {
        var db = await GetConnectionAsync();
        return await db.InsertAsync(point);
    }

    /// <summary>Returns every saved reading, oldest first.</summary>
    public async Task<List<LocationPoint>> GetAllAsync()
    {
        var db = await GetConnectionAsync();
        return await db.Table<LocationPoint>()
            .OrderBy(p => p.TimestampUtc)
            .ToListAsync();
    }

    /// <summary>Deletes every saved reading.</summary>
    public async Task<int> DeleteAllAsync()
    {
        var db = await GetConnectionAsync();
        return await db.DeleteAllAsync<LocationPoint>();
    }
}
