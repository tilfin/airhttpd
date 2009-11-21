package com.tilfin.airthttpd.server {
	import com.tilfin.airthttpd.utils.DateUtil;
	
	import flash.net.Socket;
	import flash.utils.ByteArray;

	/**
	 * HTTP Response
	 *
	 * @author toshi
	 *
	 */
	public class HttpResponse {

		private static const SERVER:String = "Server: AirHttpd/0.1.0";
		private static const NEWLINE:String = "\r\n";

		private static const CONNECTION:String = "Connection";

		private static const VERSION:String = "HTTP/1.1 ";

		private var _socket:Socket;

		private var _statusCode:int = 200;
		private var _status:String = "200 OK";

		private var _contentType:String = "text/html";
		private var _connection:String;
		private var _keepalive:String;
		private var _cookies:Array;
		private var _headers:Object;

		private var _body:ByteArray;

		private var _hasDone:Boolean = false;

		public function HttpResponse(socket:Socket) {
			_socket = socket;

			_headers = new Object();
		}

		public function set connection(value:String):void {
			if (value) {
				_headers[CONNECTION] = value;
			} else {
				delete _headers[CONNECTION];
			}
		}

		public function set contentType(value:String):void {
			_contentType = value;
		}

		public function get status():String {
			return _status;
		}

		/**
		 * @return HTTP Status Code
		 */
		public function get statusCode():int {
			return _statusCode;
		}

		/**
		 * @param code
		 * 		HTTP Status Code
		 */
		public function set statusCode(code:int):void {
			_statusCode = code;

			switch (code) {
				case 200:
					_status = "200 OK";
					break;
				case 201:
					_status = "201 Created";
					break;
				case 204:
					_status = "204 No Content";
					break;
				case 301:
					_status = "301 Moved Permanently";
					break;
				case 400:
					_status = "400 Bad Request";
					break;
				case 401:
					_status = "401 Unauthorized";
					break;
				case 403:
					_status = "403 Forbidden";
					break;
				case 404:
					_status = "404 Not Found";
					break;
				case 405:
					_status = "405 Method Not Allowed";
					break;
				case 409:
					_status = "409 Conflict";
					break;
				case 410:
					_status = "410 Gone";
					break;
				case 411:
					_status = "411 Required Length";
					break;
				case 500:
					_status = "500 Internal Server Error";
					break;
				case 501:
					_status = "501 Not Implemented";
					break;
				case 502:
					_status = "502 Bad Gateway";
					break;
				case 503:
					_status = "503 Service Unavailable";
					break;
				case 504:
					_status = "504 Gateway Timeout";
					break;
				case 505:
					_status = "505 HTTP Version Not Supported";
					break;
			}
		}

		public function set body(data:*):void {
			if (data is ByteArray) {
				_body = data;
			} else {
				_body = new ByteArray();
				_body.writeUTFBytes(data);
			}
		}

		public function setBasicAuthentication(realm:String):void {
			this.statusCode = 401;
			_headers["WWW-Authenticate"] = 'Basic realm="' + realm + '"';
		}

		public function setAllowMethods(methods:*):void {
			this.statusCode = 405;
			_headers["Allow"] = methods is Array ? methods.join(", ") : String(methods);
		}
		
		public function setCookies(cookies:Array):void {
			_cookies = cookies;
		}
		
		public function addHeader(name:String, value:String):void {
			_headers[name] = value;
		}

		public function isBodyEmpty():Boolean {
			return (_body == null);
		}

		/**
		 * output HTTP response.
		 *
		 * @param isHead
		 * 		specifying whether HTTP method is "HEAD" or not.
		 *
		 */
		internal function flush(isHead:Boolean = false):void {
			if (_hasDone)
				return;

			var header:Array = new Array();
			header.push(VERSION + _status);
			header.push("Date: " + DateUtil.toRFC822(new Date()));
			header.push(SERVER);

			for (var name:String in _headers) {
				header.push(name + ": " + _headers[name]);
			}
			
			for each (var cookie:String in _cookies) {
				header.push("Set-Cookie: " + cookie);
			}

			if (_body) {
				header.push("Content-Type: " + _contentType);
				header.push("Content-Length: " + _body.length.toString());
			}

			_socket.writeUTFBytes(header.join(NEWLINE));
			_socket.writeUTFBytes(NEWLINE + NEWLINE);

			if (!isHead && _body) {
				_socket.writeBytes(_body);
			}

			_socket.flush();

			_hasDone = true;
		}
	}
}