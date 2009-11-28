package com.tilfin.airthttpd.services {
	import com.tilfin.airthttpd.rest.ResourceContainer;
	import com.tilfin.airthttpd.rest.RestController;
	import com.tilfin.airthttpd.server.HttpRequest;
	import com.tilfin.airthttpd.server.HttpResponse;
	
	import flash.filesystem.File;

	public class RestService extends FileService {

		private var _docroot:File;

		private var _controller:RestController;

		public function RestService(resourcemap:Object, docroot:File = null, config:Object = null) {
			super(docroot);

			var container:ResourceContainer = new ResourceContainer();
			container.loadMapping(resourcemap);
			_controller = new RestController(container);
			
			if (config) {
				if (config.hasOwnProperty("responseType")) {
					_controller.responseType = config["responseType"];
				}
			}

			_docroot = docroot;
		}

		override public function doService(request:HttpRequest, response:HttpResponse):void {
			if (_controller.handleService(request, response)) {
				return;
			}

			if (_docroot) {
				super.doService(request, response);
			} else {
				response.statusCode = 404; // Not Found
			}
		}

	}
}