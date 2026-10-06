// Copyright (c) Files Community
// Licensed under the MIT License.

using Files.App.Data.Contracts;
using Files.App.Utils.Storage;

namespace Files.App.Services.Search
{
	/// <summary>
	/// Native search provider utilizing the internal FolderSearch engine (Windows Search AQS + Win32 fallback).
	/// </summary>
	public sealed class NativeFilesSearchProvider : ISearchProvider
	{
		public string Id => "native";

		public string DisplayName => "Files Native";

		public bool IsAvailable => true;

		public SearchCapabilities Capabilities { get; } = new()
		{
			SupportsContentSearch = false,
			SupportsRegex = false,
			SupportsWildcards = true,
			SupportsDeepVolumes = true,
			IsInstantStreaming = true
		};

		public async Task SearchAsync(SearchRequest request, IList<ListedItem> results, CancellationToken cancellationToken)
		{
			var folderSearch = new FolderSearch
			{
				Folder = request.Folder,
				Query = request.Query,
				MaxItemCount = request.MaxItemCount
			};

			await folderSearch.SearchAsync(results, cancellationToken);
		}
	}
}
