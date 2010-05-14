package com.tilfin.airthttpd.rest {

	/**
	 * Error class to throw http client errors simplely.
	 * 
	 * @author tilfin
	 * 
	 */
	public class ClientError extends Error {
		
		private var _statusCode:int;
		
		/**
		 * constructor.
		 * 
		 * @param statusCode
		 * 		HTTP Status code
		 * @param message
		 * 		error message
		 * 
		 */
		public function ClientError(statusCode:int, message:String = "") {
			super(message);
			
			_statusCode = statusCode;
		}
		
		/**
		 * @return HTTP Status code
		 * 
		 */
		public function get statusCode():int {
			return _statusCode;
		}

		/**
		 * throwing HTTP client error 400 Bad Request.
		 * 
		 * @param message
		 * 			error message
		 */
		public static function badRequest(message:String = ""):void {
			throw new ClientError(400, message);
		}

		/**
		 * throwing HTTP client error 403 Forbidden.
		 * 
		 * @param message
		 * 			error message
		 */
		public static function forbidden(message:String = ""):void {
			throw new ClientError(403, message);
		}

		/**
		 * throwing HTTP client error 404 Not Found.
		 * 
		 * @param message
		 * 			error message
		 */
		public static function notFound(message:String = ""):void {
			throw new ClientError(404, message);
		}
		
		/**
		 * throwing HTTP client error 409 Conflict.
		 * 
		 * @param message
		 * 			error message
		 */
		public static function conflict(message:String = ""):void {
			throw new ClientError(409, message);
		}
		
		/**
		 * throwing HTTP client error 410 Gone.
		 * 
		 * @param message
		 * 			error message
		 */
		public static function gone(message:String = ""):void {
			throw new ClientError(410, message);
		}
	}
}