package com.tilfin.airthttpd.services {
	import com.tilfin.airthttpd.server.HttpRequest;
	import com.tilfin.airthttpd.server.HttpResponse;
	
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import mx.graphics.codec.PNGEncoder;
	import mx.utils.Base64Encoder;

	/**
	 * Local File output service.
	 *
	 * @author toshi
	 *
	 */
	public class FileService implements IService {

		private static const MIME_TYPE_MAP:Object = {
				"htm": "text/html",
				"html": "text/html",
				"txt": "text/plain",
				"xml": "text/xml",
				"xsl": "text/xml",
				"css": "text/css",
				"js": "text/javascirpt",
				"gif": "image/gif",
				"jpg": "image/jpeg",
				"jpeg": "image/jpeg",
				"png": "image/png",
				"m4a": "audio/x-m4a",
				"mp3": "audio/x-mp3",
				"mp4": "video/mp4",
				"mpg": "video/mpeg",
				"mov": "video/quicktime",
				"swf": "application/x-shockwave-flash",
				"pdf": "application/pdf",
				"rdf": "application/rdf+xml",
				"xls": "application/vnd.ms-excel",
				"ppt": "application/vnd.ms-powerpoint",
				"manifest": "text/cache-manifest"
			};

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
		 * showing the index of directroy if directory index is not set. 
		 */
		public var autoIndex:Boolean = false;

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
			var params:Object = request.queryParams;
			if (params && params.hasOwnProperty("icon")) {
				if (file.icon.bitmaps.length > 0) {
					setIcon(response, file.icon.bitmaps[0]);
					return;
				}
			}

			if (file.isDirectory) {
				if (request.path.substr(request.path.length - 1) == "/") {
					// default index file.
					var indexFile:File = findDefaultPage(file.url);
					if (indexFile == null) {
						if (autoIndex) {
							setIndexesList(response, file);
						} else {
							response.statusCode = 403; // Forbidden directory acess.	
						}
						return;
					}
					file = indexFile;
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

			setContent(request, response, file);
		}

		private function setRedirect(response:HttpResponse, location:String):void {
			response.statusCode = 301;
			response.location = location;
			response.body = '<html><head><title>' + response.status + '</title></head><body><h1>' + response.status + '</h1><p>The resource has moved <a href="' + location + '">here</a>.</p></body></html>';
		}

		private function setContent(request:HttpRequest, response:HttpResponse, file:File):void {
			var modifiedSince:Date = request.ifModifiedSince;
			if (modifiedSince) {
				var modificationDate:Date = new Date(file.modificationDate.getTime() - file.modificationDate.milliseconds);
				if (modifiedSince >= modificationDate) {
					response.statusCode = 304; // Not Modified
					response.setLastModified(modificationDate);
					return;
				} 
			}
			
			var ext:String = file.extension.toLowerCase();
			var mimeType:String = MIME_TYPE_MAP[ext];
			response.contentType = mimeType ? mimeType : 'application/octet-stream';

			var data:ByteArray = new ByteArray();
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.READ);
			
			var range:Array = request.range;
			if (range) {
				var start:int = range[0];
				var end:int = range[1];
				var rangeLen:int = end - start + 1;
				fs.position = start;
				fs.readBytes(data, 0, rangeLen);
				
				response.statusCode = (rangeLen < file.size) ? 206 : 200; 
				response.setContentRange(start, end, file.size);
			} else {
				fs.readBytes(data);
			}
			
			fs.close();

			response.body = data;
			
			response.addHeader("Accept-Ranges", "bytes");
			response.setLastModified(file.modificationDate);
		}

		private function setIcon(response:HttpResponse, bmpdata:BitmapData):void {
			response.contentType = MIME_TYPE_MAP["png"];
			response.body = new PNGEncoder().encode(bmpdata);
		}
		
		private function setIndexesList(response:HttpResponse, dir:File):void {
			var html:String = '<html><head><meta name="viewport" content="width=device-width; initial-scale=1.0;">'
									+ '<style type="text/css">img{border:none;vertical-align:middle}</style></head><body><h1>'
									+ dir.name + '</h1><p><a href="../">../ move to parent folder</a></p><table>';
			
			for each (var file:File in dir.getDirectoryListing()) {
				html += '<tr><td><a href="' + file.name + '"><img src="' + file.name + '?icon=get' + ''
					 + '"/>' + file.name + '</a></td></tr>';
			}
			
			html += '</table></body></html>';
			
			response.statusCode = 200;
			response.contentType = "text/html;charset=utf8";
			response.body = html;
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