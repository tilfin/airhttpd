package com.tilfin.airthttpd.server {
	import com.tilfin.airthttpd.events.HandleEvent;
	import com.tilfin.airthttpd.services.IService;

	import flash.events.Event;
	import flash.events.ServerSocketConnectEvent;
	import flash.net.ServerSocket;

	/**
	 * HTTP Listening Server
	 *
	 * @author toshi
	 *
	 */
	public class HttpListener {

		private var _serverSocket:ServerSocket;

		private var _connections:Array;

		private var _service:IService;

		private var _logCallback:Function

		public function HttpListener(logCallback:Function) {
			_logCallback = logCallback;

			_serverSocket = new ServerSocket();

			_serverSocket.addEventListener(Event.CONNECT, onConnect);
			_serverSocket.addEventListener(Event.CLOSE, onClose);
		}

		public function set service(service:IService):void {
			_service = service;
		}

		public function listen(port:int):void {
			if (_serverSocket.listening) {
				return;
			}

			_connections = new Array();

			_serverSocket.bind(port);
			_serverSocket.listen();
		}

		public function shutdown():void {
			if (!_serverSocket.listening) {
				return;
			}

			onClose(null);

			_serverSocket.removeEventListener(Event.CONNECT, onConnect);
			_serverSocket.removeEventListener(Event.CLOSE, onClose);
			_serverSocket.close();
			_serverSocket = null;
			_connections = null;
		}

		private function onConnect(event:ServerSocketConnectEvent):void {
			var conn:HttpConnection = new HttpConnection(event.socket);
			conn.addEventListener(HandleEvent.HANDLE, onHandle);
			conn.addEventListener(Event.CLOSE, onConnectionClose);
			_connections.push(conn);
		}
		
		private function onClose(event:Event):void {
			for each (var conn:HttpConnection in _connections) {
				try {
					conn.dispose();
				} catch (e:*) {
				}
			}
		}

		private function onConnectionClose(e:Event):void {
			var conn:HttpConnection = e.target as HttpConnection;
			conn.removeEventListener(HandleEvent.HANDLE, onHandle);
			conn.removeEventListener(Event.CLOSE, onConnectionClose);
			conn.dispose();
			_connections.splice(_connections.indexOf(conn), 1);
		}

		private function onHandle(event:HandleEvent):void {
			var httpreq:HttpRequest = event.request;
			var httpres:HttpResponse = event.response;

			if (getMethodImplemented(httpreq.method)) {
				if ((httpreq.method == "POST" || httpreq.method == "PUT") && isNaN(httpreq.contentLength)) {
					httpres.statusCode = 411; // Length Required
				} else {
					_service.doService(httpreq, httpres);
				}
			} else {
				httpres.statusCode = 501; // Not Implemented
			}

			if (httpres.isBodyEmpty() && httpres.statusCode >= 400) {
				// set Error Document HTML
				httpres.body = getSimpleHtml(httpres.status);
			}

			_logCallback(httpreq.firstLine + " - " + httpres.status);
		}

		private function getMethodImplemented(method:String):Boolean {
			switch (method) {
				case "GET":
				case "HEAD":
				case "POST":
				case "PUT":
				case "DELETE":
					return true;
				default:
					return false;
			}
		}

		private function getSimpleHtml(status:String):String {
			return "<html><body><h1>" + status + "</h1></body></html>";
		}

	}
}