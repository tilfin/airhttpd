package com.tilfin.airthttpd.services {
	import com.tilfin.airthttpd.server.HttpRequest;
	import com.tilfin.airthttpd.server.HttpResponse;

	public interface IService {
		
		function doService(request:HttpRequest, response:HttpResponse):void
	}
}