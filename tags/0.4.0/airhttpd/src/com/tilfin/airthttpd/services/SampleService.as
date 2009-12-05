package com.tilfin.airthttpd.services {
	import com.tilfin.airthttpd.server.HttpRequest;
	import com.tilfin.airthttpd.server.HttpResponse;

	/**
	 * Sample Service - output request information.
	 *  
	 * @author toshi
	 * 
	 */
	public class SampleService implements IService {

		/**
		 * contructor
		 */
		public function SampleService() {
		}

		/**
		 * @inheritDoc
		 */
		public function doService(request:HttpRequest, response:HttpResponse):void {
			response.body = "<html><head><title>SampleService" + "</title></head><body><table><tr><th>Method</th><td>"
				+ request.method + "</td></tr><tr><th>Path</th><td>" + request.path + "</td></tr><tr><th>Host</th><td>"
				+ request.host + "</td></tr><tr><th>User-Agent</th><td>" + request.userAgent + "</td></tr></table></body></html>";
		}

	}
}