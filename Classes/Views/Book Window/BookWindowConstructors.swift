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

extension BookWindow
{
	///
	/// Attach content border view to bottom of window.
	///
	func attachContentBorderView()
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


	///
	/// Constructor for volume list popup button.
	///
	func populateVolumeListPopup()
	{
		let menu = tbVolumePopup.menu

		/* Remove all items already present in the menu. */
		menu?.removeAllItems()

		/* Add item for each volume. */
		for volume in book.volumes {
			let title = String(volume.number)

			let item = NSMenuItem.item(title: title,
									   target: self,
									   action: #selector(volumeListPopupChanged),
									   representedObject: volume)

			menu?.addItem(item)
		}
	}


	///
	/// Constructor for chapter list popup button.
	///
	func populateChapterListPopup()
	{
		let menu = tbChaptersPopup.menu

		/* Remove all items already present in the menu. */
		menu?.removeAllItems()

		/* Add item to access detailed chapter list. */
		let clsItem = NSMenuItem.item(title: LocalizedString("Detailed chapter list...", table: "BookWindow"),
									  target: self,
									  action: #selector(chapterListPopupPresentList))

		menu?.addItem(clsItem)
		menu?.addItem(NSMenuItem.separator())

		/* Add item for each chapter. */
		/* TODO: Investigate making this more efficient.
		 We can't just make the menu item tag the chapter number because
		 the chapter number is a double. We could always use an offset
		 of two (detailed list item and separator) to refer to a chapter
		 in the popup, but that makes maintainability hard unless we
		 expose a function whose sole responsibility is to handle that
		 logic so there aren't a bunch of offsets spread around. */
		for chapter in book.chapters.reversed() {
			let title = "\(chapter.numberFormatted) - \(chapter.title)"

			let item = NSMenuItem.item(title: title,
									   target: self,
									   action: #selector(chapterListPopupChanged),
									   representedObject: chapter)

			menu?.addItem(item)
		}
	}


	///
	/// Constructor for page list popup button.
	///
	func populatePageListPopup()
	{
		let menu = tbPagePopup.menu

		/* Remove all items already present in the menu. */
		menu?.removeAllItems()

		/* Show message if a chapter isn't selected. */
		guard let chapter = selectedChapter else {
			let item = NSMenuItem.item(title: LocalizedString("Select a chapter to read", table: "BookWindow"))

			item.isEnabled = false

			menu?.addItem(item)

			return
		}

		/* Add item for each page. */
		#warning("TODO: Implement logic for populating page list popup.")
	}
}
