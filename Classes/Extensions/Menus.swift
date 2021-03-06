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

public extension NSMenu
{
	func setItemList(_ itemList: [NSMenuItem])
	{
		/* "This property is settable in macOS 10.14 and later." */
		if #available(macOS 10.14, *) {
			items = itemList
		} else {
			removeAllItems()

			for item in itemList {
				addItem(item)
			}
		}
	} // setItemList
}

public extension NSMenuItem
{
	static func separator(withTag tag: Int) -> NSMenuItem
	{
		let item = separator()

		item.tag = tag

		return item
	}

	static func item(title: String, target: AnyObject? = nil, action: Selector? = nil, tag: Int = 0, representedObject: Any? = nil, keyEquivalent: String = "", keyEquivalentMask: NSEvent.ModifierFlags = []) -> NSMenuItem
	{
		let item = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)

		item.target = target

		item.tag = tag

		item.representedObject = representedObject

		item.keyEquivalentModifierMask = keyEquivalentMask

		return item
	}
}
