package com.tilfin.airthttpd.server {
	import com.tilfin.airthttpd.utils.ParamUtil;
	
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

		/**
		 * contructor.
		 *  
		 * @param request first line of request
		 * @param headers request header map
		 * 
		 */
		public function HttpRequest(request:String, headers:Object):void {
			var req:Array = request.split(" ", 3);
			if (req.length != 3 || String(req[0]).length < 3) {
				throw new ArgumentError();
			}
			
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

		/**
		 * @return first line of request header  
		 * 
		 */
		public function get firstLine():String {
			return _firstLine;
		}
		
		/**
		 * @return method 
		 * 
		 */
		public function get method():String {
			return _method;
		}

		/**
		 * @return requesting path 
		 * 
		 */
		public function get path():String {
			return _path;
		}

		/**
		 * @return HTTP version 
		 * 
		 */
		public function get version():String {
			return _version;
		}
		
		/**
		 * @return query string 
		 * 
		 */
		public function get queryString():String {
			return _queryStr;
		}
		
		/**
		 * @return map AS plain object parsed from query string  
		 * 
		 */
		public function get queryParams():Object {
			if (!_queryStr)
				return null;
			
			return ParamUtil.deserialize(_queryStr);
		}

		/**
		 * @return header map 
		 * 
		 */
		public function get headers():Object {
			return _headers;
		}

		/**
		 * @return destination host name 
		 * 
		 */
		public function get host():String {
			return _headers.host;
		}

		public function get acceptLanguage():String {
			return _headers["accept-language"];
		}

		/**
		 * @return connection header value 
		 * 
		 */
		public function get connection():String {
			if (_headers.hasOwnProperty("connection")) {
				return String(_headers["connection"]).toLowerCase();
			} else {
				return null;
			}
		}

		/**
		 * @return referer URL 
		 * 
		 */
		public function get referer():String {
			return _headers.referer;
		}

		/**
		 * @return cookie 
		 * 
		 */
		public function get cookie():String {
			return _headers.cookie;
		}

		/**
		 * @return user agent of web client 
		 * 
		 */
		public function get userAgent():String {
			return _headers["user-agent"];
		}

		public function get contentLength():Number {
			return parseInt(_headers["content-length"], 10);
		}
		
		/**
		 * @return content type of entity 
		 * 
		 */
		public function get contentType():String {
			return _headers["content-type"];
		}
		
		/**
		 * @return authrozation header 
		 * 
		 */
		public function get authorization():String {
			return _headers["authorization"];
		}

		/**
		 * @return entity 
		 * 
		 */
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