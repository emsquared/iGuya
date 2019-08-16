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

///
/// Each book is assigned a single window within the app which all
/// actions related to that book are performed within. Actions such
/// as viewing list of chapters or reading a specific chapter.
///
/// `BookWindows` manages the life cycle of these windows.
/// It maintains a strong reference to each window on screen and
/// only allows one to ever exist.
///
/// `BookWindows` also acts as a factory. The `presentWindow()`
/// function will create a new window for the book passed to it
/// or it will simply make that window the frontmost.
///
final class BookWindows
{
	///
	/// Shared instance of `BookWindows`.
	///
	static let shared = BookWindows()

	///
	/// Dictionary of window controllers mapped to book identifiers.
	///
	fileprivate var windows: [String: BookWindow] = [:]

	///
	/// Dispatch queue to perform access to `windows` on to
	/// avoid race conditions.
	///
	fileprivate let workerQueue = DispatchQueue(label: "BookWindowsQueue")

	init() {
		constructObservers()
	}

	deinit {
		teardownObservers()
	}

	///
	/// Construct notification observers.
	///
	fileprivate func constructObservers()
	{
		NotificationManager.shared.add(observer: self, forName: NSWindow.willCloseNotification) { [weak self] (notification) in
			guard let window = notification.object as? NSWindow else {
				return
			}

			self?.windowWillClose(window)
		}
	}

	///
	/// Teardown notification observers.
	///
	fileprivate func teardownObservers()
	{
		NotificationManager.shared.remove(observer: self, forName: NSWindow.willCloseNotification)
	}

	///
	/// Observer for when windows close so that the strong
	/// reference maintained by the store can be dropped.
	///
	fileprivate func windowWillClose(_ window: NSWindow)
	{
		guard let controller = window.windowController else {
			return
		}

		workerQueue.sync {
			if let key = windows.firstIndex(where: { $1 === controller }) {
				windows.remove(at: key)
			}
		}
	}

	///
	/// Make window for `book` key, order it front, and
	/// optionally navigate to a section of the book.
	///
	/// If there is no window on screen already associated with
	/// the book, then one is created.
	///
	/// - Parameter book: Book to present window for.
	/// - Parameter navigationAction: Optional navigation action
	/// to perform on the book when presenting the window.
	/// For example: the action `.latestChapter` will instruct
	/// the window to navigate to the latest chapter of the book.
	///
	func presentWindow(forBook book: Book, navigationAction: BookWindow.NavigationAction = .none)
	{
		var window = self.window(forBook: book)

		if (window == nil) {
			window = instantiateWindow(forBook: book)
		}

		window?.presentWindow(navigationAction: navigationAction)
	}

	///
	/// Return window controller from store that belongs to `book`.
	///
	/// - Parameter book: Book to return associated window controller for.
	///
	fileprivate func window(forBook book: Book) -> BookWindow?
	{
		workerQueue.sync {
			let key = book.identifier

			return windows[key]
		}
	}

	///
	/// Instantiate storyboard named "BookWindow" and associate with `book`.
	///
	/// - Parameter book: Book to assign to the `referenceObject`
	/// property of the window controller's content view controller.
	///
	fileprivate func instantiateWindow(forBook book: Book) -> BookWindow
	{
		let storyboard = NSStoryboard(name: "BookWindow", bundle: nil)

		guard let controller = storyboard.instantiateInitialController() as? BookWindow else {
			fatalError("Error: Storyboard does not contain an initial window controller.")
		}

		controller.representedObject = book

		workerQueue.sync {
			let key = book.identifier

			windows[key] = controller
		}

		return controller
	}
}
