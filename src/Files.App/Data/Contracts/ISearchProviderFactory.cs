// Copyright (c) Files Community
// Licensed under the MIT License.

namespace Files.App.Data.Contracts
{
	/// <summary>
	/// Factory responsible for discovering and providing active search providers.
	/// </summary>
	public interface ISearchProviderFactory
	{
		/// <summary>
		/// Gets the currently active search provider configured by the user, falling back to Native if unavailable.
		/// </summary>
		ISearchProvider GetCurrentProvider();

		/// <summary>
		/// Gets a specific search provider by its identifier.
		/// </summary>
		ISearchProvider? GetProvider(string id);

		/// <summary>
		/// Gets all registered search providers.
		/// </summary>
		IReadOnlyList<ISearchProvider> GetAllProviders();
	}
}