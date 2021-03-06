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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NSString *LocalizedStringPassthrough(NSString *string, NSString * _Nullable table, NSBundle * _Nullable bundle, va_list arguements)
{
	NSCParameterAssert(string != nil);

	if (bundle == nil) {
		bundle = NSBundle.mainBundle;
	}

	NSString *formatter = [bundle localizedStringForKey:string value:string table:table];

	return [[NSString alloc] initWithFormat:formatter arguments:arguements];
}

NSString *LocalizedString(NSString *string, NSString * _Nullable table, ...)
{
	NSCParameterAssert(string != nil);

	va_list arguments;
	va_start(arguments, table);

	NSString *result = LocalizedStringPassthrough(string, table, nil, arguments);

	va_end(arguments);

	return result;
}

NSString *LocalizedStringInBundle(NSString *string, NSString * _Nullable table, NSBundle *bundle, ...)
{
	NSCParameterAssert(string != nil);
	NSCParameterAssert(bundle != nil);

	va_list arguments;
	va_start(arguments, bundle);

	NSString *result = LocalizedStringPassthrough(string, table, bundle, arguments);

	va_end(arguments);

	return result;
}

NS_ASSUME_NONNULL_END
