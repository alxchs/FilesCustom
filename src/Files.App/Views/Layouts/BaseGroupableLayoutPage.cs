// Copyright (c) Files Community
// Licensed under the MIT License.

using CommunityToolkit.WinUI;
using Files.App.Helpers;
using Files.App.ViewModels.Layouts;
using Microsoft.UI.Input;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Controls.Primitives;
using Microsoft.UI.Xaml.Input;
using System.Runtime.InteropServices;
using Windows.Storage;
using Windows.System;
using Windows.UI.Core;
using Windows.Win32;
using WinRT;

namespace Files.App.Views.Layouts
{
	/// <summary>
	/// Represents layout page that can be grouped by.
	/// </summary>
	public abstract class BaseGroupableLayoutPage : BaseLayoutPage
	{
		// Constants

		private const int KEY_DOWN_MASK = 0x8000;

		// Fields

		protected int NextRenameIndex = 0;
		protected TextBox? renameTextBox;
		private bool _pointerPressedInExtension;
		private PointerEventHandler? renameTextBoxPointerPressedHandler;

		// Properties

		protected FileNameParts ActiveRenameParts { get; set; } = new FileNameParts(string.Empty, string.Empty, string.Empty);
		protected bool IsExtensionUnlocked { get; set; }
		protected bool IsExtensionDeliberatelyModified { get; set; }

		protected abstract ListViewBase ListViewBase { get; }
		protected abstract SemanticZoom RootZoom { get; }

		protected override ItemsControl ItemsControl => ListViewBase;

		// Constructor

		public BaseGroupableLayoutPage() : base()
		{
		}

		// Abstract methods

		protected abstract void ItemManipulationModel_AddSelectedItemInvoked(object? sender, ListedItem e);
		protected abstract void ItemManipulationModel_RemoveSelectedItemInvoked(object? sender, ListedItem e);
		protected abstract void ItemManipulationModel_FocusSelectedItemsInvoked(object? sender, EventArgs e);
		protected abstract void ItemManipulationModel_ScrollIntoViewInvoked(object? sender, ListedItem e);
		protected abstract void ItemManipulationModel_ScrollToTopInvoked(object? sender, EventArgs e);
		protected abstract void FileList_PreviewKeyDown(object sender, KeyRoutedEventArgs e);
		protected abstract void EndRename(TextBox textBox);

		// Overridden methods

		protected override void InitializeCommandsViewModel()
		{
			var parentShellPage = ParentShellPageInstance
				?? throw new InvalidOperationException("The layout page must be associated with a shell page before its commands are initialized.");

			CommandsViewModel = new BaseLayoutViewModel(parentShellPage, ItemManipulationModel);
		}

		protected override void HookEvents()
		{
			UnhookEvents();

			ItemManipulationModel.FocusFileListInvoked += ItemManipulationModel_FocusFileListInvoked;
			ItemManipulationModel.SelectAllItemsInvoked += ItemManipulationModel_SelectAllItemsInvoked;
			ItemManipulationModel.ClearSelectionInvoked += ItemManipulationModel_ClearSelectionInvoked;
			ItemManipulationModel.InvertSelectionInvoked += ItemManipulationModel_InvertSelectionInvoked;
			ItemManipulationModel.AddSelectedItemInvoked += ItemManipulationModel_AddSelectedItemInvoked;
			ItemManipulationModel.RemoveSelectedItemInvoked += ItemManipulationModel_RemoveSelectedItemInvoked;
			ItemManipulationModel.FocusSelectedItemsInvoked += ItemManipulationModel_FocusSelectedItemsInvoked;
			ItemManipulationModel.StartRenameItemInvoked += ItemManipulationModel_StartRenameItemInvoked;
			ItemManipulationModel.ScrollIntoViewInvoked += ItemManipulationModel_ScrollIntoViewInvoked;
			ItemManipulationModel.ScrollToTopInvoked += ItemManipulationModel_ScrollToTopInvoked;
			ItemManipulationModel.RefreshItemThumbnailInvoked += ItemManipulationModel_RefreshItemThumbnail;
			ItemManipulationModel.RefreshItemsThumbnailInvoked += ItemManipulationModel_RefreshItemsThumbnail;
		}

		protected override void UnhookEvents()
		{
			if (ItemManipulationModel is null)
				return;

			ItemManipulationModel.FocusFileListInvoked -= ItemManipulationModel_FocusFileListInvoked;
			ItemManipulationModel.SelectAllItemsInvoked -= ItemManipulationModel_SelectAllItemsInvoked;
			ItemManipulationModel.ClearSelectionInvoked -= ItemManipulationModel_ClearSelectionInvoked;
			ItemManipulationModel.InvertSelectionInvoked -= ItemManipulationModel_InvertSelectionInvoked;
			ItemManipulationModel.AddSelectedItemInvoked -= ItemManipulationModel_AddSelectedItemInvoked;
			ItemManipulationModel.RemoveSelectedItemInvoked -= ItemManipulationModel_RemoveSelectedItemInvoked;
			ItemManipulationModel.FocusSelectedItemsInvoked -= ItemManipulationModel_FocusSelectedItemsInvoked;
			ItemManipulationModel.StartRenameItemInvoked -= ItemManipulationModel_StartRenameItemInvoked;
			ItemManipulationModel.ScrollIntoViewInvoked -= ItemManipulationModel_ScrollIntoViewInvoked;
			ItemManipulationModel.ScrollToTopInvoked -= ItemManipulationModel_ScrollToTopInvoked;
			ItemManipulationModel.RefreshItemThumbnailInvoked -= ItemManipulationModel_RefreshItemThumbnail;
			ItemManipulationModel.RefreshItemsThumbnailInvoked -= ItemManipulationModel_RefreshItemsThumbnail;
		}

		[DynamicWindowsRuntimeCast(typeof(FrameworkElement))]
		[DynamicWindowsRuntimeCast(typeof(Button))]
		[DynamicWindowsRuntimeCast(typeof(TextBox))]
		[DynamicWindowsRuntimeCast(typeof(PasswordBox))]
		protected override void Page_CharacterReceived(UIElement sender, CharacterReceivedRoutedEventArgs args)
		{
			if (ParentShellPageInstance is null ||
				ParentShellPageInstance.CurrentPageType != this.GetType() ||
				IsRenamingItem)
				return;

			// Don't block the various uses of enter key (key 13)
			var focusedElement = (FrameworkElement)FocusManager.GetFocusedElement(XamlRoot);
			var isHeaderFocused = DependencyObjectHelpers.FindParent<DataGridHeader>(focusedElement) is not null;
			if (InputKeyboardSource.GetKeyStateForCurrentThread(VirtualKey.Enter) == CoreVirtualKeyStates.Down ||
				(focusedElement is Button && !isHeaderFocused) || // Allow jumpstring when header is focused
				focusedElement is TextBox ||
				focusedElement is PasswordBox ||
				DependencyObjectHelpers.FindParent<ContentDialog>(focusedElement) is not null)
				return;

			base.Page_CharacterReceived(sender, args);
		}

		// Virtual methods

		protected virtual async void ItemManipulationModel_RefreshItemsThumbnail(object? sender, EventArgs e)
		{
			await ReloadSelectedItemsIconAsync();
		}

		protected virtual async void ItemManipulationModel_RefreshItemThumbnail(object? sender, EventArgs args)
		{
			await ReloadSelectedItemIconAsync();
		}

		protected virtual async Task ReloadSelectedItemIconAsync()
		{
			var parentShellPage = ParentShellPageInstance;
			var selectedItem = parentShellPage?.SlimContentPage?.SelectedItem;
			if (selectedItem is null)
				return;
			var shellViewModel = parentShellPage.GetRequiredShellViewModel();

			shellViewModel.CancelExtendedPropertiesLoading();
			selectedItem.ItemPropertiesInitialized = false;

			await shellViewModel.LoadExtendedItemPropertiesAsync(selectedItem);

			if (shellViewModel.EnabledGitProperties is not GitProperties.None &&
				selectedItem is IGitItem gitItem)
			{
				await shellViewModel.LoadGitPropertiesAsync(gitItem);
			}
		}

		protected virtual async Task ReloadSelectedItemsIconAsync()
		{
			var parentShellPage = ParentShellPageInstance;
			var selectedItems = parentShellPage?.SlimContentPage?.SelectedItems;
			if (selectedItems is null)
				return;
			var shellViewModel = parentShellPage.GetRequiredShellViewModel();

			shellViewModel.CancelExtendedPropertiesLoading();

			foreach (var selectedItem in selectedItems)
			{
				selectedItem.ItemPropertiesInitialized = false;
				await shellViewModel.LoadExtendedItemPropertiesAsync(selectedItem);
			}

			if (shellViewModel.EnabledGitProperties is not GitProperties.None)
			{
				await Task.WhenAll(selectedItems.Select(item =>
				{
					if (item is IGitItem gitItem)
						return shellViewModel.LoadGitPropertiesAsync(gitItem);

					return Task.CompletedTask;
				}));
			}
		}

		[DynamicWindowsRuntimeCast(typeof(FrameworkElement))]
		protected virtual void ItemManipulationModel_FocusFileListInvoked(object? sender, EventArgs e)
		{
			try
			{
				if (App.AppModel.IsMainWindowClosed)
					return;

				var focusedElement = (FrameworkElement)FocusManager.GetFocusedElement(MainWindow.Instance.Content.XamlRoot);
				var isFileListFocused = DependencyObjectHelpers.FindParent<ListViewBase>(focusedElement) == ItemsControl;
				if (!isFileListFocused)
					ListViewBase.Focus(FocusState.Programmatic);
			}
			catch
			{
				// Handle exception in case the window is closed during the operation
			}
		}

		protected virtual void ItemManipulationModel_SelectAllItemsInvoked(object? sender, EventArgs e)
		{
			ListViewBase.SelectAll();
		}

		protected virtual void ItemManipulationModel_ClearSelectionInvoked(object? sender, EventArgs e)
		{
			ListViewBase.SelectedItems.Clear();
		}

		protected virtual void ItemManipulationModel_InvertSelectionInvoked(object? sender, EventArgs e)
		{
			if (SelectedItems.Count < GetAllItems().Count() / 2)
			{
				var oldSelectedItems = SelectedItems.ToList();
				ItemManipulationModel.SelectAllItems();
				ItemManipulationModel.RemoveSelectedItems(oldSelectedItems);
				return;
			}

			List<ListedItem> newSelectedItems = GetAllItems()
				.Cast<ListedItem>()
				.Except(SelectedItems)
				.ToList();

			ItemManipulationModel.SetSelectedItems(newSelectedItems);
		}

		protected virtual void ItemManipulationModel_StartRenameItemInvoked(object? sender, EventArgs e)
		{
			StartRenameItem();
		}

		protected override void ZoomIn()
		{
			RootZoom.IsZoomedInViewActive = true;
		}

		protected virtual void FileList_SelectionChanged(object sender, SelectionChangedEventArgs? e)
		{

			if (e is null && SelectedItems?.Count == 0)
				return;

			if (e is not null && e.AddedItems.Count == 0 && e.RemovedItems.Count == 0)
				return;

			var selectedItems = ListViewBase.SelectedItems.Cast<ListedItem>().Where(x => x is not null).ToList();

			if (SelectedItems is not null && SelectedItems.SequenceEqual(selectedItems))
				return;

			SelectedItems = selectedItems;

			if (e is null)
				return;

			OnSelectionChanged(e);
		}

		protected abstract void OnSelectionChanged(SelectionChangedEventArgs e);

		protected virtual void SelectionRectangle_SelectionStarted(object? sender, EventArgs e)
		{
			isDraggingSelectionRectangle = true;
		}

		protected virtual void SelectionRectangle_SelectionEnded(object? sender, EventArgs e)
		{
			isDraggingSelectionRectangle = false;
			FlushSelectionToToolbar();
			ListViewBase.Focus(FocusState.Programmatic);
		}

		protected static bool ShouldShowExtensionInRename(ListedItem item) =>
			(!item.IsFolder || item.IsArchive) && !item.IsShortcut && item is not AlternateStreamItem;

		[DynamicWindowsRuntimeCast(typeof(ListViewItem))]
		[DynamicWindowsRuntimeCast(typeof(TextBlock))]
		[DynamicWindowsRuntimeCast(typeof(TextBox))]
		protected virtual void StartRenameItem(string itemNameTextBox)
		{
			RenamingItem = SelectedItem;
			var renamingItem = RenamingItem;
			if (renamingItem is null)
				return;

			ListViewItem? listViewItem = ListViewBase.ContainerFromItem(renamingItem) as ListViewItem;
			if (listViewItem is null)
				return;

			TextBlock? textBlock = listViewItem.FindDescendant("ItemName") as TextBlock;
			TextBox? textBox = listViewItem.FindDescendant(itemNameTextBox) as TextBox;
			if (textBlock is null || textBox is null)
				throw new InvalidOperationException("The rename controls are not available for the selected item.");

			string editText = ShouldShowExtensionInRename(renamingItem) ? renamingItem.ItemNameRaw! : textBlock.Text;
			textBox.Text = editText;
			OldItemName = editText;
			textBlock.Visibility = Visibility.Collapsed;
			textBox.Visibility = Visibility.Visible;

			var parentGrid = textBox.FindParent<Grid>();
			if (parentGrid is null)
			{
				textBlock.Visibility = Visibility.Visible;
				textBox.Visibility = Visibility.Collapsed;
				return;
			}

			Grid.SetColumnSpan(parentGrid, 8);

			textBox.Focus(FocusState.Pointer);
			textBox.LostFocus += RenameTextBox_LostFocus;
			textBox.KeyDown += RenameTextBox_KeyDown;

			renameTextBoxPointerPressedHandler = new PointerEventHandler(RenameTextBox_PointerPressed);
			textBox.AddHandler(UIElement.PointerPressedEvent, renameTextBoxPointerPressedHandler, true);

			InitializeRenameSelection(textBox, editText, renamingItem);
			IsRenamingItem = true;

			renameTextBox = textBox;
			if (guardRenameFromDoubleClick)
				DeferRenameTextBoxHitTesting(textBox);
		}

		protected void InitializeRenameSelection(TextBox textBox, string editText, ListedItem item)
		{
			bool showExtension = ShouldShowExtensionInRename(item);
			ActiveRenameParts = showExtension
				? FileNameExtensionHelper.Split(editText, isFolder: item.PrimaryItemAttribute == StorageItemTypes.Folder, isShortcut: item.IsShortcut)
				: new FileNameParts(editText, editText, string.Empty);

			IsExtensionUnlocked = !ActiveRenameParts.HasExtension;
			IsExtensionDeliberatelyModified = false;

			int selectLength = ActiveRenameParts.HasExtension
				? ActiveRenameParts.NamePart.Length
				: editText.Length;

			textBox.Select(0, selectLength);
			textBox.SelectionChanged += RenameTextBox_SelectionChanged;
		}

		[DynamicWindowsRuntimeCast(typeof(TextBox))]
		protected virtual void RenameTextBox_SelectionChanged(object sender, RoutedEventArgs e)
		{
			if (sender is not TextBox textBox || !IsRenamingItem)
				return;

			if (!IsExtensionUnlocked && ActiveRenameParts.HasExtension)
			{
				int extLen = ActiveRenameParts.ExtensionPart.Length;
				int nameLen = Math.Max(0, textBox.Text.Length - extLen);

				if (_pointerPressedInExtension)
				{
					_pointerPressedInExtension = false;
					IsExtensionUnlocked = true;
					IsExtensionDeliberatelyModified = true;
					return;
				}

				if (textBox.SelectionStart > nameLen)
				{
					textBox.Select(nameLen, 0);
				}
				else if (textBox.SelectionStart < nameLen && (textBox.SelectionStart + textBox.SelectionLength) > nameLen)
				{
					textBox.Select(textBox.SelectionStart, nameLen - textBox.SelectionStart);
				}
			}
		}

		[DynamicWindowsRuntimeCast(typeof(TextBox))]
		private void RenameTextBox_PointerPressed(object sender, PointerRoutedEventArgs e)
		{
			if (sender is not TextBox textBox || !IsRenamingItem || IsExtensionUnlocked || !ActiveRenameParts.HasExtension)
				return;

			var pointerPt = e.GetCurrentPoint(textBox);
			if (!pointerPt.Properties.IsLeftButtonPressed)
				return;

			var x = pointerPt.Position.X;
			var nameWidth = MeasureTextWidth(textBox, ActiveRenameParts.NamePart);
			var fullWidth = MeasureTextWidth(textBox, textBox.Text);
			var offset = textBox.Padding.Left + textBox.BorderThickness.Left;
			var extStartX = offset + nameWidth;
			var extEndX = offset + fullWidth;

			if (x >= extStartX && x <= extEndX + 4)
			{
				_pointerPressedInExtension = true;
			}
			else
			{
				_pointerPressedInExtension = false;
			}
		}

		private static double MeasureTextWidth(TextBox textBox, string text)
		{
			if (string.IsNullOrEmpty(text))
				return 0;

			var tb = new TextBlock
			{
				Text = text,
				FontSize = textBox.FontSize,
				FontFamily = textBox.FontFamily,
				FontStyle = textBox.FontStyle,
				FontWeight = textBox.FontWeight,
			};
			tb.Measure(new Windows.Foundation.Size(double.PositiveInfinity, double.PositiveInfinity));
			return tb.DesiredSize.Width;
		}

		protected void ResetRenameState(TextBox? textBox)
		{
			if (textBox is not null)
			{
				textBox.LostFocus -= RenameTextBox_LostFocus;
				textBox.KeyDown -= RenameTextBox_KeyDown;
				textBox.SelectionChanged -= RenameTextBox_SelectionChanged;

				if (renameTextBoxPointerPressedHandler is not null)
				{
					textBox.RemoveHandler(UIElement.PointerPressedEvent, renameTextBoxPointerPressedHandler);
					renameTextBoxPointerPressedHandler = null;
				}
			}

			_pointerPressedInExtension = false;
			IsExtensionUnlocked = false;
			IsExtensionDeliberatelyModified = false;
			ActiveRenameParts = new FileNameParts(string.Empty, string.Empty, string.Empty);
		}

		protected override async Task ValidateItemNameInputTextAsync(TextBox textBox, TextBoxBeforeTextChangingEventArgs args, Action<bool> showError)
		{
			if (!IsExtensionUnlocked && ActiveRenameParts.HasExtension)
			{
				if (args.NewText.Length < ActiveRenameParts.ExtensionPart.Length ||
					!args.NewText.EndsWith(ActiveRenameParts.ExtensionPart, StringComparison.Ordinal))
				{
					args.Cancel = true;
					return;
				}
			}

			await base.ValidateItemNameInputTextAsync(textBox, args, showError);
		}

		protected async void DeferRenameTextBoxHitTesting(TextBox textBox)
		{
			// Lets a double click pass through to the list so it opens the item instead of landing in the text box
			textBox.IsHitTestVisible = false;
			await Task.Delay(RenameDoubleClickGuardDuration);
			textBox.IsHitTestVisible = true;
		}

		protected void CancelRenameOnDoubleClick(ListedItem? item)
		{
			if (item is null || item != RenamingItem || renameTextBox is null || !IsRenameDoubleClickGuardActive)
				return;

			renameTextBox.LostFocus -= RenameTextBox_LostFocus;
			renameTextBox.Text = OldItemName;
			EndRename(renameTextBox);
		}

		protected virtual async Task CommitRenameAsync(TextBox textBox)
		{
			var renamingItem = RenamingItem;
			var parentShellPage = ParentShellPageInstance;
			bool suppressExtensionDialog = IsExtensionDeliberatelyModified;
			EndRename(textBox);
			if (renamingItem is null || parentShellPage is null)
				throw new InvalidOperationException("The rename operation does not have an item and shell page.");

			string newItemName = textBox.Text.Trim().TrimEnd('.');

			await UIFilesystemHelpers.RenameFileItemAsync(
				renamingItem,
				newItemName,
				parentShellPage,
				showExtensionDialog: !suppressExtensionDialog,
				nameIsComplete: ShouldShowExtensionInRename(renamingItem));
		}

		[DynamicWindowsRuntimeCast(typeof(AppBarButton))]
		[DynamicWindowsRuntimeCast(typeof(Popup))]
		[DynamicWindowsRuntimeCast(typeof(TextBox))]
		protected virtual async void RenameTextBox_LostFocus(object sender, RoutedEventArgs e)
		{
			try
			{
				// This check allows the user to use the text box context menu without ending the rename
				if (!(FocusManager.GetFocusedElement(MainWindow.Instance.Content.XamlRoot) is AppBarButton or Popup))
				{
					TextBox textBox = (TextBox)e.OriginalSource;
					await CommitRenameAsync(textBox);
				}
			}
			catch (COMException)
			{

			}
		}

		// Methods

		[DynamicWindowsRuntimeCast(typeof(TextBox))]
		protected async void RenameTextBox_KeyDown(object sender, KeyRoutedEventArgs e)
		{
			var textBox = (TextBox)sender;
			var isShiftPressed = (PInvoke.GetKeyState((int)VirtualKey.Shift) & KEY_DOWN_MASK) != 0;
			var isCtrlPressed = (PInvoke.GetKeyState((int)VirtualKey.Control) & KEY_DOWN_MASK) != 0;

			switch (e.Key)
			{
				case VirtualKey.Escape:
					textBox.LostFocus -= RenameTextBox_LostFocus;
					textBox.Text = OldItemName;
					EndRename(textBox);
					e.Handled = true;
					break;
				case VirtualKey.Enter:
					textBox.LostFocus -= RenameTextBox_LostFocus;
					await CommitRenameAsync(textBox);
					e.Handled = true;
					break;
				case VirtualKey.A:
					if (isCtrlPressed && !IsExtensionUnlocked && ActiveRenameParts.HasExtension)
					{
						int extLen = ActiveRenameParts.ExtensionPart.Length;
						int nameLen = Math.Max(0, textBox.Text.Length - extLen);
						textBox.Select(0, nameLen);
						e.Handled = true;
					}
					break;
				case VirtualKey.Delete:
					if (!IsExtensionUnlocked && ActiveRenameParts.HasExtension)
					{
						int extLen = ActiveRenameParts.ExtensionPart.Length;
						int nameLen = Math.Max(0, textBox.Text.Length - extLen);
						if (textBox.SelectionStart == nameLen && textBox.SelectionLength == 0)
						{
							e.Handled = true;
						}
					}
					break;
				case VirtualKey.Decimal:
				case (VirtualKey)190: // OEM Period
					{
						if (IsExtensionUnlocked && ActiveRenameParts.HasExtension)
						{
							int extLen = ActiveRenameParts.ExtensionPart.Length;
							int extStart = Math.Max(0, textBox.Text.Length - extLen);
							if (textBox.SelectionStart == extStart + 1 && textBox.SelectionLength == extLen - 1)
							{
								textBox.Select(extStart, extLen);
							}
						}
						break;
					}
				case VirtualKey.Home:
					textBox.SelectionStart = 0;
					textBox.SelectionLength = 0;
					e.Handled = true;
					break;
				case VirtualKey.End:
					if (!IsExtensionUnlocked && ActiveRenameParts.HasExtension)
					{
						int extLen = ActiveRenameParts.ExtensionPart.Length;
						int nameLen = Math.Max(0, textBox.Text.Length - extLen);
						if (isShiftPressed)
						{
							int start = textBox.SelectionStart;
							textBox.Select(start, Math.Max(0, nameLen - start));
						}
						else
						{
							textBox.Select(nameLen, 0);
						}
						e.Handled = true;
					}
					break;
				case VirtualKey.Up:
					if (!isShiftPressed)
						textBox.SelectionStart = 0;
					e.Handled = true;
					break;
				case VirtualKey.Down:
					if (!isShiftPressed)
					{
						if (!IsExtensionUnlocked && ActiveRenameParts.HasExtension)
						{
							int extLen = ActiveRenameParts.ExtensionPart.Length;
							int nameLen = Math.Max(0, textBox.Text.Length - extLen);
							textBox.Select(nameLen, 0);
						}
						else
						{
							textBox.SelectionStart = textBox.Text.Length;
						}
					}
					e.Handled = true;
					break;
				case VirtualKey.Left:
					e.Handled = textBox.SelectionStart == 0;
					break;
				case VirtualKey.Right:
					if (!IsExtensionUnlocked && ActiveRenameParts.HasExtension)
					{
						int extLen = ActiveRenameParts.ExtensionPart.Length;
						int nameLen = Math.Max(0, textBox.Text.Length - extLen);
						if (textBox.SelectionStart >= nameLen)
						{
							e.Handled = true;
							break;
						}
					}
					e.Handled = (textBox.SelectionStart + textBox.SelectionLength) == textBox.Text.Length;
					break;
				case VirtualKey.Tab:
					{
						if (!ActiveRenameParts.HasExtension)
						{
							e.Handled = true;
							break;
						}

						var currentParts = FileNameExtensionHelper.Split(textBox.Text);
						if (currentParts.HasExtension)
							ActiveRenameParts = currentParts;

						int extLength = ActiveRenameParts.ExtensionPart.Length;
						int extStart = Math.Max(0, textBox.Text.Length - extLength);
						int nameLength = extStart;

						bool currentlyOnExtension = textBox.SelectionStart >= extStart;

						if (isShiftPressed || currentlyOnExtension)
						{
							IsExtensionUnlocked = false;
							textBox.Select(0, nameLength);
						}
						else
						{
							IsExtensionUnlocked = true;
							IsExtensionDeliberatelyModified = true;
							if (ActiveRenameParts.ExtensionPart.StartsWith('.') && extLength > 1)
							{
								textBox.Select(extStart + 1, extLength - 1);
							}
							else
							{
								textBox.Select(extStart, extLength);
							}
						}
						e.Handled = true;
						break;
					}
			}
		}

		protected bool TryStartRenameNextItem(ListedItem item)
		{
			var nextItemIndex = ListViewBase.Items.IndexOf(item) + NextRenameIndex;
			NextRenameIndex = 0;

			if (nextItemIndex >= 0 &&
				nextItemIndex < ListViewBase.Items.Count)
			{
				ListViewBase.SelectedIndex = nextItemIndex;
				StartRenameItem();

				return true;
			}

			return false;
		}

		protected void SelectionCheckbox_DoubleTapped(object sender, DoubleTappedRoutedEventArgs e)
		{
			e.Handled = true;
		}

		// Disposer

		public override void Dispose()
		{
			base.Dispose();
			UnhookEvents();

			if (ListViewBase.ItemsPanelRoot is Panel itemsPanel)
			{
				foreach (var container in itemsPanel.Children.OfType<SelectorItem>())
				{
					UninitializeDrag(container);
					ToolTipService.SetToolTip(container, null);
					container.DataContext = null;
					container.Content = null;
				}
			}

			ListViewBase.ItemsSource = null;
			CollectionViewSource = new();
			CommandsViewModel?.Dispose();
		}
	}
}
