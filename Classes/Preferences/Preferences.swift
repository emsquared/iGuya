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

final public class Preferences
{
	///
	/// Notifications posted when a preference changes.
	///
	/// Notification `object` value is `nil`.
	///
	public enum ChangeNotifications: String, RawRepresentable, NotificationName
	{
		case preferredGroup
		case layoutDirection
		case scalingMode
	}

	///
	/// Preferred release group.
	///
	/// Defaults to Jaimini's Box.
	///
	static public var preferredGroup: Group?
	{
		get {
			guard let value = UserDefaults.standard.string(forKey: "PreferredReleaseGroup") else {
				return nil
			}

			return Group.group(with: value)
		} // get

		set {
			UserDefaults.standard.set(newValue?.identifier, forKey: "PreferredReleaseGroup")

			postChangeNotification(.preferredGroup)
		} // set
	} // preferredGroup

	///
	/// Layout direction for pages.
	///
	public enum LayoutDirection: Int, CaseIterable
	{
		///
		/// Layout direction is left to right.
		///
		case leftToRight = 1

		///
		/// Layout direction is right to left.
		///
		case rightToLeft = 2

		///
		/// Layout direction is top to bottom.
		///
		case topToBottom = 3
	}

	///
	/// Layout direction for pages.
	///
	/// The layout direction of the app's user interface,
	/// which depends on the user's region, is used as
	/// the default.
	///
	static public var layoutDirection: LayoutDirection
	{
		get {
			let value = UserDefaults.standard.integer(forKey: "LayoutDirection")

			guard let direction = LayoutDirection(rawValue: value) else {
				switch (NSApp.userInterfaceLayoutDirection) {
					case .rightToLeft:
						return .rightToLeft
					default:
						return .leftToRight
				}
			}

			return direction
		} // get

		set {
			UserDefaults.standard.set(newValue.rawValue, forKey: "LayoutDirection")

			postChangeNotification(.layoutDirection)
		} // set
	} // layoutDirection

	///
	/// Scaling mode for pages.
	///
	public enum ScalingMode: Int, CaseIterable
	{
		///
		/// Scale to fit width.
		///
		case width = 0

		///
		/// Scale to fit height.
		///
		case height = 1

		///
		/// Scale to fit width and height.
		///
		case proportionally = 2

		///
		/// Do not scale.
		///
		case original = 3
	}

	///
	/// Scaling mode for pages.
	///
	/// Defaults to `.width`.
	///
	static public var scalingMode: ScalingMode
	{
		get {
			let value = UserDefaults.standard.integer(forKey: "ScalingMode")

			guard let scaling = ScalingMode(rawValue: value) else {
				return .width
			}

			return scaling
		} // get

		set {
			UserDefaults.standard.set(newValue.rawValue, forKey: "ScalingMode")

			postChangeNotification(.scalingMode)
		} // set
	} // scaling

	///
	/// Register default preference values with `UserDefaults`.
	///
	static func registerDefaults()
	{
		guard 	let file = Bundle.main.url(forResource: "RegisteredDefaults", withExtension: "plist"),
				let defaults = NSDictionary(contentsOf: file) as? [String: Any] else {
			fatalError("Error: 'RegisteredDefaults.plist' file is missing or malformed.")
		}

		UserDefaults.standard.register(defaults: defaults)
	}

	///
	/// Post change notification.
	///
	static fileprivate func postChangeNotification(_ notification: Preferences.ChangeNotifications)
	{
		NotificationCenter.default.post(name: notification.name, object: nil)
	}
}
