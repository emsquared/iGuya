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

final class BookListCell: NSCollectionViewItem, BookCoverImage
{
	@IBOutlet weak var bookCoverImageView: NSImageView!
	@IBOutlet weak var bookCoverNotAvailField: NSTextField!
	@IBOutlet weak var bookCoverProgressWheel: NSProgressIndicator!

	fileprivate var bookDetailsPopover: NSViewController?

	override func mouseDown(with event: NSEvent)
	{
		super.mouseDown(with: event)

		presentBookDetails()
	}

	override func dismiss(_ viewController: NSViewController)
	{
		super.dismiss(viewController)

		if (bookDetailsPopover == viewController) {
			bookDetailsPopover = nil
		}
	}

	fileprivate func presentBookDetails()
	{
		if (bookDetailsPopover != nil) {
			return
		}

		guard let delegate = collectionView?.delegate as? BookListView else {
			fatalError("Error: Delegate of collection view is not of type 'BookListView'")
		}

		guard let controller = delegate.storyboard?.instantiateController(withIdentifier: "BookDetails") as? NSViewController else {
			fatalError("Error: Storyboard does not contain a 'BookDetails' controller.")
		}

		controller.representedObject = representedObject

		present(controller, asPopoverRelativeTo: view.bounds, of: view, preferredEdge: .maxX, behavior: .semitransient)

		bookDetailsPopover = controller
	}

	override func viewWillAppear()
	{
		super.viewWillAppear()

		/* representedObject is set after viewDidLoad() is called
		 but before the view appears so load the cover from here. */
		/* BookListView retains one copy of this class which it uses
		 as a template for sizing. That's not a problem for this
	 	 section of code because the view will never appear on
		 screen. It's still good to document this here in case
		 the codebase of the cell if ever expanded. */
		guard let book = representedObject as? Book else {
			fatalError("Error: Represented object is of unexpected type.")
		}

		loadBookCoverImage(at: book.cover)
	}
}
