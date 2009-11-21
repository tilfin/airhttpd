package com.tilfin.airthttpd.server {
	import flash.utils.ByteArray;

	/**
	 * HTTP Request
	 *  
	 * @author toshi
	 * 
	 */
	public class HttpRequest {
		
		private var _firstLine:String;
		private var _method:String;
		private var _path:String;
		private var _version:String;

		private var _queryStr:String;
		private var _headers:Object;

		private var _bytes:ByteArray;

		public function HttpRequest(request:String, headers:Object):void {
			var req:Array = request.split(" ", 3);
			_firstLine = request;
			_method = req[0];
			_path = req[1];
			_version = req[2];
			_headers = headers;
			
			var queryStartPos:int = _path.indexOf("?");
			if (queryStartPos > -1) {
				_queryStr = _path.substr(queryStartPos + 1);
				_path = _path.substr(0, queryStartPos);
			}
		}

		public function get firstLine():String {
			return _firstLine;
		}
		
		public function get method():String {
			return _method;
		}

		public function get path():String {
			return _path;
		}

		public function get version():String {
			return _version;
		}
		
		public function get queryString():String {
			return _queryStr;
		}
		
		public function get queryParams():Object {
			if (!_queryStr)
				return null;
			
			var params:Object = new Object();
			var entries:Array = _queryStr.split("&");
			for each (var entry:String in entries) {
				var keyval:Array = entry.split("=");
				params[keyval[0]] = decodeURIComponent(keyval[1]);
			}
			return params;
		}

		public function get headers():Object {
			return _headers;
		}

		public function get host():String {
			return _headers.host;
		}

		public function get acceptLanguage():String {
			return _headers["accept-language"];
		}

		public function get connection():String {
			if (_headers.hasOwnProperty("connection")) {
				return String(_headers["connection"]).toLowerCase();
			} else {
				return null;
			}
		}

		public function get referer():String {
			return _headers.referer;
		}

		public function get cookie():String {
			return _headers.cookie;
		}

		public function get userAgent():String {
			return _headers["user-agent"];
		}

		public function get contentLength():Number {
			return parseInt(_headers["content-length"], 10);
		}
		
		public function get authorization():String {
			return _headers["authorization"];
		}

		public function get requestBody():ByteArray {
			return _bytes;
		}

		public function set requestBody(bytes:ByteArray):void {
			_bytes = bytes;
		}

		public function getHeader(key:String):String {
			return _headers[key];
		}
	}
}