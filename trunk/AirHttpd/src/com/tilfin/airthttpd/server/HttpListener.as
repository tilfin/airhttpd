package com.tilfin.air.http.server {
	import com.tilfin.air.http.server.events.ServiceEvent;
	import com.tilfin.air.http.server.service.IService;

	import flash.events.Event;
	import flash.events.ServerSocketConnectEvent;
	import flash.net.ServerSocket;

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
			_connections = new Array();

			_serverSocket.bind(port);
			_serverSocket.listen();
		}

		public function shutdown():void {
			_serverSocket.close();
		}

		private function onConnect(event:ServerSocketConnectEvent):void {
			var conn:HttpConnection = new HttpConnection(event.socket);
			conn.addEventListener(ServiceEvent.SERVICE, onService);
			conn.addEventListener(Event.CLOSE, onConnectionClose);
			_connections.push(conn);
		}

		private function onService(event:ServiceEvent):void {
			_service.service(event.request, event.response);
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
			conn.dispose();
			_connections.splice(_connections.indexOf(conn), 1);
		}

	}
}