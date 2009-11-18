package com.tilfin.airthttpd.events {
	import com.tilfin.airthttpd.server.HttpRequest;
	import com.tilfin.airthttpd.server.HttpResponse;
	
	import flash.events.Event;

	/**
	 * Handle Event dispatched when http request receives.
	 *  
	 * @author toshi
	 * 
	 */
	public class HandleEvent extends Event {

		public static const HANDLE:String = "handle";

		public function HandleEvent() {
			super(HANDLE);
		}

		public var request:HttpRequest;

		public var response:HttpResponse;

	}
}