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
	/// Oldest chapter of the book.
	///
	@inlinable
	var oldestChapter: Chapter?
	{
		return chapters.first
	}

	///
	/// Newest chapter of the book.
	///
	@inlinable
	var newestChapter: Chapter?
	{
		return chapters.last
	}

	///
	/// Specific chapter in the book.
	///
	/// - Parameter number: The chapter number.
	///
	/// - Returns: The chapter or `nil` if the book does not
	/// have a chapter with that number.
	///
	@inlinable
	func chapter(numbered number: Double) -> Chapter?
	{
		return chapters.first { $0.number == number }
	}
}

extension Volume
{
	///
	/// First page of first chapter in the volume
	/// by preferred group.
	///
	/// - Returns: First page by **any group** if there
	/// is **no preferred group** or they **do not have
	/// a release for the chapter**.
	///
	@inlinable
	var firstPage: Page?
	{
		return chapters.first?.firstPage
	}

	///
	/// The index of the volume in the `volumes` array of the book.
	///
	@inlinable
	var index: Int?
	{
		return book?.volumes.firstIndex(of: self)
	}
}

extension Chapter
{
	///
	/// The book the chapter belongs to.
	///
	@inlinable
	var book: Book?
	{
		return volume?.book
	}

	///
	/// First page of the chapter.
	///
	/// If the preferred group has a release for the chapter,
	/// then the page will be returned from that release.
	/// Otherwise, it is returned from any group.
	///
	@inlinable
	var firstPage: Page?
	{
		if let release = releaseByPreferredGroup {
			return release.firstPage
		}

		return releases.first?.firstPage
	}

	///
	/// Last page of the chapter.
	///
	/// If the preferred group has a release for the chapter,
	/// then the page will be returned from that release.
	/// Otherwise, it is returned from any group.
	///
	@inlinable
	var lastPage: Page?
	{
		if let release = releaseByPreferredGroup {
			return release.lastPage
		}

		return releases.first?.lastPage
	}

	///
	/// Specific page of the chapter.
	///
	/// If the preferred group has a release for the chapter,
	/// then the page will be returned from that release.
	/// Otherwise, it is returned from any group.
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

		if let release = releaseByPreferredGroup {
			return release.page(numbered: number)
		}

		return releases.first?.page(numbered: number)
	}

	///
	/// Release in the chapter by preferred group.
	///
	/// - Returns: Release by the group or `nil` if the group
	/// does not have a release for the chapter.
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
	/// - Returns: Release by the group or `nil` if the group
	/// does not have a release in the chapter.
	///
	@inlinable
	func release(byGroup group: Group) -> Release?
	{
		return releases.first { $0.group == group }
	}

	///
	/// The index of the chapter in the `chapters` array of the volume.
	///
	@inlinable
	var volumeIndex: Int?
	{
		return volume?.chapters.firstIndex(of: self)
	}

	///
	/// The index of the chapter in the `chapters` array of the book.
	///
	@inlinable
	var bookIndex: Int?
	{
		return book?.chapters.firstIndex(of: self)
	}

	///
	/// Is the chapter the first chapter in the volume?
	///
	@inlinable
	var isFirstChapter: Bool
	{
		return (volume?.chapters.first == self)
	}

	///
	/// Is the chapter the last chapter in the volume?
	///
	@inlinable
	var isLastChapter: Bool
	{
		return (volume?.chapters.last == self)
	}

	///
	/// Is the chapter the first chapter in the book?
	///
	@inlinable
	var isFirstChapterInBook: Bool
	{
		return (book?.chapters.first == self)
	}

	///
	/// Is the chapter the last chapter in the book?
	///
	@inlinable
	var isLastChapterInBook: Bool
	{
		return (book?.chapters.last == self)
	}

	///
	/// Chapter before the current chapter.
	///
	/// The behavior of this function, by default, is to
	/// return chapters from the current volume.
	///
	/// - Parameter escapeVolume: `true` to jump to previous
	/// volume once the first chapter of the current volume
	/// is reached. `false` to return `nil` in that case.
	///
	@inlinable
	func previousChapter(escapeVolume: Bool = false) -> Chapter?
	{
		if (escapeVolume) {
			return book?.chapters.before(self)
		}

		return volume?.chapters.before(self)
	}

	///
	/// Chapter after the current chapter.
	///
	/// The behavior of this function, by default, is to
	/// return chapters from the current volume.
	///
	/// - Parameter escapeVolume: `true` to jump to next
	/// volume once the last chapter of the current volume
	/// is reached. `false` to return `nil` in that case.
	///
	@inlinable
	func nextChapter(escapeVolume: Bool = false) -> Chapter?
	{
		if (escapeVolume) {
			return book?.chapters.after(self)
		}

		return volume?.chapters.after(self)
	}

}

extension Release
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

	///
	/// The index of the release in the `releases` array of the chapter.
	///
	@inlinable
	var index: Int?
	{
		return chapter?.releases.firstIndex(of: self)
	}
}

extension Page
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
	func equivalentPage(byGroup group: Group) -> Page?
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

	///
	/// The chapter the page belongs to.
	///
	@inlinable
	var chapter: Chapter?
	{
		return release?.chapter
	}

	///
	/// The volume the page belongs to.
	///
	@inlinable
	var volume: Volume?
	{
		return chapter?.volume
	}

	///
	/// The index of the page in the `pages` array of the release.
	///
	@inlinable
	var index: Int?
	{
		return release?.pages.firstIndex(of: self)
	}

	///
	/// Is the page the first page in the release?
	///
	@inlinable
	var isFirstPage: Bool
	{
		return (release?.pages.first == self)
	}

	///
	/// Is the page the last page in the release?
	///
	@inlinable
	var isLastPage: Bool
	{
		return (release?.pages.last == self)
	}

	///
	/// Is the page the first page in the book?
	///
	@inlinable
	var isFirstPageInBook: Bool
	{
		return (isFirstPage && chapter?.isFirstChapterInBook == true)
	}

	///
	/// Is the page the last page in the book?
	///
	@inlinable
	var isLastPageInBook: Bool
	{
		return (isLastPage && chapter?.isLastChapterInBook == true)
	}

	///
	/// Page before the current page.
	///
	/// The behavior of this function, by default, is to
	/// return pages from the current chapter.
	///
	/// - Parameter escapeChapter: `true` to jump to previous
	/// chapter once the first page of the current chapter is
	/// reached. `false` to return `nil` in that case.
	///
	/// If this function has to jump to the previous chapter
	/// to return a page, then it will call the property
	/// `Chapter.lastPage` to do so. See the documentation for
	/// that property to understand how the release is picked.
	///
	@inlinable
	func previousPage(escapeChapter: Bool = false) -> Page?
	{
		if let page = release?.pages.before(self) {
			return page
		}

		if (escapeChapter == false) {
			return nil
		}

		return chapter?.previousChapter(escapeVolume: true)?.lastPage
	}

	///
	/// Page after the current page.
	///
	/// The behavior of this function, by default, is to
	/// return pages from the current chapter.
	///
	/// - Parameter escapeChapter: `true` to jump to next
	/// chapter once the last page of the current chapter is
	/// reached. `false` to return `nil` in that case.
	///
	/// If this function has to jump to the next chapter
	/// to return a page, then it will call the property
	/// `Chapter.firstPage` to do so. See the documentation for
	/// that property to understand how the release is picked.
	///
	@inlinable
	func nextPage(escapeChapter: Bool = false) -> Page?
	{
		if let page = release?.pages.after(self) {
			return page
		}

		if (escapeChapter == false) {
			return nil
		}

		return chapter?.nextChapter(escapeVolume: true)?.firstPage
	}
}
