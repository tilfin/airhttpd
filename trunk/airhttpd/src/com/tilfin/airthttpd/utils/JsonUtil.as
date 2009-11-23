package com.tilfin.airthttpd.utils {

	public class JsonUtil {
		
		private static const ESCAPE_STR_PATTERN:RegExp = /("|\n|\\)/g;

		public static function generate(data:Object):String {
			if (data === null)
				return "null";

			var val:Object;
			var type:String = typeof data;
			if (type == 'number' || type == 'boolean') {
				return data.toString();

			} else if (type == 'function' || type == 'unknown') {
				return null;

			} else if (type == 'string' || data is String) {
				return '"' + data.replace(ESCAPE_STR_PATTERN, function():String {
						var char:String = arguments[1];
						return (char == "\n") ? "\\n" : '\\' + char
					}) + '"';

			} else if (data is Date) {
				return 'new Date("' + data.toString() + '")';

			} else if (data is Array) {
				var arr:Array = data as Array;
				var items:Array = [];
				for (var i:int = 0; i < arr.length; i++) {
					val = generate(arr[i]);
					if (val != null)
						items.push(val);
				}
				return "[" + items.join(",") + "]";

			} else if (data is Object) {
				var props:Object = [];
				for (var k:String in data) {
					val = generate(data[k]);
					if (val != null)
						props.push(generate(k) + ":" + val);
				}
				return "{" + props.join(",") + "}";
			}
			
			return null;
		}
	}
}