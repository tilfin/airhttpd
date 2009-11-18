package com.tilfin.airthttpd.services {
	import com.tilfin.airthttpd.server.HttpRequest;
	import com.tilfin.airthttpd.server.HttpResponse;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	/**
	 * Local File output service.
	 *
	 * @author toshi
	 *
	 */
	public class FileService implements IService {
		
		private static const MIME_TYPE_MAP:Object = {
			"htm" : "text/html",
			"html": "text/html",
			"xml": "text/xml",
			"css" : "text/css",
			"js" : "text/javascirpt",
			"gif" : "image/gif",
			"jpg" : "image/jpeg",
			"jpeg": "image/jpeg",
			"png" : "image/png",
			"txt" : "text/plain",
			"swf" : "application/x-shockwave-flash",
			"pdf" : "application/pdf",
			"rdf" : "application/rdf+xml"
		}

		private var _docroot:String;
		
		private var _logCallback:Function

		/**
		 * Contructor
		 *
		 * @param docroot document root path
		 *
		 */
		public function FileService(docroot:File, logCallback:Function) {
			_docroot = docroot.url;
			_logCallback = logCallback;
		}

		/**
		 * @inheritDoc
		 */
		public function doService(request:HttpRequest, response:HttpResponse):void {
			var file:File = new File(_docroot + request.path);
			
			if (file.isDirectory) {
				// default index file.
				file = new File(file.url + "/index.html");
			}
			
			if (!file.exists) {
				response.status = 404;
				response.body = "<html><body><h1>Not Found</h1></body></html>";
				_logCallback(request.method + " " + request.path + "\tNot Found");
				return;
			}
			
			var ext:String = file.extension.toLowerCase();
			response.contentType = MIME_TYPE_MAP[ext];
			
			var data:ByteArray = new ByteArray();
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.READ);
			fs.readBytes(data);
			fs.close();
			
			response.body = data;
			_logCallback(request.method + " " + request.path + "\tOK");
		}

	}
}