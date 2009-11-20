package com.tilfin.airthttpd.services {
	import com.tilfin.airthttpd.server.HttpRequest;
	import com.tilfin.airthttpd.server.HttpResponse;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import mx.utils.Base64Encoder;

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
		
		private var _basicCredentials:String = null;

		/**
		 * Contructor
		 *
		 * @param docroot document root path
		 *
		 */
		public function FileService(docroot:File) {
			_docroot = docroot.url;
		}
		
		public function setBasicCredentials(user:String, pass:String):void {
			var base64enc:Base64Encoder = new Base64Encoder();
			base64enc.encode(user + ":" + pass);
			_basicCredentials = base64enc.flush(); 
		}

		/**
		 * @inheritDoc
		 */
		public function doService(request:HttpRequest, response:HttpResponse):void {
			if (_basicCredentials) {
				var auth:String = request.authorization;
				if (!auth || auth.substr(0, 6) != "Basic " || auth.substr(6) != _basicCredentials) {
					response.statusCode = 401;
					response.setBasicAuthentication("File Auth");
					response.body = "<html><body><h1>" + response.status + "</h1></body></html>";
					return;
				}
			}
			
			var file:File = new File(_docroot + request.path);
			
			if (file.isDirectory) {
				// default index file.
				file = new File(file.url + "/index.html");
			}
			
			if (!file.exists) {
				response.statusCode = 404;
				response.body = "<html><body><h1>" + response.status + "</h1></body></html>";
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
		}

	}
}