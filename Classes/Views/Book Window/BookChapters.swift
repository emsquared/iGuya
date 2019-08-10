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

final class BookChaptersView: NSViewController, BookWindowAccessors
{
	@IBOutlet private var chapterList: NSArrayController!
	@IBOutlet private weak var chapterListTable: NSTableView!

	@IBOutlet private weak var chapterSearchField: NSSearchField!
	@IBOutlet private weak var chapterNoResultsField: NSTextField!

	fileprivate var chapterListObserver: NSKeyValueObservation?

	override func viewWillAppear()
	{
		super.viewWillAppear()

		chapterListTable.sortDescriptors = [
			NSSortDescriptor(key: "number", ascending: false)
		]

		chapterList.add(contentsOf: book.chapters)

		chapterListObserver =
		chapterList.observe(\.arrangedObjects, options: [.initial, .new]) { [weak self] (_, _) in
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

		chapterNoResultsField.isHidden = !objects.isEmpty
	}
}
