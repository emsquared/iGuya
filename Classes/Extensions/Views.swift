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

public extension NSView
{
	struct HugEdgesOfSuperviewOptions: OptionSet
	{
		public typealias RawValue = Int

		public var rawValue = 0

		static public let top			= Self(rawValue: 1 << 0)
		static public let bottom		= Self(rawValue: 1 << 1)
		static public let leading		= Self(rawValue: 1 << 2)
		static public let trailing		= Self(rawValue: 1 << 3)

		static public let all: Self = [.top, .bottom, .leading, .trailing]

		public init(rawValue: RawValue)
		{
			self.rawValue = rawValue
		}
	}
	///
	/// Toggle auto layout top, bottom, left, right anchors against superview.
	///
	/// - Parameter hug: `true` to enable anchors.
	///                  `false` to disable anchors.
	///                      Defaults to `true`.
	/// - Parameter options: Which edges of superview to apply to.
	///                      Defaults to all edges.
	///
	/// - Returns: `true` on success. `false` otherwise.
	///
	@discardableResult
	func hugEdgesOfSuperview(_ hug: Bool = true, options: HugEdgesOfSuperviewOptions = .all) -> Bool
	{
		guard let superview = superview else {
			return false
		}

		translatesAutoresizingMaskIntoConstraints = false

		if (options.contains(.top)) {
			topAnchor.constraint(equalTo: superview.topAnchor, constant: 0.0).isActive = hug
		}

		if (options.contains(.bottom)) {
			bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0.0).isActive = hug
		}

		if (options.contains(.leading)) {
			leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0.0).isActive = hug
		}

		if (options.contains(.trailing)) {
			trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0.0).isActive = hug
		}

		return true
	}
}

public extension NSViewController
{
	///
	/// Perform crossfade transition to a view controller.
	///
	/// - Warning: This function assumes there is ever only one child
	/// view controller in the host view (self).
	/// Breaking this assumption will result in undefined behavior.
	///
	/// - Parameter nextController: View controller to transition to.
	///
	/// - Returns: `true` on success. `false` otherwise.
	///
	@discardableResult @inlinable
	func crossfade(to nextController: NSViewController) -> Bool
	{
		guard let prevController = children.first else {
			return false
		}

		return NSViewController.crossfade(from: prevController, to: nextController)
	}

	///
	/// Perform crossfade transition to a view controller.
	///
	/// - Parameter prevController: View controller to transition from.
	/// - Parameter nextController: View controller to transition to.
	///
	/// - Warning: This function assumes there is ever only one child
	/// view controller in the host view (parent of `prevController`).
	/// Breaking this assumption will result in undefined behavior.
	///
	/// - Returns: `true` on success. `false` otherwise.
	///
	@discardableResult
	static func crossfade(from prevController: NSViewController, to nextController: NSViewController) -> Bool
	{
		/* Let's be sane. */
		if (prevController == nextController) {
			return false
		}

		/* Disable top, bottom, right, left anchors on superview. */
		prevController.view.hugEdgesOfSuperview(false)

		/* Add next controller as child of container. */
		let containerController = prevController.parent!

		containerController.insertChild(nextController, at: 1)

		/* Ask for layers to make transition smoother. */
		prevController.view.wantsLayer = true
		nextController.view.wantsLayer = true

		/* Perform transition using crossfade. */
		containerController.transition(from: prevController, to: nextController, options: .crossfade) {
			containerController.removeChild(at: 0)
		}

		/* Enable top, bottom, right, left anchors on superview. */
		nextController.view.hugEdgesOfSuperview()

		/* Adjust window frame so that new window is centered in position of old window. */
		let window = containerController.view.window!

		if (window.isFullscreen) {
			return false
		}

		let oldFrameSize = containerController.view.frame.size
		let newFrameSize = nextController.view.frame.size

		let horizontalChange = ((newFrameSize.width - oldFrameSize.width) / 2.0)
		let verticalChange = ((newFrameSize.height - oldFrameSize.height) / 2.0)

		var windowFrame = window.frame

		windowFrame.origin.x -= horizontalChange
		windowFrame.origin.y += verticalChange // TODO: why is this + and not - ?

		window.setFrame(windowFrame, display: true, animate: true)

		return true
	}
}

public extension NSWindow
{
	///
	/// `true` if window is full screen. `false` otherwise.
	///
	@inlinable
	var isFullscreen: Bool
	{
		return styleMask.contains(.fullScreen)
	}
}
