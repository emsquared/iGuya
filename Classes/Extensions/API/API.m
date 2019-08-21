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

#import "APIExtensionPrivate.h"
#import "LocalizationPrivate.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark -

@implementation Book (iGuyaHelper)

- (NSString *)numberOfChapters
{
	/* Show chapter number for latest chapter as the count instead
	 of the count of `chapters` because special pages are treated
	 as chapters so showing user there is 177 chapters when the
	 latest chapter is numbered 158 can be confusing. */
	/* Sort of `chapters` is stable so we only need last one. */
	Chapter *lastChapter = self.chapters.lastObject;

	if (lastChapter == nil) {
		return @"0";
	}

	return lastChapter.numberFormatted;
}

@end

#pragma mark -

@implementation Chapter (iGuyaHelper)

- (NSString *)groupsFormatted
{
	if (self.groups.count == 1) {
		return self.groups.firstObject.name;
	} else {
		return LocalizedString(@"Multiple groups", @"API");
	}
}

- (NSString *)numberFormatted
{
	NSNumberFormatter *formatter = [NSNumberFormatter new];

	formatter.minimumFractionDigits = 0;
	formatter.maximumFractionDigits = 2;

	formatter.numberStyle = NSNumberFormatterDecimalStyle;

	return [formatter stringFromNumber:@(self.number)];
}

@end

NS_ASSUME_NONNULL_END
