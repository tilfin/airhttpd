package com.tilfin.airthttpd.rest {
	import com.tilfin.airthttpd.server.HttpRequest;
	import com.tilfin.airthttpd.server.HttpResponse;
	import com.tilfin.airthttpd.utils.JsonUtil;
	import com.tilfin.airthttpd.utils.ParamUtil;
	
	import flash.xml.XMLDocument;
	
	import mx.rpc.xml.SimpleXMLDecoder;
	import mx.rpc.xml.SimpleXMLEncoder;

	public class RestController {

		private var _mapping:Object;

		private var _rescontainer:ResourceContainer;

		private var _responseType:String = "xml";

		public function RestController(container:ResourceContainer) {
			_rescontainer = container;
		}
		
		public function set responseType(value:String):void {
			_responseType = value;
		}

		public function handleService(request:HttpRequest, response:HttpResponse):Boolean {
			var path:String = request.path;
			var id:String = null;

			// find Resource.
			var resource:ResourceBase = _rescontainer.getResource(path);
			if (resource == null) {
				// path with id
				var pos:int = path.lastIndexOf("/");
				if (pos > 0) {
					id = path.substr(pos + 1);
					path = path.substr(0, pos);
				}

				resource = _rescontainer.getResource(path);
				if (resource == null)
					return false;
			}

			try {
				handleResourceMethod(resource, id, request, response);
			} catch (clienterr:ClientError) {
				response.statusCode = clienterr.statusCode;
				trace(response.status + " " + clienterr.message);
			}

			return true;
		}

		private function handleResourceMethod(resource:ResourceBase, id:String,
			request:HttpRequest, response:HttpResponse):void {

			var body:Object = null;

			if (request.method == "GET" || request.method == "HEAD") {
				if (id) {
					body = resource.show(id, request.queryParams);
				} else {
					body = resource.index(request.queryParams);
				}

				if (body) {
					response.statusCode = 200; // OK
				} else {
					response.statusCode = 404; // Not Found
				}

			} else if (request.method == "POST") {
				body = resource.create(getRequestEntity(request), request.queryParams);

				if (response.location) {
					response.statusCode = 201; // Created
				} else if (body) {
					response.statusCode = 200; // OK
				} else {
					response.statusCode = 204; // No Content
				}

			} else if (request.method == "PUT" && id) {
				body = resource.update(id, getRequestEntity(request), request.queryParams);

				if (body) {
					response.statusCode = 200; // OK
				} else {
					response.statusCode = 204; // No Content
				}

			} else if (request.method == "DELETE" && id) {
				body = resource.destroy(id, getRequestEntity(request), request.queryParams);

				if (body) {
					response.statusCode = 200; // OK
				} else {
					response.statusCode = 204; // No Content
				}

			} else {
				response.statusCode = 405; // Method Not Allowed
			}

			if (body) {
				setResponseEntity(response, body);
			}
		}
		
		private static const CONTENT_TYPE_PATTERN:RegExp = /^([a-z0-9\-]+)\/([a-z0-9\-]+);?(.*)$/

		private function getRequestEntity(request:HttpRequest):Object {
			var ctntype:String = request.contentType;
			if (!ctntype)
				return null;

			var pos:int = ctntype.lastIndexOf("/");
			
			var result:Object = CONTENT_TYPE_PATTERN.exec(ctntype);
			var type:String = result[2];

			var bodystr:String = request.requestBody.toString();

			if (type == "x-www-form-urlencoded") {
				return ParamUtil.deserialize(bodystr);;

			} else if (type == "xml") {
				var xmldoc:XMLDocument = new XMLDocument();
				xmldoc.ignoreWhite = true;
				try {
					xmldoc.parseXML(bodystr);
				} catch (parseError:Error) {
					return false;
				}

				var xmldecoder:SimpleXMLDecoder = new SimpleXMLDecoder(false);
				return xmldecoder.decodeXML(xmldoc);
				
			} else if (type == "plain") {
				return bodystr;
			}

			return null;
		}

		private function setResponseEntity(response:HttpResponse, entity:Object):void {
			if (_responseType == "xml") {
				response.contentType = "application/xml";
				
				var xmldoc:XMLDocument = new XMLDocument();
				var xmlencoder:SimpleXMLEncoder = new SimpleXMLEncoder(xmldoc);
				xmlencoder.encodeValue(entity, new QName("root"), xmldoc);
				response.body = xmldoc.toString();
				
			} else if (_responseType == "json") {
				response.contentType = "application/json";
				response.body = JsonUtil.generate(entity);
				
			} else {
				response.contentType = "text/plain";
				response.body = entity.toString();
			}
		}
	}
}