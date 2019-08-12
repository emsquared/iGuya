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
import os.log

///
/// `NotificationManager` helps make block-based notification observation easier.
/// It abstracts away the unnecessary clutter of maintaining references to notification
/// tokens that are needed to remove observations.
///
/// `NotificationManager` uses `NotificationCenter.default` as its notification center.
///

final public class NotificationManager
{
	///
	/// Shared instance of the notification manager.
	///
	static public let shared = NotificationManager()

	///
	/// Type of the observer for a notification.
	///
	public typealias Observer = AnyObject

	///
	/// Type of the name of the notification to observe.
	///
	public typealias Name = Notification.Name

	///
	/// `Observation` is used internally as a store to
	/// associate the observer with its notification name,
	/// and the token for observing it.
	///
	fileprivate struct Observation
	{
		let observer: Observer
		let name: Name?

		let token: NSObjectProtocol
	}

	///
	/// Array of active observations.
	///
	fileprivate var observations: [Observation] = []

	///
	/// Dispatch queue to perform access to `observations`
	/// on to avoid race conditions.
	///
	fileprivate let observationsQueue = DispatchQueue(label: "NotificationObservationsQueue")

	///
	/// Add a notification observer.
	///
	/// - Parameter observer: The observer of the notification.
	/// - Parameter name: The name of the notification.
	/// - Parameter object: An object to observe notifications from.
	/// - Parameter queue: An operation queue to perform `block` on.
	/// - Parameter block: A block to perform when a notification is posted.
	///
	/// `observer` is used to associate an observation with a specific object.
	/// The `observer` is not interacted with when notification is posted.
	/// Only the block passed to the `block` parameter is.
	///
	public func add(observer: Observer, forName name: Name?, object: Any? = nil, queue: OperationQueue? = nil, using block: @escaping (Notification) -> Void)
	{
		observationsQueue.sync {
			if let _ = observations.first(where: { (observation) in
				(	observation.observer 	=== 	observer &&
					observation.name 		== 		name)

			}) /* if */ {
				os_log("'%{public}@' already exists as an observer of '%{public}@'.",
					   log: Logging.Subsystem.general, type: .error, observer.description, (name?.rawValue ?? "<All>"))

				return
			}

			let token = NotificationCenter.default.addObserver(forName: name, object: object, queue: queue, using: block)

			let observation = Observation(observer: observer, name: name, token: token)

			observations.append(observation)
		}
	} // add()

	///
	/// Remove a notification observer.
	///
	/// - Parameter observer: The observer of the notification.
	/// - Parameter name: The name of the notification.
	///
	public func remove(observer: Observer, forName name: Name?)
	{
		observationsQueue.sync {
			guard let index = observations.firstIndex(where: { (observation) in
				(	observation.observer 	=== 	observer &&
					observation.name 		== 		name)
			}) /* guard */ else {
				os_log("'%{public}@' does not exist as an observer of '%{public}@'.",
					   log: Logging.Subsystem.general, type: .error, observer.description, (name?.rawValue ?? "<All>"))

				return
			}

			let observation = observations.remove(at: index)

			NotificationCenter.default.removeObserver(observation.token)
		}
	} // remove()
}
