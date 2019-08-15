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

extension BookWindow
{
	///
	/// Action for comment button.
	///
	@IBAction
	func commentButtonClicked(_ sender: Any)
	{
		guard let commentPage = selectedChapter?.commentPage else {
			return
		}

		NSWorkspace.shared.open(commentPage)
	}

	///
	/// Action for layout direction button.
	///
	@IBAction
	func layoutDirectionButtonClicked(_ sender: Any?)
	{
		changeLayoutDirection(to: layoutDirection.next)

		updateLayoutDirectionButton()
	}

	///
	/// Action for group changes in the group list popup button.
	///
	@objc
	func groupListPopupChanged(_ sender: Any)
	{
		guard 	let sender = sender as? NSMenuItem,
				let group = sender.representedObject as? Group else {
			fatalError("Error: Unexpected object passed to \(#function) as 'sender'.")
		}

		guard 	let prevPage = selectedPage,
				let nextPage = prevPage.equivalentPage(byGroup: group) else {
			return
		}

		performNavigation(toPage: nextPage)
	}

	///
	/// Action for volume changes in the volume list popup button.
	///
	@objc
	func volumeListPopupChanged(_ sender: Any?)
	{
		guard let sender = sender as? NSMenuItem else {
			fatalError("Error: Unexpected object passed to \(#function) as 'sender'.")
		}

		let index = sender.tag

		let volume = book.volumes[index]

		guard let page = volume.firstPage else {
			return
		}

		performNavigation(toPage: page)
	}

	///
	/// Action for chapter changes in the chapter list popup button.
	///
	@objc
	func chapterListPopupChanged(_ sender: Any?)
	{
		guard let sender = sender as? NSMenuItem else {
			fatalError("Error: Unexpected object passed to \(#function) as 'sender'.")
		}

		let index = sender.tag

		let chapter = book.chapters[index]

		guard let page = chapter.firstPage else {
			return
		}

		performNavigation(toPage: page)
	}

	///
	/// Action to present chapter list sheet in the chapter list popup button.
	///
	@objc
	func chapterListPopupPresentList(_ sender: Any?)
	{
		presentChapterList()
	}

	///
	/// Action for page changes in the page list popup button.
	///
	@objc
	func pageListPopupChanged(_ sender: Any?)
	{
		guard let sender = sender as? NSMenuItem else {
			fatalError("Error: Unexpected object passed to \(#function) as 'sender'.")
		}

		guard let release = selectedRelease else {
			return
		}

		let index = sender.tag

		let page = release.pages[index]

		performNavigation(toPage: page)
	}

	///
	/// Action for page changes in the page navigator segmented control.
	///
	@IBAction
	func pageNavigatorClicked(_ sender: Any?)
	{
		guard let sender = sender as? NSSegmentedControl else {
			fatalError("Error: Unexpected object passed to \(#function) as 'sender'.")
		}

		switch (sender.selectedSegment) {
			case 0: // Back
				performNavigation(.nextPage)
			case 1: // Forward
				performNavigation(.previousPage)
			default:
				break
		} // switch
	}
}
