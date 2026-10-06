// Copyright (c) Files Community
// Licensed under the MIT License.

using Files.App.Data.Commands;
using Microsoft.UI.Xaml.Controls;

namespace Files.App.UserControls.Menus
{
	public sealed partial class ClassicMenuBar : UserControl
	{
		public ICommandManager Commands { get; } = Ioc.Default.GetRequiredService<ICommandManager>();

		public ClassicMenuBar()
		{
			InitializeComponent();
		}
	}
}
