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
	/// Search provider utilizing the local Agent Ransack CLI export in silent mode.
	/// </summary>
	public sealed class AgentRansackSearchProvider : ISearchProvider
	{
		private static readonly string[] PossibleExePaths =
		[
			@"C:\Program Files\Mythicsoft\Agent Ransack\AgentRansack.exe",
			@"C:\Program Files (x86)\Mythicsoft\Agent Ransack\AgentRansack.exe"
		];

		private readonly ILogger? _logger;

		public string Id => "agentransack";

		public string DisplayName => "Agent Ransack";

		public bool IsAvailable => GetExecutablePath() is not null;

		public SearchCapabilities Capabilities { get; } = new()
		{
			SupportsContentSearch = true,
			SupportsRegex = true,
			SupportsWildcards = true,
			SupportsDeepVolumes = true,
			IsInstantStreaming = false
		};

		public AgentRansackSearchProvider(ILogger<AgentRansackSearchProvider>? logger = null)
		{
			_logger = logger;
		}

		private static string? GetExecutablePath()
		{
			foreach (var path in PossibleExePaths)
			{
				if (File.Exists(path))
					return path;
			}
			return null;
		}

		public async Task SearchAsync(SearchRequest request, IList<ListedItem> results, CancellationToken cancellationToken)
		{
			var exePath = GetExecutablePath();
			if (exePath is null)
				return;

			var tempOutputFile = Path.Combine(Path.GetTempPath(), $"ar_search_{Guid.NewGuid():N}.csv");

			try
			{
				var arguments = new List<string>
				{
					"-d", $"\"{request.Folder}\"",
					"-f", $"\"{request.Query}\"",
					"-o", $"\"{tempOutputFile}\"",
					"-ofc"
				};

				if (request.SearchContent && !string.IsNullOrEmpty(request.Query))
				{
					arguments.Add("-c");
					arguments.Add($"\"{request.Query}\"");
				}

				if (!request.SearchSubfolders)
				{
					arguments.Add("-s-");
				}

				var startInfo = new ProcessStartInfo
				{
					FileName = exePath,
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

						var parts = line.Split(',');
						if (parts.Length >= 2)
						{
							var folder = parts[0].Trim().Trim('"');
							var fileName = parts[1].Trim().Trim('"');

							if (string.IsNullOrEmpty(fileName))
								continue;

							var fullPath = Path.Combine(folder, fileName);

							var isFolder = Directory.Exists(fullPath);
							var item = new ListedItem(null!)
							{
								ItemPath = fullPath,
								ItemNameRaw = fileName,
								PrimaryItemAttribute = isFolder ? StorageItemTypes.Folder : StorageItemTypes.File
							};

							results.Add(item);
						}
					}
				}
			}
			catch (OperationCanceledException)
			{
				// Cancellation handled gracefully
			}
			catch (Exception ex)
			{
				_logger?.LogWarning(ex, "Agent Ransack search failed for query {Query} in folder {Folder}", request.Query, request.Folder);
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
	}
}
