// Copyright (c) Files Community
// Licensed under the MIT License.

using Files.App.Data.Contracts;
using Files.App.Data.Enums;

namespace Files.App.Services.Search
{
	/// <summary>
	/// Default implementation of ISearchProviderFactory.
	/// </summary>
	public sealed class SearchProviderFactory : ISearchProviderFactory
	{
		private readonly Dictionary<string, ISearchProvider> _providers;
		private readonly ISearchProvider _defaultProvider;
		private readonly IUserSettingsService? _userSettingsService;

		public SearchProviderFactory(IEnumerable<ISearchProvider> providers, IUserSettingsService? userSettingsService = null)
		{
			_providers = providers.ToDictionary(p => p.Id, p => p, StringComparer.OrdinalIgnoreCase);
			_defaultProvider = _providers.TryGetValue("native", out var native)
				? native
				: _providers.Values.FirstOrDefault() ?? new NativeFilesSearchProvider();
			_userSettingsService = userSettingsService;
		}

		public ISearchProvider GetCurrentProvider()
		{
			if (_userSettingsService?.FoldersSettingsService is { } foldersSettings)
			{
				var preferredKind = foldersSettings.SearchEnginePreference;
				var providerId = preferredKind switch
				{
					SearchEngineKind.AgentRansack => "agentransack",
					SearchEngineKind.Everything => "everything",
					_ => "native"
				};

				if (_providers.TryGetValue(providerId, out var provider) && provider.IsAvailable)
					return provider;
			}

			return _defaultProvider;
		}

		public ISearchProvider? GetProvider(string id)
		{
			return _providers.GetValueOrDefault(id);
		}

		public IReadOnlyList<ISearchProvider> GetAllProviders()
		{
			return _providers.Values.ToList().AsReadOnly();
		}
	}
}
