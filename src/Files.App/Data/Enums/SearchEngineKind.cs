// Copyright (c) Files Community
// Licensed under the MIT License.

namespace Files.App.Data.Enums
{
	/// <summary>
	/// Represents the search engine mechanism selected by the user.
	/// </summary>
	public enum SearchEngineKind
	{
		/// <summary>
		/// Default Files search using Windows Search AQS and Win32 fallback.
		/// </summary>
		Native = 0,

		/// <summary>
		/// Deep content and regex search powered by Agent Ransack CLI.
		/// </summary>
		AgentRansack = 1,

		/// <summary>
		/// Instant NTFS index search powered by voidtools Everything.
		/// </summary>
		Everything = 2
	}
}
