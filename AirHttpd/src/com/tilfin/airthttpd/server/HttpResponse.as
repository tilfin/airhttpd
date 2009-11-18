package com.tilfin.airthttpd.server {
	import flash.net.Socket;
	import flash.utils.ByteArray;

	/**
	 * HTTP Response
	 *  
	 * @author toshi
	 * 
	 */
	public class HttpResponse {
		
		private static const SERVER:String = "Server: AirHttpd/0.0.1";
		private static const NEWLINE:String = "\r\n";

		private static const VERSION:String = "HTTP/1.x ";

		private var _socket:Socket;

		private var _status:String = "200 OK";

		private var _contentType:String = "text/html";

		private var _body:ByteArray;

		private var _hasDone:Boolean = false;

		public function HttpResponse(socket:Socket) {
			_socket = socket;
		}

		public function set contentType(value:String):void {
			_contentType = value;
		}

		public function set status(code:int):void {
			switch (code) {
				case 200:
					_status = "200 OK";
					break;
				case 403:
					_status = "403 Forbidden";
					break;
				case 404:
					_status = "404 Not Found";
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

		public function flush():void {
			if (_hasDone)
				return;

			var header:Array = new Array();
			header.push(VERSION + _status);
			header.push(SERVER);
			header.push("Content-Type: " + _contentType);
			header.push("Content-Length: " + _body.length.toString());

			_socket.writeUTFBytes(header.join(NEWLINE));
			_socket.writeUTFBytes(NEWLINE + NEWLINE);
			_socket.writeBytes(_body);
			_socket.flush();

			_hasDone = true;
		}
	}
}