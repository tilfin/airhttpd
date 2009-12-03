package com.tilfin.airthttpd.errors {

	/**
	 * Socket Error.
	 * 
	 * @author tilfin
	 * 
	 */
	public class SocketError extends Error {
		
		public function SocketError(message:String = "", id:int = 0) {
			super(message, id);
		}

	}
}