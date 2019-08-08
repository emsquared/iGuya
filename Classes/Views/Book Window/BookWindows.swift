
import Cocoa
import iGuyaAPI
import os.log

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
class BookWindows
{
	///
	/// Shared instance of `BookWindows`.
	///
	static let shared = BookWindows()

	///
	/// Dictionary of window controllers mapped to book identifiers.
	///
	fileprivate var windows: [String : BookWindow] = [:]

	///
	/// Dispatch queue to perform access to `windows` on to
	/// avoid race conditions.
	///
	fileprivate let workerQueue = DispatchQueue(label: "BookWindowsQueue")

	/* Token for observing notifications. */
	fileprivate var notificationObserver: NSObjectProtocol?

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
		os_log("Constructing observers for 'BookWindows'.",
			   log: Logging.Subsystem.general, type: .debug)

		notificationObserver =
		NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: nil, queue: nil) { [weak self] (notification) in
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
		os_log("Tearing down observers for 'BookWindows'.",
			   log: Logging.Subsystem.general, type: .debug)

		NotificationCenter.default.removeObserver(notificationObserver)
		notificationObserver = nil
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

				os_log("Removing window '%{public}@' from store.",
					   log: Logging.Subsystem.general, type: .debug, controller)
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
		os_log("Presenting window for '%{public}@' with navigation action: '%{public}@'",
			   log: Logging.Subsystem.general, type: .debug, book.identifier, String(describing: navigationAction))

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

		os_log("Adding window '%{public}@' to store.",
			   log: Logging.Subsystem.general, type: .debug, controller)

		return controller
	}
}

