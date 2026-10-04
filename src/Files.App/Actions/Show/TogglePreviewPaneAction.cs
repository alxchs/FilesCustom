// Copyright (c) Files Community
// Licensed under the MIT License.

namespace Files.App.Actions
{
	[GeneratedRichCommand]
	internal sealed partial class TogglePreviewPaneAction : ObservableObject, IAction
	{
		private readonly InfoPaneViewModel infoPaneViewModel = Ioc.Default.GetRequiredService<InfoPaneViewModel>();
		private readonly IInfoPaneSettingsService infoPaneSettingsService = Ioc.Default.GetRequiredService<IInfoPaneSettingsService>();

		public string Label
			=> Strings.TogglePreviewPane.GetLocalizedResource();

		public string Description
			=> Strings.TogglePreviewPaneDescription.GetLocalizedResource();

		public ActionCategory Category
			=> ActionCategory.Show;

		public RichGlyph Glyph
			=> new(themedIconStyle: "App.ThemedIcons.PanelRight");

		public HotKey HotKey
			=> new(Keys.P, KeyModifiers.Alt);

		public bool IsAccessibleGlobally
			=> true;

		public bool IsExecutable
			=> true;

		public TogglePreviewPaneAction()
		{
		}

		public Task ExecuteAsync(object? parameter = null)
		{
			if (parameter is "Tab")
			{
				infoPaneSettingsService.SelectedTab = InfoPaneTabs.Preview;
				return Task.CompletedTask;
			}

			var (isPaneOpen, selectedTab) = InfoPaneToggleHelper.Toggle(
				infoPaneViewModel.IsEnabled,
				infoPaneSettingsService.SelectedTab,
				InfoPaneTabs.Preview);

			infoPaneSettingsService.SelectedTab = selectedTab;
			infoPaneViewModel.IsEnabled = isPaneOpen;

			return Task.CompletedTask;
		}
	}
}
