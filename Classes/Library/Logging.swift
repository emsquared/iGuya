
import os.log

struct Logging
{
	struct Subsystem
	{
		static var general: OSLog =
		{
			return OSLog(subsystem: "app.unstable.frameworks.iGuya", category: "General")
		}()

//		static var performance: OSLog =
//		{
//			return OSLog(subsystem: "app.unstable.frameworks.iGuya", category: "Performance")
//		}()
	}
}
