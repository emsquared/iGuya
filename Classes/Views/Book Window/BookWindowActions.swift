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
	/// Action for volume changes in the volume list popup button.
	///
	@objc
	func volumeListPopupChanged(_ sender: Any?)
	{
		Logging.logFunctionCall()

		guard  	let sender = sender as? NSMenuItem,
				let index = sender.representedObject as? Int else {
			fatalError("Error: Unexpected object passed to \(#function) as 'sender'.")
		}

		let volume = book.volumes[index]

		guard let page = volume.firstPage else {
			/* This should be impossible. */
			os_log("Volume does not contain a first page.",
				   log: Logging.Subsystem.general, type: .fault)

			return
		}

		changePage(toPage: page)
	}

	///
	/// Action for chapter changes in the chapter list popup button.
	///
	@objc
	func chapterListPopupChanged(_ sender: Any?)
	{
		Logging.logFunctionCall()

		guard  	let sender = sender as? NSMenuItem,
				let index = sender.representedObject as? Int else {
			fatalError("Error: Unexpected object passed to \(#function) as 'sender'.")
		}

		let chapter = book.chapters[index]

		guard let page = chapter.firstPage else {
			/* This should be impossible. */
			os_log("Chapter does not contain a first page.",
				   log: Logging.Subsystem.general, type: .fault)

			return
		}

		changePage(toPage: page)
	}

	///
	/// Action to present chapter list sheet in the chapter list popup button.
	///
	@objc
	func chapterListPopupPresentList(_ sender: Any?)
	{
		Logging.logFunctionCall()

		presentChapterList()
	}

	///
	/// Action for page changes in the page list popup button.
	///
	@objc
	func pageListPopupChanged(_ sender: Any?)
	{
		Logging.logFunctionCall()

		guard  	let sender = sender as? NSMenuItem,
				let index = sender.representedObject as? Int else {
			fatalError("Error: Unexpected object passed to \(#function) as 'sender'.")
		}

		guard let release = selectedRelease else {
			/* This should be impossible. */
			os_log("Tried to change to a page with no chapter selected.",
				   log: Logging.Subsystem.general, type: .fault)

			return
		}

		let page = release.pages[index]

		changePage(toPage: page)
	}
}
