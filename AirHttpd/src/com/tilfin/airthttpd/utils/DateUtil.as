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