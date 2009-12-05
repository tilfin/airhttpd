package com.tilfin.airthttpd.services {
	import com.tilfin.airthttpd.server.HttpRequest;
	import com.tilfin.airthttpd.server.HttpResponse;

	/**
	 * Empty service.
	 *
	 * only to return '404 Not Found'.
	 *
	 * @author toshi
	 *
	 */
	public class EmptyService implements IService {

		/**
		 * contructor
		 */
		public function EmptyService() {
		}

		/**
		 * @inheritDoc
		 */
		public function doService(request:HttpRequest, response:HttpResponse):void {
			response.statusCode = 404;
		}

	}
}