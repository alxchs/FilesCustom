// Copyright (c) Files Community
// Licensed under the MIT License.

using Files.App.Data.Contracts;
using Files.App.Data.Items;
using Microsoft.Extensions.Logging;
using System.Diagnostics;
using System.IO;
using Windows.Storage;

namespace Files.App.Services.Search
{
	/// <summary>
	/// Search provider utilizing voidtools Everything index or CLI.
	/// </summary>
	public sealed class EverythingSearchProvider : ISearchProvider
	{
		private static readonly string[] PossibleEsPaths =
		[
			@"C:\Program Files\Everything\es.exe",
			@"C:\Program Files (x86)\Everything\es.exe"
		];

		private readonly NativeFilesSearchProvider _fallbackProvider = new();
		private readonly ILogger? _logger;

		public string Id => "everything";

		public string DisplayName => "Everything";

		public bool IsAvailable
		{
			get
			{
				try
				{
					return Process.GetProcessesByName("Everything").Length > 0 || GetEsPath() is not null;
				}
				catch
				{
					return false;
				}
			}
		}

		public SearchCapabilities Capabilities { get; } = new()
		{
			SupportsContentSearch = false,
			SupportsRegex = true,
			SupportsWildcards = true,
			SupportsDeepVolumes = true,
			IsInstantStreaming = true
		};

		public EverythingSearchProvider(ILogger<EverythingSearchProvider>? logger = null)
		{
			_logger = logger;
		}

		private static string? GetEsPath()
		{
			foreach (var path in PossibleEsPaths)
			{
				if (File.Exists(path))
					return path;
			}
			return null;
		}

		public async Task SearchAsync(SearchRequest request, IList<ListedItem> results, CancellationToken cancellationToken)
		{
			var esPath = GetEsPath();
			if (esPath is not null)
			{
				var tempOutputFile = Path.Combine(Path.GetTempPath(), $"everything_search_{Guid.NewGuid():N}.csv");
				try
				{
					var arguments = new List<string>
					{
						"-path", $"\"{request.Folder}\"",
						$"\"{request.Query}\"",
						"-export-csv", $"\"{tempOutputFile}\""
					};

					var startInfo = new ProcessStartInfo
					{
						FileName = esPath,
						Arguments = string.Join(" ", arguments),
						UseShellExecute = false,
						CreateNoWindow = true,
						WindowStyle = ProcessWindowStyle.Hidden
					};

					using var process = new Process { StartInfo = startInfo };
					process.Start();

					using (cancellationToken.Register(() =>
					{
						try
						{
							if (!process.HasExited)
								process.Kill();
						}
						catch { }
					}))
					{
						await process.WaitForExitAsync(cancellationToken);
					}

					if (File.Exists(tempOutputFile))
					{
						var lines = await File.ReadAllLinesAsync(tempOutputFile, cancellationToken);
						foreach (var line in lines)
						{
							if (string.IsNullOrWhiteSpace(line))
								continue;

							var path = line.Trim().Trim('"');
							if (string.IsNullOrEmpty(path))
								continue;

							var fileName = Path.GetFileName(path);
							var isFolder = Directory.Exists(path);

							var item = new ListedItem(null!)
							{
								ItemPath = path,
								ItemNameRaw = fileName,
								PrimaryItemAttribute = isFolder ? StorageItemTypes.Folder : StorageItemTypes.File
							};

							results.Add(item);
						}
						return;
					}
				}
				catch (OperationCanceledException)
				{
					return;
				}
				catch (Exception ex)
				{
					_logger?.LogWarning(ex, "Everything CLI search failed for query {Query}", request.Query);
				}
				finally
				{
					try
					{
						if (File.Exists(tempOutputFile))
							File.Delete(tempOutputFile);
					}
					catch { }
				}
			}

			// Fallback to Native Files Search when Everything CLI/IPC is not directly invokable
			await _fallbackProvider.SearchAsync(request, results, cancellationToken);
		}
	}
}
