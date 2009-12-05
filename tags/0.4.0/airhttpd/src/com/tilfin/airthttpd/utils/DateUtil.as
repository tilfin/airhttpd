package com.tilfin.airthttpd.utils {
	
	/**
	 * Date utility class for RFC822
	 * 
	 * @author toshi
	 */
	public class DateUtil {

		private static var monthShortNames:Array = ["Jan", "Feb", "Mar",
			"Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

		private static var dayShortNames:Array = ["Sun", "Mon", "Tue",
			"Wed", "Thu", "Fri", "Sat"];

		private static var RFC822_PATTERN:RegExp = /^([A-Z][a-z]{2}), (\d{1,2}) ([A-Z][a-z]{2}) (\d{2,4}) (\d{2}):(\d{2}):(\d{2}) ([A-Z]+)/ 

		public static function fromRFC822(str:String):Date {
			var result:Array = RFC822_PATTERN.exec(str);
			if (result == null || result.length != 9) {
				return null;
			}
			
			var day:Number = parseInt(result[2], 10);
			var month:Number = monthShortNames.indexOf(result[3]);
			var year:Number = parseInt(result[4], 10);
			var hour:Number = parseInt(result[5], 10);
			var min:Number = parseInt(result[6], 10);
			var sec:Number = parseInt(result[7], 10);
			
			switch (String(result[8])) {
				case "GMT":
				case "UTC":
					var date:Date = new Date(Date.UTC(year, month, day, hour, min, sec, 0));
					trace(date.toLocaleString());
					return date;
				default:
				return null;
			}
		}

		/**
		 * Returns a date string formatted for RFC822.
		 *
		 * @param date
		 * @return formatted string
		 *
		 * @see http://asg.web.cmu.edu/rfc/rfc822.html
		 */
		public static function toRFC822(date:Date):String {
			var arr:Array = new Array();

			arr.push(dayShortNames[date.getUTCDay()] + ",");
			arr.push(getTwoDigits(date.getUTCDate()));
			arr.push(monthShortNames[date.getUTCMonth()]);
			arr.push(date.getUTCFullYear());
			arr.push(getTwoDigits(date.getUTCHours()) + ":" + getTwoDigits(date.getUTCMinutes()) + ":" + getTwoDigits(date.getUTCSeconds()));
			arr.push("GMT");

			return arr.join(" ");
		}

		private static function getTwoDigits(number:Number):String {
			return number >= 10 ? number.toString() : "0" + number; 
		}
	}
}