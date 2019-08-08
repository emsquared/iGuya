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

class BookListView: NSViewController, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout
{
	@IBOutlet private var list: NSArrayController!
	@IBOutlet private var listCollection: NSCollectionView!

	@IBOutlet private var listProgressView: NSView!
	@IBOutlet private var listProgressWheel: NSProgressIndicator!

	fileprivate var listSizingCell: BookListCell?

	override func viewDidLoad()
	{
		super.viewDidLoad()

		loadBooks()

		guard let cell = NSNib(nibNamed: "BookListCell", bundle: nil) else {
			fatalError("Error: Book list cell nib could not be loaded.")
		}

		listCollection.register(cell, forItemWithIdentifier: NSUserInterfaceItemIdentifier("BookListCell"))

		instantiateSizingTemplate(in: cell)
	}

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize
	{
		guard let size = calculateSize(forItemAt: indexPath) else {
			fatalError("Error: Failed to calculate size of cell.")
		}

		return size
	}

	fileprivate func book(at indexPath: IndexPath) -> Book?
	{
		guard let books = list.arrangedObjects as? [Book] else {
			return nil
		}

		return books[indexPath.item]
	}

	fileprivate func calculateSize(forItemAt indexPath: IndexPath) -> NSSize?
	{
		guard let book = book(at: indexPath) else {
			return nil
		}

		/* Change represented object to force title (which
		 is bound to the represented object) to update. */
		listSizingCell?.representedObject = book

		/* Ask the cell to perform layout. */
		listSizingCell?.view.layoutSubtreeIfNeeded()

		return listSizingCell?.view.fittingSize
	}

	fileprivate func instantiateSizingTemplate(in nib: NSNib)
	{
		let template = BookListCell()

		var topLevelObjects: NSArray?

		guard nib.instantiate(withOwner: template, topLevelObjects: &topLevelObjects) else {
			fatalError("Error: Sizing template could not be instantiated.")
		}

		guard let objects = topLevelObjects as? [Any] else {
			fatalError("Error: Sizing template objects cannot be read.")
		}

		for object in objects {
			if let cell = object as? BookListCell {
				listSizingCell = cell

				return
			}
		} // for
	}

	fileprivate func loadBooks()
	{
		listProgressView.isHidden = false
		listProgressWheel.startAnimation(nil)

		BookManager.shared.requestBooks { [weak self] (result) in
			switch (result) {
				case .success(let books):
					self?.list.add(contentsOf: books)
				case .failure(let error):
					#warning("TODO: Handle errors")

					os_log("Failed to load books with error: '%{public}@'",
						   log: Logging.Subsystem.general, type: .error, error.localizedDescription)
			}

			DispatchQueue.main.async {
				self?.listProgressView.isHidden = true
				self?.listProgressWheel.stopAnimation(nil)
			}
		} // BookManager
	}
}
