package com.tilfin.air.http.server.events
{
	import com.tilfin.air.http.server.HttpRequest;
	import com.tilfin.air.http.server.HttpResponse;
	
	import flash.events.Event;
	
	public class ServiceEvent extends Event
	{
		public static const SERVICE:String = "service";
		
		public function ServiceEvent()
		{
			super(SERVICE);
		}
		
		public var request:HttpRequest;
		
		public var response:HttpResponse;

	}
}