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

class MainWindow : NSWindowController
{
	@IBAction func selectHomeViewController(_ sender: Any?)
	{
		if (onHomeViewController) {
			os_log("Tried to transition to home while on home",
				   log: Logging.Subsystem.general, type: .fault)

			return
		}

		let bookListView = instantiateBookList()

		present(viewController: bookListView)
	}

	fileprivate func present(viewController: NSViewController)
	{
		contentView.crossfade(to: viewController)
	}

	fileprivate var onHomeViewController: Bool
	{
		return childView is BookListView
	}

	fileprivate var contentView: MainWindowContentView
	{
		guard let contentView = contentViewController as? MainWindowContentView else {
			fatalError("Error: Content view is not of type 'MainWindowContentView'")
		}

		return contentView
	}

	fileprivate var childView: NSViewController?
	{
		return contentView.children.first
	}

	override func windowDidLoad()
	{
		super.windowDidLoad()

		let bookListView = instantiateBookList()

		contentView.assignInitialView(bookListView)
	}

	fileprivate func instantiateBookList() -> BookListView
	{
		guard let controller = storyboard?.instantiateController(withIdentifier: "BookList") as? BookListView else {
			fatalError("Error: Storyboard does not contain a 'BooksList' controller.")
		}

		return controller
	}
}

/* ------------------------------------------------------ */

class MainWindowContentView : NSViewController
{
	fileprivate func assignInitialView(_ controller: NSViewController)
	{
		if (children.count > 0) {
			fatalError("Error: Tried to assign an initial view to a controller that already has children.")
		}

		addChild(controller)
	}

	override func viewWillAppear()
	{
		super.viewWillAppear()

		guard let firstView = children.first?.view else {
			fatalError("Error: Controller does not have any children.")
		}

		view.addSubview(firstView)

		firstView.hugEdgesOfSuperview()
	}
}
