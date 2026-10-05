// Copyright (c) Files Community
// Licensed under the MIT License.

namespace Files.App.Data.Enums
{
	/// <summary>
	/// Represents UI density mode for file views and navigation controls.
	/// </summary>
	public enum AppDensityKind
	{
		/// <summary>
		/// Standard spacing (Files default).
		/// </summary>
		Normal = 0,

		/// <summary>
		/// Compact spacing with reduced row heights and margins.
		/// </summary>
		Compact = 1,

		/// <summary>
		/// Ultra-compact OneCommander-style density (~22-24px rows for maximum items per screen).
		/// </summary>
		UltraCompact = 2,
	}
}
