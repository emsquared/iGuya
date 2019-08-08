
import Cocoa
import iGuyaAPI
import os.log

class BookChaptersView: NSViewController, BookWindowAccessors
{
	@IBOutlet var chapterList: NSArrayController!
	@IBOutlet weak var chapterListTable: NSTableView!

	@IBOutlet weak var chapterSearchField: NSSearchField!
	@IBOutlet weak var chapterNoResultsField: NSTextField!

	fileprivate var chapterListObserver: NSKeyValueObservation?

	override func viewWillAppear()
	{
		super.viewWillAppear()

		chapterListTable.sortDescriptors = [
			NSSortDescriptor(key: "number", ascending: false)
		]

		chapterList.add(contentsOf: book.chapters)

		chapterListObserver =
		chapterList.observe(\.arrangedObjects, options: [.initial, .new]) { [weak self] (list, changes) in
			self?.updateNoResultsField()
		}
	}

	override func viewDidAppear()
	{
		super.viewDidAppear()

		view.window?.title = LocalizedString("iGuya - Chapter List - %@", table: "Windows", book.title)
	}

	override func viewWillDisappear()
	{
		super.viewWillDisappear()

		chapterListObserver?.invalidate()
		chapterListObserver = nil
	}

	func updateNoResultsField()
	{
		os_log("Refreshing 'No Results' button.",
			   log: Logging.Subsystem.general, type: .debug)

		guard let objects = chapterList.arrangedObjects as? [Any] else {
			fatalError("Error: Chapter list is not an array.")
		}

		chapterNoResultsField.isHidden = (objects.count > 0)
	}
}
