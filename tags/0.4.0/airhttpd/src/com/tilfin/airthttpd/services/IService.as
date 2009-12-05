package com.tilfin.airthttpd.services {
	import com.tilfin.airthttpd.server.HttpRequest;
	import com.tilfin.airthttpd.server.HttpResponse;

	/**
	 * HTTP process service interface. 
	 *  
	 * @author toshi
	 * 
	 */
	public interface IService {
		
		/**
		 * this method must be implemented process service.
		 * 
		 * At least, you must set response.statusCode.
		 * 
		 * @param request
		 * 		HTTP request
		 * @param response
		 * 		HTTP response
		 * 
		 */
		function doService(request:HttpRequest, response:HttpResponse):void
	}
}