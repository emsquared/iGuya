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

import Foundation
import iGuyaAPI
import os.log

class BookManager
{
	///
	/// Shared instance of the book manager.
	///
	static let shared = BookManager()

	///
	/// List of books.
	///
	fileprivate(set) var books: Books?

	///
	/// The books request.
	///
	fileprivate var booksRequest: Request<Books>?

	///
	/// `true` if a books request is in progress. `false` otherwise.
	///
	fileprivate(set) var requestingBooks = false

	///
	/// Request books.
	///
	/// The API is designed to cache books which means the books
	/// returned may be those already cached in memory and/or disk.
	///
	/// - Parameter returningLocalCache: If `true`, then the contents of
	/// `BookManager.books` is returned if it is already set.
	/// This parameter **does not disable caching performed by API**.
	/// - Parameter completionHandler: A completion handler
	/// to call when request is finished.
	///
	/// - Returns: `true` on success creating request. `false` otherwise.
	///
	@discardableResult
	func requestBooks(returningLocalCache: Bool = true, _ completionHandler: @escaping Request<Books>.CompletionHandler) -> Bool
	{
		os_log("Preparing to request books.",
			   log: Logging.Subsystem.general, type: .debug)

		if (requestingBooks) {
			os_log("Request cancelled becauase another is already in progress.",
				   log: Logging.Subsystem.general, type: .fault)

			return false
		}

		if (returningLocalCache && books != nil) {
			os_log("Returning books from local cache.",
				   log: Logging.Subsystem.general, type: .debug)

			completionHandler(.success(books!))

			return true
		}

		let request = Gateway.getBooks { (result) in
			self.requestBooksCompleted(with: result, completionHandler: completionHandler)
		}

		booksRequest = request

		requestingBooks = true

		request.start()

		os_log("Queued request for books.",
			   log: Logging.Subsystem.general, type: .debug)

		return true
	}

	///
	/// Callback handler for books request.
	///
	fileprivate func requestBooksCompleted(with result: Request<Books>.CompletionResult, completionHandler: Request<Books>.CompletionHandler)
	{
		os_log("Book request completed.",
			   log: Logging.Subsystem.general, type: .debug)

		booksRequest = nil

		requestingBooks = false

		if case .success(let data) = result {
			books = data
		}

		completionHandler(result)
	}
}
