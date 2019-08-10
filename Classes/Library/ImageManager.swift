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
import os.log

///
/// `ImageManager` is responsible for downloading all external image
/// resources including, but not limited to, book covers and page images.
///
/// Downloads are performed using shared `URLSession` object which
/// uses `NSURLRequestUseProtocolCachePolicy` as the cache policy.
///
/// - SeeAlso: [NSURLRequestUseProtocolCachePolicy](https://developer.apple.com/documentation/foundation/nsurlrequestcachepolicy/nsurlrequestuseprotocolcachepolicy)
///
final class ImageManager
{
	///
	/// Shared instance of the image manager.
	///
	static let shared = ImageManager()

	///
	/// Errors thrown by `ImageManager`.
	///
	enum Failure: Error
	{
		///
		/// Data received from endpoint is in a form which
		/// is not expected or cannot be handled.
		///
		case dataMalformed

		///
		/// Response is not an HTTP response.
		///
		case responseNotHTTP

		///
		/// Response is not 200 (OK) status code.
		///
		/// - Parameter statusCode: status code of response.
		///
		case responseNotOK(statusCode: Int)

		///
		/// Error originated from `URLSession`
		///
		/// - Parameter error: error returned by `URLSession`
		///
		case sessionError(_ error: Error)
	}

	///
	/// Result passed to the completion handler.
	///
	/// - Parameter data: The result of request.
	/// - Parameter error: An error which describes why the request failed.
	///
	/// Both parameters will never be `nil` at the same time.
	///
	typealias CompletionResult = Result<NSImage, Failure>

	///
	/// Completion handler that is called when the request finishes.
	///
	/// - Parameter result: The result of request.
	///
	/// Both parameters will never be `nil` at the same time.
	///
	typealias CompletionHandler = (CompletionResult) -> Void

	/* Hard references to asks which is mapped to hash of URL. */
	fileprivate var tasks: [Int: URLSessionTask] = [:]

	///
	/// Download image file at `url`.
	///
	/// - Parameter url: URL to download image file from.
	/// - Parameter completionHandler: Completion handler that is called
	/// when the download finishes or an error is returned.
	///
	func image(at url: URL, _ completionHandler: @escaping CompletionHandler)
	{
		os_log("Preparing to load cover at URL: '%{public}@'.",
			   log: Logging.Subsystem.general, type: .debug, url.description)

		/* Hash of URL is used as a way to map tasks to a dictionary. */
		let key = url.hashValue

		/* Do not allow more than one task to run for the same URL. */
		if let task = tasks[key] {
			os_log("Load cancelled becauase another is already in progress.",
				   log: Logging.Subsystem.general, type: .fault)

			return
		}

		/* Create new task */
		let session = URLSession.shared

		let sessionTask = session.dataTask(with: url) { (data, response, error) in
			defer {
				self.tasks.removeValue(forKey: key)
			}

			if let error = error {
				os_log("Loading cover at '%{public}@' failed with error: '%{public}@'.",
					   log: Logging.Subsystem.general, type: .error, url.description, error.localizedDescription)

				completionHandler(.failure(.sessionError(error)))

				return
			}

			guard let response = response as? HTTPURLResponse else {
				os_log("Loading cover at '%{public}@' failed because response is not HTTP.",
					   log: Logging.Subsystem.general, type: .error, url.description)

				completionHandler(.failure(.responseNotHTTP))

				return
			}

			let statusCode = response.statusCode

			guard statusCode == 200 else {
				os_log("Loading cover at '%{public}@' failed because Not-OK status code: %{public}ld.",
					   log: Logging.Subsystem.general, type: .error, url.description, statusCode)

				completionHandler(.failure(.responseNotOK(statusCode: statusCode)))

				return
			}

			/* data should never be nil because we already checked if error is. */
			/* I have this check because I want to be sane as possible. */
			guard let data = data else {
				os_log("Loading cover at '%{public}@' failed because data is malformed.",
					   log: Logging.Subsystem.general, type: .error, url.description)

				completionHandler(.failure(.dataMalformed))

				return
			}

			/* Create image from data */
			guard let image = NSImage(data: data) else {
				os_log("Loading cover at '%{public}@' failed because an image could not be created.",
					   log: Logging.Subsystem.general, type: .error, url.description)

				completionHandler(.failure(.dataMalformed))

				return
			}

			os_log("Loading cover at '%{public}@' completed.",
				   log: Logging.Subsystem.general, type: .debug, url.description)

			completionHandler(.success(image))
		} // sessionTask

		/* Assign task */
		tasks[key] = sessionTask

		/* Start task */
		sessionTask.resume()

		os_log("Queued task to load cover at '%{public}@' as task '%{public}@'.",
			   log: Logging.Subsystem.general, type: .debug, url.description, sessionTask)
	}
}
