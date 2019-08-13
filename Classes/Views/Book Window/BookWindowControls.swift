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
	/// Update "page of page" label in content border view.
	///
	fileprivate func updateCurrentPageField()
	{
		guard let page = selectedPage,
			  let release = selectedRelease else
		{
			cbvCurrentPageField.stringValue = ""

			return
		}

		cbvCurrentPageField.stringValue = LocalizedString("Page %1$ld of %2$ld", table: "BookWindow", page.number, release.numberOfPages)
	}

	///
	/// Update group popup by selecting the group associated
	/// with the selected release.
	///
	func updateGroupPopup()
	{
		guard let group = selectedRelease?.group else {
			return
		}

		tbGroupPopup.selectItem(withRepresentedObject: group)
		cbvGroupPopup.selectItem(withRepresentedObject: group)
	}

	///
	/// Update appearance of layout direction button.
	///
	func updateLayoutDirectionButton()
	{
		let image: String

		switch (layoutDirection) {
			case .rightToLeft:
				image = "LayoutDirectionRTLTemplate"
			case .leftToRight:
				image = "LayoutDirectionLTRTemplate"
			case .topToBottom:
				image = "LayoutDirectionTTBTemplate"
		}

		tbLayoutButton.image = NSImage(named: image)
	}
}
