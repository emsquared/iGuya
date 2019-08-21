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

extension Book
{
	///
	/// URL of cover for the book.
	///
	var coverPage: URL
	{
		let link = "https://ka.guya.moe\(cover)"

		return URL(string: link)!
	}
}

extension Chapter
{
	///
	/// URL of comment page for the chapter.
	///
	@inlinable
	var commentPage: URL?
	{
		guard let identifier = book?.identifier else {
			return nil
		}

		let link = "https://guya.moe/reader/series/\(identifier)/\(numberFormatted)/comments"

		return URL(string: link)
	}
}

extension Page
{
	///
	/// URL of full size image for the page.
	///
	@inlinable
	public var page: URL?
	{
		guard 	let release = release,
				let chapter = release.chapter,
				let identifier = chapter.volume?.book?.identifier else {
			return nil
		}

		let link = "https://ka.guya.moe/media/manga/\(identifier)/chapters/\(chapter.folder)/\(release.group.identifier)/\(file)"

		return URL(string: link)
	}

	///
	/// URL of scaled preview image for the page.
	///
	@inlinable
	var preview: URL?
	{
		guard 	let release = release,
				let chapter = release.chapter,
				let identifier = chapter.volume?.book?.identifier else {
			return nil
		}

		let link = "https://ka.guya.moe/media/manga/\(identifier)/chapters/\(chapter.folder)/\(release.group.identifier)_shrunk/\(file)"

		return URL(string: link)
	}
	///
	/// URL of the page onnline at guya.moe.
	///
	@inlinable
	var webpage: URL?
	{
		guard 	let chapter = release?.chapter,
				let identifier = chapter.volume?.book?.identifier else {
			return nil
		}

		let link: String

		/* "Kaguya Wants To Be Confessed To" is the only book
		 that guya.moe supports short URLs for. */
		if (identifier == "Kaguya-Wants-To-Be-Confessed-To") {
			link = "https://ka.guya.moe/\(chapter.numberFormatted)/\(number)"
		} else {
			link = "https://ka.guya.moe/reader/series/\(identifier)/\(chapter.numberFormatted)/\(number)"
		}

		return URL(string: link)
	}
} // Links
