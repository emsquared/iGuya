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

final public class BookManager
{
	///
	/// Shared instance of the book manager.
	///
	static public let shared = BookManager()

	///
	/// List of books.
	///
	fileprivate(set) public var books: Books?

	///
	/// The books request.
	///
	fileprivate var booksRequest: Request<Books>?

	///
	/// `true` if a books request is in progress. `false` otherwise.
	///
	fileprivate(set) public var requestingBooks = false

	///
	/// Dictionary mapping book identifier to a weight.
	///
	/// The weight is used when sorting the list of books.
	/// Weight is sorted in descending order which means
	/// the highest weight will always be first.
	///
	fileprivate static let bookWeights = [
		"Kaguya-Wants-To-Be-Confessed-To" 					: 1000,
		"Kaguya-Wants-To-Be-Confessed-To-Official-Doujin" 	: 99,
		"We-Want-To-Talk-About-Kaguya" 						: 98
	]

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
	public func requestBooks(returningLocalCache: Bool = true, _ completionHandler: @escaping Request<Books>.CompletionHandler) -> Bool
	{
		if (requestingBooks) {
			return false
		}

		if (returningLocalCache && books != nil) {
			completionHandler(.success(books!))

			return true
		}

		let request = Gateway.getBooks { (result) in
			self.requestBooksCompleted(with: result, completionHandler: completionHandler)
		}

		booksRequest = request

		requestingBooks = true

		request.start()

		return true
	}

	///
	/// Callback handler for books request.
	///
	fileprivate func requestBooksCompleted(with result: Request<Books>.CompletionResult, completionHandler: Request<Books>.CompletionHandler)
	{
		booksRequest = nil

		requestingBooks = false

		switch (result) {
			case .success(var books):
				books.sort(by: { (lhs, rhs) -> Bool in
					guard 	let lhw = Self.bookWeights[lhs.identifier],
							let rhw = Self.bookWeights[rhs.identifier] else
					{
						return false
					}

					return (lhw > rhw)
				}) // sort

				self.books = books

				/* Redeclare result to pass sorted result. */
				completionHandler(.success(books))
			default:
				completionHandler(result)
		}
	}
}
