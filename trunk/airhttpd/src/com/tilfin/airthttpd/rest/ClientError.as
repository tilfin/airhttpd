package com.tilfin.airthttpd.rest {

	public class ClientError extends Error {
		
		private var _statusCode:int;
		
		public function ClientError(statusCode:int, message:String = "") {
			super(message);
			
			_statusCode = statusCode;
		}
		
		public function get statusCode():int {
			return _statusCode;
		}

		public static function badRequest(message:String = ""):void {
			throw new ClientError(400, message);
		}

		public static function forbidden(message:String = ""):void {
			throw new ClientError(403, message);
		}

		public static function notFound(message:String = ""):void {
			throw new ClientError(404, message);
		}
		
		public static function conflict(message:String = ""):void {
			throw new ClientError(409, message);
		}
		
		public static function gone(message:String = ""):void {
			throw new ClientError(410, message);
		}
	}
}