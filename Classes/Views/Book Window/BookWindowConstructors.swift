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
	/// Constructor for group list popup buttons.
	///
	func populateGroupPopup()
	{
		/* Show message if a chapter isn't selected. */
		guard let releases = selectedChapter?.releases else {
			return
		}

		/* Remove all items already present in the menu. */
		tbGroupPopup.menu?.removeAllItems()
		cbvGroupPopup.menu?.removeAllItems()

		/* Add item for each group. */
		var items: [NSMenuItem] = []

		for release in releases {
			let group = release.group

			let title = group.name

			let item = NSMenuItem.item(title: title,
									   target: self,
									   action: #selector(groupListPopupChanged),
									   representedObject: group)

			items.append(item)
		}

		/* Add items to menu. */
		tbGroupPopup.menu?.setItemList(items)
		cbvGroupPopup.menu?.setItemList(items.mapCopy)

		/* Toggle arrow hidden if there is only one group. */
//		tbGroupPopup.toggleArrowVisibility()
		cbvGroupPopup.toggleArrowVisibility()
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
		for (index, volume) in book.volumes.enumerated() {
			let title = String(volume.number)

			let item = NSMenuItem.item(title: title,
									   target: self,
									   action: #selector(volumeListPopupChanged),
									   tag: index)

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

		/* Create item for each chapter. */
		var items: [NSMenuItem] = []

		for (index, chapter) in book.chapters.enumerated() {
			let title = "\(chapter.numberFormatted) - \(chapter.title)"

			let item = NSMenuItem.item(title: title,
									   target: self,
									   action: #selector(chapterListPopupChanged),
									   tag: index)

			items.append(item)
		}

		/* Reverse order of items. */
		/* Items are reversed after enumeration so that the index
		 assigned to `tag` is equal to what it is in the original
		 array. Not the reversed array. */
		items.reverse()

		/* Add item to access detailed chapter list. */
		items.insert(NSMenuItem.separator(withTag: Int.max), at: 0)

		let clsItem = NSMenuItem.item(title: LocalizedString("Detailed chapter list...", table: "BookWindow"),
									  target: self,
									  action: #selector(chapterListPopupPresentList),
									  tag: Int.max)

		items.insert(clsItem, at: 0)

		/* Add items to menu. */
		menu?.setItemList(items)
	}

	///
	/// Constructor for page list popup button.
	///
	func populatePageListPopup()
	{
		let menu = tbPagePopup.menu

		/* Show message if a chapter isn't selected. */
		guard let release = selectedRelease else {
			return
		}

		/* Remove all items already present in the menu. */
		menu?.removeAllItems()

		/* Add item for each page. */
		for (index, page) in release.pages.enumerated() {
			 let title = String(page.number)

			 let item = NSMenuItem.item(title: title,
										target: self,
										action: #selector(pageListPopupChanged),
										tag: index)

			 menu?.addItem(item)
		 }
	}
}
