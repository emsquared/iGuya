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

class BookWindow: NSWindowController
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
		/// Navigate to a specific chapter of the book.
		///
		/// An optional `page` parameter can be assigned
		/// to navigate to a specific page within the chapter.
		/// Page numbers begin at **1**.
		///
		case chapter(_ chapter: Double, page: Int = 1)

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

	@IBOutlet private var contentBorderView: NSView!
	@IBOutlet private var cbvCurrentPageField: NSTextField!
	@IBOutlet private var cbvGroupPopup: NSPopUpButton!

	@IBOutlet private var toolbar: NSToolbar!
	@IBOutlet private var tbLayoutButton: NSButton!
	@IBOutlet private var tbPreloadButton: NSButton!
	@IBOutlet private var tbScalingButton: NSButton!
	@IBOutlet private var tbPageNavigator: NSSegmentedControl!
	@IBOutlet private var tbGroupPopup: NSPopUpButton!
	@IBOutlet private var tbChaptersPopup: NSPopUpButton!
	@IBOutlet private var tbPagePopup: NSPopUpButton!
	@IBOutlet private var tbVolumePopup: NSPopUpButton!

	fileprivate var chapterListView: BookChaptersView?

	var selectedPage: Chapter.Release.Page?

	@inlinable
	var selectedRelease: Chapter.Release?
	{
		return selectedPage?.release
	}

	@inlinable
	var selectedChapter: Chapter?
	{
		return selectedRelease?.chapter
	}

	override func windowDidLoad()
	{
		super.windowDidLoad()

		attachContentBorderView()
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

		updateTitle()
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
//		if case .chapterList = navigationAction {
//			dismissChapterList()
//		}

		switch (navigationAction) {
			case .chapterList:
				presentChapterList()
			case .none:
				os_log("Tried to navigate window to '.none'.",
					   log: Logging.Subsystem.general, type: .fault)
			default:
				break
		}
	}

	///
	/// Present chapter list sheet.
	///
	func presentChapterList()
	{
		os_log("Preparing to present chapter list sheet.",
			   log: Logging.Subsystem.general, type: .debug)

		if (chapterListView != nil) {
			os_log("Cancelled chapter list sheet because one already is visible.",
				   log: Logging.Subsystem.general, type: .fault)

			return
		}

		guard let controller = storyboard?.instantiateController(withIdentifier: "BookChapters") as? BookChaptersView else {
			fatalError("Error: Storyboard does not contain a 'BookChapters' controller.")
		}

		contentViewController?.presentAsSheet(controller)

		self.chapterListView = controller
	}

	///
	/// Dismiss chapter list sheet.
	///
	func dismissChapterList()
	{
		guard let chapterListView = chapterListView else {
			return
		}

		os_log("Dismissing chapter list sheet.",
			   log: Logging.Subsystem.general, type: .debug)

		contentViewController?.dismiss(chapterListView)

		self.chapterListView = nil
	}

	///
	/// Update title of the window.
	///
	fileprivate func updateTitle()
	{
		window?.title = LocalizedString("iGuya - %@", table: "Windows",	book.title)
	}

	///
	/// Attach content border view to bottom of window.
	///
	fileprivate func attachContentBorderView()
	{
		guard let superview = window?.contentView else {
			fatalError("Error: Window has no content view.")
		}

		guard let borderThickness = window?.contentBorderThickness(for: .minY) else {
			fatalError("Error: Window has no bottom content border.")
		}

		superview.addSubview(contentBorderView)

		contentBorderView.hugEdgesOfSuperview(options: [.bottom, .leading, .trailing])
		contentBorderView.heightAnchor.constraint(equalToConstant: borderThickness).isActive = true
	}
}

///
/// Prtoocol assigned to view controllers within window
/// to allow them access to the window controller.
///
protocol BookWindowAccessors
{
	var bookWindow: BookWindow { get }
	var book: Book { get }
}

///
/// Default implementation for protocol.
///
extension BookWindowAccessors where Self: NSViewController
{
	@inlinable
	var bookWindow: BookWindow
	{
		if let window = view.window?.windowController as? BookWindow {
			return window
		} else if let window = view.window?.sheetParent?.windowController as? BookWindow {
			return window
		}

		fatalError("Error: Window controller is not correct class.")
	}

	@inlinable
	var book: Book
	{
		return bookWindow.book
	}

	@inlinable
	var representedObject: Any?
	{
		return book
	}
}
