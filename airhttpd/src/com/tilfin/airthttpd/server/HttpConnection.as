package com.tilfin.airthttpd.server {
	import com.tilfin.airthttpd.errors.SocketError;
	import com.tilfin.airthttpd.events.HandleEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	import mx.utils.StringUtil;

	[Event(type="com.tilfin.airhttpd.events.HandleEvent", name="handle")]

	[Event(type="flash.events.Event", name="close")]

	/**
	 * HTTP connection
	 * 
	 * adapted Keep-Alive.
	 *  
	 * @author tilfin
	 * 
	 */
	public class HttpConnection extends EventDispatcher {
		private static const HEADER_END:String = "\r\n\r\n";
		private static const NEWLINE:String = "\r\n";

		private var _reqbuf:ByteArray;
		private var _socket:Socket;

		private var _httpreq:HttpRequest;

		/**
		 * constructor.
		 * 
		 * @param socket
		 * 			connected socket
		 * 
		 */
		public function HttpConnection(socket:Socket) {
			_socket = socket;
			_reqbuf = new ByteArray();

			_socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
			_socket.addEventListener(Event.CLOSE, onClose);
		}
		
		public function get socket():Socket {
			return _socket;
		}
		
		private function onClose(event:Event):void {
			dispose();
			
			dispatchEvent(event);
		}

		private function onSocketData(event:ProgressEvent):void {
			_socket.readBytes(_reqbuf, _reqbuf.length, _socket.bytesAvailable);

			try {
				fetchRequestStream();
				
			} catch (socketerr:SocketError) {
				dispose();
				
			} catch (err:Error) {
				// failed to analyze HTTP Request.
				var httpres:HttpResponse = new HttpResponse(this);
				httpres.connection = "close";
				httpres.statusCode = 400;
				httpres.contentType = "text/plain";
				httpres.body = "";
				
				try {
					httpres.flush();
				} catch (err2:Error) {
					trace(err2.message);
				}

				// force to close connection.
				dispose();
			}
		}

		private function fetchRequestStream():void {
			var temp:ByteArray;

			while (_reqbuf.length > 0) {
				if (_httpreq) {
					// Body
					if (_reqbuf.length < _httpreq.contentLength)
						return;

					var bodybuf:ByteArray = new ByteArray();
					bodybuf.writeBytes(_reqbuf, 0, _httpreq.contentLength);

					temp = new ByteArray();
					temp.writeBytes(_reqbuf, _httpreq.contentLength);
					_reqbuf = temp;

					_httpreq.requestBody = bodybuf;
					bodybuf = null;

					// request with the body. 
					handleRequest(_httpreq);
					_httpreq = null;

					if (_reqbuf.length == 0)
						return;
				}

				if (_reqbuf.length > 8192) {
					// Request header size too large.
					throw new Error();
				}

				var bufstr:String = _reqbuf.toString();

				var headerEndPos:int = bufstr.indexOf(HEADER_END);
				if (headerEndPos == -1) {
					return;
				}

				_httpreq = getHttpRequest(bufstr.substr(0, headerEndPos));

				temp = new ByteArray();
				temp.writeBytes(_reqbuf, headerEndPos + 4);
				_reqbuf = temp;

				if (_httpreq.method == "GET" || !_httpreq.contentLength) {
					// request without the body.
					handleRequest(_httpreq);
					_httpreq = null;
				}
			}
		}

		private function getHttpRequest(headerStr:String):HttpRequest {
			var entries:Object = new Object();
			var lines:Array = new Array();
			
			lines = headerStr.split(NEWLINE);
			trace(lines.join("\n"));
			
			var request:String = lines.shift();

			for each (var line:String in lines) {
				var pos:int = line.indexOf(":");
				if (pos > -1) {
					var key:String = line.substr(0, pos);
					var val:String = line.substr(pos + 1);
					entries[StringUtil.trim(key).toLowerCase()] = StringUtil.trim(val);
				}
			}

			return new HttpRequest(request, entries);
		}

		private function handleRequest(httpreq:HttpRequest):void {
			var httpres:HttpResponse = new HttpResponse(this, httpreq);
			httpres.connection = httpreq.connection;

			var evt:HandleEvent = new HandleEvent();
			evt.socket = _socket;
			evt.request = httpreq;
			evt.response = httpres;

			dispatchEvent(evt);
		}

		/**
		 * destroy connection. 
		 * 
		 */
		public function dispose():void {
			_httpreq = null;
			_reqbuf = null;

			if (_socket && _socket.connected) {
				_socket.close();
			}
			_socket = null;
		}
	}
}