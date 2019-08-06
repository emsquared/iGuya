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

extension NSView
{
	///
	/// Toggle auto layout top, bottom, left, right anchors against superview.
	///
	/// - Parameter hug: `true` to enable anchors.
	///                  `false` to disable anchors.
	///                      Defaults to `true`.
	///
	/// - Returns: `true` on success. `false` otherwise.
	///
	@discardableResult
	func hugEdgesOfSuperview(_ hug: Bool = true) -> Bool
	{
		guard let superview = superview else {
			return false
		}

		translatesAutoresizingMaskIntoConstraints = false

		topAnchor.constraint(equalTo: superview.topAnchor, constant: 0.0).isActive = hug
		bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0.0).isActive = hug
		leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0.0).isActive = hug
		trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0.0).isActive = hug

		return true
	}
}

extension NSWindow
{
	///
	/// `true` if window is full screen. `false` otherwise.
	///
	var isFullscreen: Bool
	{
		return styleMask.contains(.fullScreen)
	}
}
