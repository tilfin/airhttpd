package com.tilfin.air.http.server {
	import com.tilfin.air.http.server.events.ServiceEvent;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;

	import mx.utils.StringUtil;

	[Event(type="com.tilfin.air.http.server.events.ServiceEvent", name="service")]

	[Event(type="flash.events.Event", name="close")]

	public class HttpConnection extends EventDispatcher {
		private static const HEADER_END:String = "\r\n\r\n";
		private static const NEWLINE:String = "\r\n";

		private var _reqbuf:ByteArray;
		private var _socket:Socket;

		private var _httpreq:HttpRequest;

		public function HttpConnection(socket:Socket) {
			_socket = socket;
			_reqbuf = new ByteArray();

			_socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
			_socket.addEventListener(Event.CLOSE, onClose);
		}

		private function onClose(event:Event):void {
			dispatchEvent(event);
		}

		private function onSocketData(event:ProgressEvent):void {
			_socket.readBytes(_reqbuf, _reqbuf.length, _socket.bytesAvailable);
			fetchRequestStream();
		}

		private function fetchRequestStream():void {
			var temp:ByteArray;

			while (_reqbuf.length > 0) {
				if (_httpreq) {
					// Body
					if (_reqbuf.length < _httpreq.contentLength)
						return;

					var bodybuf:ByteArray = new ByteArray();
					_reqbuf.readBytes(bodybuf, 0, _httpreq.contentLength);

					temp = new ByteArray();
					temp.writeBytes(_reqbuf, _httpreq.contentLength);
					_reqbuf = temp;

					_httpreq.requestBody = bodybuf;
					bodybuf = null;

					// request with the body. 
					procRequest(_httpreq);
					_httpreq = null;

					if (_reqbuf.length == 0)
						return;
				}

				var bufstr:String = _reqbuf.toString();

				var headerEndPos:int = bufstr.indexOf(HEADER_END);
				if (headerEndPos == -1) {
					return;
				}

				_httpreq = getHttpRequest(bufstr.substr(0, headerEndPos - 1));

				temp = new ByteArray();
				temp.writeBytes(_reqbuf, headerEndPos + 4);
				_reqbuf = temp;

				if (_httpreq.method == "GET" || !_httpreq.contentLength) {
					// request without the body.
					procRequest(_httpreq);
					_httpreq = null;
				}
			}
		}

		private function getHttpRequest(headerStr:String):HttpRequest {
			var entries:Object = new Object();
			var lines:Array = new Array();

			lines = headerStr.split(NEWLINE);
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

		private function procRequest(httpreq:HttpRequest):void {
			var evt:ServiceEvent = new ServiceEvent();
			evt.request = httpreq;
			evt.response = new HttpResponse(_socket);
			dispatchEvent(evt);

			evt.response.flush();
		}

		public function dispose():void {
			_httpreq = null;
			_reqbuf = null;

			if (_socket)
				_socket.close();
			_socket = null;
		}
	}
}