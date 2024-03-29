package com.tilfin.airthttpd.server {
	import __AS3__.vec.Vector;

	import com.tilfin.airthttpd.events.BlockResponseSignal;
	import com.tilfin.airthttpd.events.HandleEvent;
	import com.tilfin.airthttpd.services.EmptyService;
	import com.tilfin.airthttpd.services.IService;
	import com.tilfin.airthttpd.utils.DateUtil;

	import flash.events.Event;
	import flash.events.ServerSocketConnectEvent;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.net.URLRequestMethod;

	import mx.logging.ILogger;
	import mx.logging.Log;

	/**
	 * HttpListener
	 *
	 * provided HTTP server function based on ServerSocket.
	 *
	 * @author toshi
	 *
	 */
	public class HttpListener {

		private static var log:ILogger = Log.getLogger("com.tilfin.airthttpd.server.HttpListener");

		private var _serverSocket:ServerSocket;

		private var _connections:Vector.<HttpConnection>;

		private var _service:IService;

		private var _logCallback:Function

		/**
		 * constructor.
		 *
		 * @param logCallback
		 *    spcified logging function.
		 *		function(msg:String):void {
		 * 			trace(msg);
		 *		}
		 *
		 */
		public function HttpListener(logCallback:Function) {
			_logCallback = logCallback;

			_service = new EmptyService();

			_serverSocket = new ServerSocket();

			_serverSocket.addEventListener(Event.CONNECT, onConnect);
			_serverSocket.addEventListener(Event.CLOSE, onClose);
		}

		/**
		 * @param service
		 * 		applying to HTTP service.
		 */
		public function set service(service:IService):void {
			_service = service;
		}

		/**
		 * start listening server on port.
		 *
		 * @param port
		 * 		HTTP port number
		 *
		 */
		public function listen(port:int):void {
			if (_serverSocket.listening) {
				return;
			}

			_connections = new Vector.<HttpConnection>();

			_serverSocket.bind(port);
			_serverSocket.listen();
		}

		/**
		 * stop server.
		 *
		 */
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

			if (httpreq.version != "HTTP/1.1" && httpreq.version != "HTTP/1.0") {
				httpres.statusCode = 505; // HTTP Version Not Supported
				exitHandling(event.socket, httpres);
				return;
			}

			if (getMethodImplemented(httpreq.method)) {
				if ((httpreq.method == URLRequestMethod.POST || httpreq.method == URLRequestMethod.PUT) && isNaN(httpreq.contentLength)) {
					httpres.statusCode = 411; // Length Required
					exitHandling(event.socket, httpres);
					return;
				}
			} else {
				httpres.statusCode = 501; // Not Implemented
				exitHandling(event.socket, httpres);
				return;
			}

			try {
				httpres.exitHandlingCallback = exitHandling;
				_service.doService(httpreq, httpres);
			} catch (signal:BlockResponseSignal) {
				return;
			} catch (error:Error) {
				httpres.statusCode = 500; // Internal Server Error
				log.error("(500 Internal Server Error) " + error.message);
			}

			exitHandling(event.socket, httpres);
		}

		private function exitHandling(socket:Socket, httpres:HttpResponse):void {
			if (httpres.isBodyEmpty() && httpres.statusCode >= 400) {
				// set Error Document HTML
				httpres.contentType = "text/html";
				httpres.body = getSimpleHtml(httpres.status);
			}

			try {
				httpres.flush();
				putAccessLogInfo(socket, httpres.httpRequest, httpres);

			} catch (error:Error) {
				if (error.errorID == 2002) {
					// socket is dead.
					log.info("Socket is dead. " + error.message);
				} else {
					log.error(error.message);
				}

				httpres.httpConnection.dispose();
			}
		}

		private function getMethodImplemented(method:String):Boolean {
			switch (method) {
				case URLRequestMethod.GET:
				case URLRequestMethod.POST:
				case URLRequestMethod.PUT:
				case URLRequestMethod.DELETE:
				case URLRequestMethod.HEAD:
					return true;
				default:
					return false;
			}
		}

		private function getSimpleHtml(status:String):String {
			return "<html><body><h1>" + status + "</h1></body></html>";
		}

		private static const QUOT:String = '"';

		private function putAccessLogInfo(socket:Socket, httpreq:HttpRequest,
			httpres:HttpResponse):void {
			var logfields:Array = [socket.remoteAddress, '-', '-'];
			logfields.push("[" + DateUtil.toAccessLog() + "]");
			logfields.push(QUOT + httpreq.firstLine + QUOT);
			logfields.push(httpres.statusCode.toString());
			logfields.push(httpres.contentLength);

			var referer:String = httpreq.referer;
			if (referer) {
				logfields.push(QUOT + referer + QUOT);
			} else {
				logfields.push('"-"');
			}

			logfields.push(QUOT + httpreq.userAgent + QUOT);

			_logCallback(logfields.join(" "));
		}

	}
}