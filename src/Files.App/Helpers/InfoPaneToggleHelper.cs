// Copyright (c) Files Community
// Licensed under the MIT License.

using System.Collections.Generic;

namespace Files.App.Helpers
{
	public readonly struct PaneToggleResult<T>
	{
		public bool IsPaneOpen { get; }
		public T SelectedTab { get; }

		public PaneToggleResult(bool isPaneOpen, T selectedTab)
		{
			IsPaneOpen = isPaneOpen;
			SelectedTab = selectedTab;
		}

		public void Deconstruct(out bool isPaneOpen, out T selectedTab)
		{
			isPaneOpen = IsPaneOpen;
			selectedTab = SelectedTab;
		}
	}

	public static class InfoPaneToggleHelper
	{
		/// <summary>
		/// Computes the new state for the info pane given its current state and the requested tab.
		/// Implements scenarios AC-1 through AC-6.
		/// </summary>
		/// <typeparam name="T">The type representing tabs.</typeparam>
		/// <param name="isPaneOpen">Whether the pane is currently open.</param>
		/// <param name="currentTab">The currently selected tab.</param>
		/// <param name="requestedTab">The tab associated with the invoked toggle action.</param>
		/// <returns>A <see cref="PaneToggleResult{T}"/> containing the new pane open status and selected tab.</returns>
		public static PaneToggleResult<T> Toggle<T>(bool isPaneOpen, T currentTab, T requestedTab)
		{
			if (!isPaneOpen)
			{
				// AC-1, AC-2: painel fechado -> abre na aba pedida
				return new PaneToggleResult<T>(true, requestedTab);
			}

			if (EqualityComparer<T>.Default.Equals(currentTab, requestedTab))
			{
				// AC-4, AC-6: painel aberto na mesma aba -> fecha
				return new PaneToggleResult<T>(false, currentTab);
			}

			// AC-3, AC-5: painel aberto em outra aba -> muda para a aba pedida e continua aberto
			return new PaneToggleResult<T>(true, requestedTab);
		}
	}
}
