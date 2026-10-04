// Copyright (c) Files Community
// Licensed under the MIT License.

namespace Files.App.Actions
{
	[GeneratedRichCommand]
	internal sealed partial class ToggleDetailsPaneAction : ObservableObject, IAction
	{
		private readonly InfoPaneViewModel infoPaneViewModel = Ioc.Default.GetRequiredService<InfoPaneViewModel>();
		private readonly IInfoPaneSettingsService infoPaneSettingsService = Ioc.Default.GetRequiredService<IInfoPaneSettingsService>();

		public string Label
			=> Strings.ToggleDetailsPane.GetLocalizedResource();

		public string Description
			=> Strings.ToggleDetailsPaneDescription.GetLocalizedResource();

		public ActionCategory Category
			=> ActionCategory.Show;

		public RichGlyph Glyph
			=> new(themedIconStyle: "App.ThemedIcons.PanelRight");

		public HotKey HotKey
			=> new(Keys.P, KeyModifiers.AltShift);

		public bool IsAccessibleGlobally
			=> true;

		public bool IsExecutable
			=> true;

		public ToggleDetailsPaneAction()
		{
		}

		public Task ExecuteAsync(object? parameter = null)
		{
			if (parameter is "Tab")
			{
				infoPaneSettingsService.SelectedTab = InfoPaneTabs.Details;
				return Task.CompletedTask;
			}

			var (isPaneOpen, selectedTab) = InfoPaneToggleHelper.Toggle(
				infoPaneViewModel.IsEnabled,
				infoPaneSettingsService.SelectedTab,
				InfoPaneTabs.Details);

			infoPaneSettingsService.SelectedTab = selectedTab;
			infoPaneViewModel.IsEnabled = isPaneOpen;

			return Task.CompletedTask;
		}
	}
}
