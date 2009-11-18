package com.tilfin.air.http.server.service {
	import com.tilfin.air.http.server.HttpRequest;
	import com.tilfin.air.http.server.HttpResponse;

	public interface IService {
		
		function service(request:HttpRequest, response:HttpResponse):void
	}
}