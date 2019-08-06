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

///
/// Custom segue to crossfade two view controllers on a parent.
///
class CrossfadeStoryboardSegue : NSStoryboardSegue
{
    override func perform()
	{
		let nextController = destinationController as! NSViewController
		let prevController = sourceController as! NSViewController
		let containerController = prevController.parent! as NSViewController

		/* Disable top, bottom, right, left anchors on superview. */
		prevController.view.hugEdgesOfSuperview(false)

		/* Add next controller as child of container. */
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
			return
		}

		let oldFrameSize = containerController.view.frame.size
		let newFrameSize = nextController.view.frame.size

		let horizontalChange = ((newFrameSize.width - oldFrameSize.width) / 2.0)
		let verticalChange = ((newFrameSize.height - oldFrameSize.height) / 2.0)

		var windowFrame = window.frame

		windowFrame.origin.x -= horizontalChange
		windowFrame.origin.y += verticalChange // TODO: why is this + and not - ?

		window.setFrame(windowFrame, display: true, animate: true)
    }
}
