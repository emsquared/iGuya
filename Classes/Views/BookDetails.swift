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
import Dispatch
import iGuyaAPI

class BookDetailsView : NSViewController, BookCoverImage
{
	fileprivate var book: Book!

	@IBOutlet weak var bookCoverImageView: NSImageView!
	@IBOutlet weak var bookCoverNotAvailField: NSTextField!
	@IBOutlet weak var bookCoverProgressWheel: NSProgressIndicator!

	@IBOutlet var chapterList: NSArrayController!
	@IBOutlet weak var chapterListTable: NSTableView!

	@IBOutlet weak var chapterSearchField: NSSearchField!
	@IBOutlet weak var chapterNoResultsField: NSTextField!

	override func viewDidLoad()
	{
		super.viewDidLoad()

		if let book = representedObject as? Book {
			self.book = book
		} else {
			fatalError("Error: Book not assigned to represented object.")
		}

		chapterListTable.sortDescriptors = [
			NSSortDescriptor(key: "number", ascending: false)
		]

		chapterList.add(contentsOf: book.chapters)
		chapterList.addObserver(self, forKeyPath: "arrangedObjects", options: [.initial, .new], context: nil)

		loadBookCoverImage(at: book.cover)
	}

	override func viewDidAppear()
	{
		super.viewDidAppear()

		view.window?.title = LocalizedString("iGuya - Manga: %@", table: "MainWindow", book.title)
	}

	override func viewWillDisappear()
	{
		super.viewWillDisappear()

		chapterList.removeObserver(self, forKeyPath: "arrangedObjects")
	}

	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
	{
		if (keyPath == "arrangedObjects") {
			updateNoResultsField()
		}
	}

	func updateNoResultsField()
	{
		guard let objects = chapterList.arrangedObjects as? [Any] else {
			return
		}

		chapterNoResultsField.isHidden = (objects.count > 0)
	}
}
