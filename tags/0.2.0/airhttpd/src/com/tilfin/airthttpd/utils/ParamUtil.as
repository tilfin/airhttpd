package com.tilfin.airthttpd.utils {

	/**
	 * Request Parameters Utility
	 *
	 * @author toshi
	 *
	 */
	public class ParamUtil {

		private static const PLUS_PATTERN:RegExp = /\+/g;
		
		/**
		 * parse urlencoded paramter string.
		 *
		 * @param queryStr
		 * 		Query string or request body
		 * @return parameters
		 *
		 */
		public static function deserialize(queryStr:String):Object {
			var params:Object = new Object();
			var entries:Array = queryStr.split("&");

			for each (var entry:String in entries) {
				var vals:Array = entry.split("=");
				if (vals.length == 2) {
					var value:String = String(vals[1]).replace(PLUS_PATTERN, " ");
					params[vals[0]] = decodeURIComponent(value);
				}
			}

			return params;
		}

	}
}