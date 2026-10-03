// Copyright (c) Files Community
// Licensed under the MIT License.

using System;

namespace Files.App.Helpers
{
	public sealed class FileNameParts
	{
		public string FullName { get; }
		public string NamePart { get; }
		public string ExtensionPart { get; }
		public bool HasExtension => !string.IsNullOrEmpty(ExtensionPart);
		public int ExtensionStartIndex => NamePart.Length;

		public FileNameParts(string fullName, string namePart, string extensionPart)
		{
			FullName = fullName ?? string.Empty;
			NamePart = namePart ?? string.Empty;
			ExtensionPart = extensionPart ?? string.Empty;
		}
	}

	public static class FileNameExtensionHelper
	{
		private static readonly string[] CompoundExtensions = new string[]
		{
			".tar.gz",
			".tar.bz2",
			".tar.xz",
			".tar.zst",
			".tar.lz",
			".tar.lzma",
			".tar.lzo",
			".tar.z",
			".tar.7z",
			".user.js",
		};

		public static FileNameParts Split(string? fileName, bool isFolder = false, bool isShortcut = false)
		{
			if (string.IsNullOrEmpty(fileName))
				return new FileNameParts(string.Empty, string.Empty, string.Empty);

			if (isFolder || isShortcut)
				return new FileNameParts(fileName, fileName, string.Empty);

			// Dotfiles (starts with a dot, e.g., ".gitignore", ".env")
			if (fileName.StartsWith('.'))
			{
				int secondDot = fileName.IndexOf('.', 1);
				if (secondDot < 0)
				{
					// Pure dotfile: whole string is the name, no editable extension
					return new FileNameParts(fileName, fileName, string.Empty);
				}
				// Dotfile with subsequent extension, e.g., ".gitignore.bak" -> continue below
			}

			// Trailing dot without extension, e.g., "arquivo."
			if (fileName.EndsWith('.'))
				return new FileNameParts(fileName, fileName, string.Empty);

			// Known compound extensions
			foreach (var compound in CompoundExtensions)
			{
				if (fileName.EndsWith(compound, StringComparison.OrdinalIgnoreCase) && fileName.Length > compound.Length)
				{
					string name = fileName.Substring(0, fileName.Length - compound.Length);
					string ext = fileName.Substring(fileName.Length - compound.Length);
					return new FileNameParts(fileName, name, ext);
				}
			}

			// Standard single extension
			int lastDot = fileName.LastIndexOf('.');
			if (lastDot > 0 && lastDot < fileName.Length - 1)
			{
				string name = fileName.Substring(0, lastDot);
				string ext = fileName.Substring(lastDot);
				return new FileNameParts(fileName, name, ext);
			}

			return new FileNameParts(fileName, fileName, string.Empty);
		}
	}
}
