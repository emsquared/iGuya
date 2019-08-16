/* *********************************************************************
*                   _  _____
*                  (_)/ ____|
*                   _| |  __ _   _ _   _  __ _
*                  | | | |_ | | | | | | |/ _` |
*                  | | |__| | |_| | |_| | (_| |
*                  |_|\_____|\__,_|\__, |\__,_|
*                                   __/ |
*                                  |___/
*
*               Copyright (c) 2019 Michael Morris
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions
* are met:
*
*  * Redistributions of source code must retain the above copyright
*    notice, this list of conditions and the following disclaimer.
*  * Redistributions in binary form must reproduce the above copyright
*    notice, this list of conditions and the following disclaimer in the
*    documentation and/or other materials provided with the distribution.
*
* THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
* ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
* FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
* DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
* OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
* HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
* LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
* OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
* SUCH DAMAGE.
*
*********************************************************************** */

import Cocoa
import iGuyaAPI
import os.log

final class BookWindow: NSWindowController, BookChaptersViewDelegate
{
	///
	/// Navigation actions which can be performed.
	///
	enum NavigationAction
	{
		///
		/// Navigate to list of chapters.
		///
		case chapterList

		///
		/// Navigate to the newest chapter of the book.
		///
		case newestChapter

		///
		/// Navigate to the oldest chapter of the book.
		///
		case oldestChapter

		///
		/// Navigate to the next chapter in the book.
		///
		/// This action is linear. Once it reaches the
		/// end of the book, it will not loop around.
		///
		case nextChapter

		///
		/// Navigation to the previous chapter in the book.
		///
		/// This action is linear. Once it reaches the
		/// beginning of the book, it will not loop around.
		///
		case previousChapter

		///
		/// Navigate to a specific chapter of the book.
		///
		/// An optional `page` parameter can be assigned
		/// to navigate to a specific page within the chapter.
		///
		/// Page numbers begin at **1**.
		///
		case chapter(_ chapter: Double, page: Int = 1)

		///
		/// Navigate to a specific page in the current chapter.
		///
		/// If the page does not exist in the chapter, then
		/// nothing happens.
		///
		/// Page numbers begin at **1**
		///
		case page(_ page: Int)

		///
		/// Navigate to next page.
		///
		/// This action is linear. Once it reaches the
		/// end of the book, it will not loop around.
		///
		case nextPage

		///
		/// Navigate to previous page.
		///
		/// This action is linear. Once it reaches the
		/// beginning of the book, it will not loop around.
		///
		case previousPage

		///
		/// Do not perform a navigation action.
		///
		case none
	}

	var representedObject: Any?
	{
		didSet {
			if (oldValue == nil) {
				performConstruction()
			}
		} // didSet
	}

	fileprivate(set) var book: Book!

	@IBOutlet private(set) var contentBorderView: NSView!
	@IBOutlet private(set) var cbvCurrentPageField: NSTextField!
	@IBOutlet private(set) var cbvGroupPopup: NSPopUpButton!

	@IBOutlet private(set) var toolbar: NSToolbar!
	@IBOutlet private(set) var tbLayoutButton: NSButton!
	@IBOutlet private(set) var tbScalingButton: NSButton!
	@IBOutlet private(set) var tbPageNavigator: NSSegmentedControl!
	@IBOutlet private(set) var tbGroupPopup: NSPopUpButton!
	@IBOutlet private(set) var tbChaptersPopup: NSPopUpButton!
	@IBOutlet private(set) var tbPagePopup: NSPopUpButton!
	@IBOutlet private(set) var tbVolumePopup: NSPopUpButton!

	fileprivate(set) var layoutDirection = Preferences.layoutDirection
	fileprivate(set) var scalingMode = Preferences.scalingMode

	typealias Release = Chapter.Release
	typealias Page = Chapter.Release.Page

	fileprivate(set) var selectedPage: Page?

	@inlinable
	var selectedRelease: Release?
	{
		return selectedPage?.release
	}

	@inlinable
	var selectedChapter: Chapter?
	{
		return selectedRelease?.chapter
	}

	@inlinable
	var selectedVolume: Volume?
	{
		return selectedChapter?.volume
	}

	override func windowDidLoad()
	{
		super.windowDidLoad()

		/* Attach content view bottom border to window. */
		attachContentBorderView()

		/* Set initial appearance of buttons. */
		updateLayoutDirectionButton()
		updateScalingButton()
	}

	///
	/// Actions to take once book object is set.
	///
	fileprivate func performConstruction()
	{
		if let book = representedObject as? Book {
			self.book = book
		} else {
			fatalError("Error: Book not assigned to represented object.")
		}

		/* The following functions require access to `book`. */
		/* They cannot be called until `representedObject` is set
		 during which time performConstruction() is called. */
		updateTitle()

		populateVolumeListPopup()
		populateChapterListPopup()
	}

	///
	/// Make window for the book key, order it front, and
	/// optionally navigate to a section of the book.
	///
	/// - Parameter navigationAction: Optional navigation action
	/// to perform on the book when presenting the window.
	/// For example: the action `.latestChapter` will instruct
	/// the window to navigate to the latest chapter of the book.
	///
	func presentWindow(navigationAction: BookWindow.NavigationAction = .none)
	{
		window?.makeKeyAndOrderFront(nil)

		performNavigation(navigationAction)
	}

	///
	/// Navigate to a section of the book.
	///
	/// Navigating to `.none` will do nothing.
	///
	/// This function will dismiss the chapter list view
	/// if it is on screen.
	///
	func performNavigation(_ navigationAction: BookWindow.NavigationAction)
	{
		#warning("TODO: Implement logic to dismiss chapter list sheet.")

		switch (navigationAction) {
			case .chapterList:
				presentChapterList()
			case .newestChapter:
				if let chapter = book.newestChapter {
					performNavigation(toChapter: chapter)
				}
			case .oldestChapter:
				if let chapter = book.oldestChapter {
					performNavigation(toChapter: chapter)
				}
			case .nextChapter:
				if let chapter = selectedChapter?.nextChapter(escapeVolume: true) {
					performNavigation(toChapter: chapter)
				}
			case .previousChapter:
				if let chapter = selectedChapter?.previousChapter(escapeVolume: true) {
					performNavigation(toChapter: chapter)
				}
			case .nextPage:
				if let page = selectedPage?.nextPage(escapeChapter: true) {
					performNavigation(toPage: page)
				}
			case .previousPage:
				if let page = selectedPage?.previousPage(escapeChapter: true) {
					performNavigation(toPage: page)
				}
			case .none:
				os_log("Tried to navigate window to '.none'.",
					   log: Logging.Subsystem.general, type: .info)
			default:
				break
		}
	}

	///
	/// Navigate to first page of the chapter by preferred group.
	///
	/// Navigates to first page by **any group** if there
	/// is **no preferred group** or they **do not have
	/// a release for the chapter**.
	///
	func performNavigation(toChapter chapter: Chapter)
	{
		guard let page = chapter.firstPage else {
			return
		}

		performNavigation(toPage: page)
	}

	///
	/// Navigate to a specific page in the book.
	///
	func performNavigation(toPage page: Page)
	{
		changePage(to: page)
	}

	///
	/// Change page in the window to `page`.
	///
	/// - Parameter page: Page to change the window to.
	///
	fileprivate func changePage(to page: Page)
	{
		/* Do not change to the same page. */
		if (selectedPage == page) {
			return
		}

		/* Figure out what changed to only update UI where needed. */
		/* A note on performance: */
		/* This function is called by user interactions, such as changing
		 selection in a popup, and internally by scrolling the reader.
		 For the former, this function still performs selection on the
		 popup the user interacted with. I could have optimized this
		 double selection away (1. from user 2. then by this function),
		 but that feels like an over-optimization when you consider
		 the fact the user wont be changing selection every second. */
		let differentRelease = (selectedPage?.release != page.release)
		let differentChapter = (selectedPage?.chapter != page.chapter)
		let differentVolume = (selectedPage?.volume != page.volume)

		/* Assign page to window. */
		selectedPage = page

		/* Volume changed */
		if (differentVolume) {
			/* Select volume in volume list popup. */
			updateVolumeListPopupSelection()
		}

		/* Chapter changed */
		if (differentChapter) {
			/* Select chapter in chapter list popup. */
			updateChapterListPopupSelection()
		}

		/* Release changed */
		if (differentRelease) {
			/* Populate group list popup. */
			populateGroupPopup()

			/* Select group in group list popup. */
			updateGroupPopupSelection()

			/* Populate page list popup with number of pages. */
			populatePageListPopup()
		}

		/* Select page in page list popup. */
		updatePageListPopupSelection()

		/* Enable/disable back and forward page buttons. */
		updatePageNavigatorState()

		/* Update "page of page" label. */
		updateCurrentPageField()
	}

	///
	/// Reference to visible chapter list sheet.
	///
	fileprivate var chapterListView: BookChaptersView?
	{
		guard let controller = window?.attachedSheet?.contentViewController as? BookChaptersView else {
			return nil
		}

		return controller
	}

	///
	/// Present chapter list sheet.
	///
	func presentChapterList()
	{
		if (chapterListView != nil) {
			return
		}

		guard let controller = storyboard?.instantiateController(withIdentifier: "BookChapters") as? BookChaptersView else {
			fatalError("Error: Storyboard does not contain a 'BookChapters' controller.")
		}

		controller.delegate = self

		contentViewController?.presentAsSheet(controller)
	}

	///
	/// Dismiss chapter list sheet.
	///
	func dismissChapterList()
	{
		guard let chapterListView = chapterListView else {
			return
		}

		contentViewController?.dismiss(chapterListView)
	}

	///
	/// Delegate call when a chapter is selected in the chapter list sheet.
	///
	func bookChaptersView(_ bookChaptersView: BookChaptersView, selectedChapter chapter: Chapter)
	{
		dismissChapterList()

		performNavigation(toChapter: chapter)
	}

	///
	/// Change layout direction.
	///
	/// Changing the layout direction using this function
	/// will only change it for the book. Not all books.
	///
	func changeLayoutDirection(to layoutDirection: Preferences.LayoutDirection)
	{
		self.layoutDirection = layoutDirection
	}

	///
	/// Change scaling mode.
	///
	/// Changing the scaling mode using this function
	/// will only change it for the book. Not all books.
	///
	func changeScalingMode(to scalingMode: Preferences.ScalingMode)
	{
		self.scalingMode = scalingMode
	}
}
