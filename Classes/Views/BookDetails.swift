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
import os.log

class BookDetailsView : NSViewController
{
	fileprivate var book: Book!

	@IBOutlet weak var bookCoverImageView: NSImageView!
	@IBOutlet weak var bookCoverNotAvailField: NSTextField!
	@IBOutlet weak var bookCoverProgressWheel: NSProgressIndicator!

	@IBOutlet var chapterList: NSArrayController!
	@IBOutlet weak var chapterListTable: NSTableView!

	@IBOutlet weak var chapterSearchField: NSSearchField!
	@IBOutlet weak var chapterNoResultsField: NSTextField!

	func assignBook(_ book: Book)
	{
		if (self.book == nil) {
			self.book = book
		}
	}

	override func viewDidLoad()
	{
		super.viewDidLoad()

		representedObject = book

		chapterListTable.sortDescriptors = [
			NSSortDescriptor(key: "number", ascending: false)
		]

		chapterList.add(contentsOf: book.chapters)
		chapterList.addObserver(self, forKeyPath: "arrangedObjects", options: [.initial, .new], context: nil)

		updateBookCoverImage()
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

	func updateBookCoverImage()
	{
		bookCoverNotAvailField.isHidden = true

		bookCoverProgressWheel.startAnimation(nil)

		ImageManager.shared.image(at: book.cover) { [weak self] (result) in
			switch (result) {
				case .success(let image):
					DispatchQueue.main.async {
						self?.bookCoverImageView.image = image
					}
				case .failure(let error):
					self?.bookCoverNotAvailField.isHidden = false

					os_log("Failed to download cover image with error: %@",
						   log: Logging.Subsystem.general, type: .error, error.localizedDescription)
			}

			DispatchQueue.main.async {
				self?.bookCoverProgressWheel.stopAnimation(nil)
			}
		} // ImageManager
	}
}
