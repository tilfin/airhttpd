package com.tilfin.airthttpd.services {
	import com.tilfin.airthttpd.server.HttpRequest;
	import com.tilfin.airthttpd.server.HttpResponse;
	import com.tilfin.airthttpd.utils.DateUtil;

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

		private static const MIME_TYPE_MAP:Object = {"htm": "text/html",
				"html": "text/html", "xml": "text/xml", "css": "text/css",
				"js": "text/javascirpt", "gif": "image/gif", "jpg": "image/jpeg",
				"jpeg": "image/jpeg", "png": "image/png", "txt": "text/plain",
				"swf": "application/x-shockwave-flash", "pdf": "application/pdf",
				"rdf": "application/rdf+xml"}

		private static const DIRECTORY_INDEX:Array = ["index.html"];

		private var _docroot:String;

		private var _directoryIndex:Array;

		private var _basicCredentials:String = null;

		/**
		 * Contructor
		 *
		 * @param docroot document root path
		 *
		 */
		public function FileService(docroot:File) {
			_docroot = docroot.url;
			_directoryIndex = DIRECTORY_INDEX;
		}

		/**
		 * @return
		 * 		a default pages to display when a directory is accessed.
		 */
		public function get directoryIndex():Array {
			return _directoryIndex;
		}

		/**
		 * @private
		 */
		public function set directoryIndex(value:Array):void {
			_directoryIndex = value;
		}

		/**
		 * set the credentials information for Basic authentication.
		 *
		 * @param user userid
		 * @param pass password
		 *
		 */
		public function setBasicCredentials(user:String, pass:String):void {
			var base64enc:Base64Encoder = new Base64Encoder();
			base64enc.encode(user + ":" + pass);
			_basicCredentials = base64enc.flush();
		}

		/**
		 * @inheritDoc
		 */
		public function doService(request:HttpRequest, response:HttpResponse):void {
			if (request.method != "GET" && request.method != "HEAD") {
				response.setAllowMethods("GET, HEAD");
				return;
			}

			if (_basicCredentials) {
				// check authentication.
				var auth:String = request.authorization;
				if (!auth || auth.substr(0, 6) != "Basic " || auth.substr(6) != _basicCredentials) {
					response.setBasicAuthentication("Authetication");
					return;
				}
			}

			var file:File = new File(_docroot + request.path);

			if (file.isDirectory) {
				if (request.path.substr(request.path.length - 1) == "/") {
					// default index file.
					file = findDefaultPage(file.url);
					if (file == null) {
						response.statusCode = 403; // Forbidden directory acess.
						return;
					}
				} else {
					// Moved Permanently
					setRedirect(response, "http://" + request.host + request.path + "/");
					return;
				}
			}

			if (!file.exists) {
				response.statusCode = 404; // Not Found
				return;
			}

			setContent(response, file);
		}

		private function setRedirect(response:HttpResponse, location:String):void {
			response.statusCode = 301;
			response.location = location;
			response.body = '<html><head><title>' + response.status + '</title></head><body><h1>' + response.status + '</h1><p>The resource has moved <a href="' + location + '">here</a>.</p></body></html>';
		}

		private function setContent(response:HttpResponse, file:File):void {
			var ext:String = file.extension.toLowerCase();
			response.contentType = MIME_TYPE_MAP[ext];

			var data:ByteArray = new ByteArray();
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.READ);
			fs.readBytes(data);
			fs.close();

			response.body = data;
			response.addHeader("Last-Modified", DateUtil.toRFC822(file.modificationDate));
		}

		private function findDefaultPage(dirurl:String):File {
			for each (var page:String in _directoryIndex) {
				var file:File = new File(dirurl + "/index.html");
				if (file.exists) {
					return file;
				}
			}

			return null;
		}
	}
}