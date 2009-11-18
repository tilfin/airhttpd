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

		public function HttpListener() {
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

		private function onHandle(event:HandleEvent):void {
			_service.doService(event.request, event.response);
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

	}
}