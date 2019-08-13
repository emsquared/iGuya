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

extension Volume
{
	///
	/// First page of first chapter in the volume
	/// by preferred group.
	///
	/// Returns first page by **any group** if there
	/// is **no preferred group** or they **do not have
	/// a release for the chapter**.
	///
	@inlinable
	var firstPage: Chapter.Release.Page?
	{
		return chapters.first?.firstPage
	}
}

extension Chapter
{
	///
	/// URL of comment page for the chapter.
	///
	/// This property is computed on the fly which is why
	/// it can return `nil`. It might not always have enough
	/// context at the time it's called.
	///
	@inlinable
	var commentPage: URL?
	{
		guard let identifier = volume?.book?.identifier else {
			return nil
		}

		let link = "https://guya.moe/reader/series/\(identifier)/\(numberFormatted)/comments"

		return URL(string: link)
	}

	///
	/// First page of the chapter by preferred group.
	///
	/// Returns first page by **any group** if there
	/// is **no preferred group** or they **do not have
	/// a release for the chapter**.
	///
	@inlinable
	var firstPage: Release.Page?
	{
		if let release = releaseByPreferredGroup {
			return release.firstPage
		}

		return releases.first?.firstPage
	}

	///
	/// Release in the chapter by preferred group.
	///
	/// - Returns: Release by the group or `nil` if the group does
	/// not have a release in the chapter.
	///
	@inlinable
	var releaseByPreferredGroup: Release?
	{
		guard let group = Preferences.preferredGroup else {
			return nil
		}

		return release(byGroup: group)
	}

	///
	/// Release by `group` in the chapter.
	///
	/// - Parameter group: The group to return release for.
	///
	/// - Returns: Release by the group or `nil` if the group does
	/// not have a release in the chapter.
	///
	@inlinable
	func release(byGroup group: Group) -> Release?
	{
		return releases.first { $0.group == group }
	}
}

extension Chapter.Release
{
	///
	/// Page numbered `number` in the release.
	///
	/// - Parameter number: The page number. **Page numbers begin at 1.**
	///
	/// - Returns: The page or `nil` if the release does not have a
	/// page with that number.
	///
	@inlinable
	func page(numbered number: Int) -> Page?
	{
		precondition(number > 0)

		return pages.first { $0.number == number }
	}

	///
	/// First page of the release.
	///
	@inlinable
	var firstPage: Page?
	{
		return pages.first
	}

	///
	/// Last page of the release.
	///
	@inlinable
	var lastPage: Page?
	{
		return pages.last
	}

	///
	/// Number of pages in the release.
	///
	@inlinable
	var numberOfPages: Int
	{
		return pages.count
	}
}

extension Chapter.Release.Page
{
	///
	/// Page equivalent to the current page by a different group.
	///
	/// - Warning: This function does not guarantee the `number`
	/// of the page returned will be the same as the `number`
	/// of the current page. Releases do not always have the
	/// same number of pages so this function may return a
	/// best choice instead of a 1:1 of page numbers.
	///
	/// - Parameter group: Group to return equivalent page for.
	///
	/// - Returns: Equivalent page or `nil` if the group does
	/// not have a release in the chapter.
	///
	func equivalentPage(byGroup group: Group) -> Chapter.Release.Page?
	{
		guard let prevRelease = release else {
			return nil
		}

		/* Return self is the group is the same. */
		if (prevRelease.group == group) {
			return self
		}

		guard let chapter = prevRelease.chapter else {
			return nil
		}

		/* Does the group have a release in the chapter? */
		guard let nextRelease = chapter.release(byGroup: group) else {
			return nil
		}

		/* Return the last page of the next release if the current
		 page has a higher number than that of the last page. */
		/* The previous release had more pages than the next release. */
		if let lastPage = nextRelease.lastPage {
			if (lastPage.number < number) {
				return lastPage
			}
		}

		/* Return 1:1 of page numbers. */
		return nextRelease.page(numbered: number)
	}
}
