package com.tilfin.airthttpd.rest {
	import com.tilfin.airthttpd.server.HttpRequest;
	import com.tilfin.airthttpd.server.HttpResponse;
	import com.tilfin.airthttpd.utils.EntityUtil;
	import com.tilfin.airthttpd.utils.ParamUtil;

	public class RestController {

		private static const PARAM_METHOD:String = "_method";

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

			var queryParams:Object = request.queryParams;
			var method:String = request.method;
			var body:Object = null;

			// Post replace
			if (queryParams && queryParams.hasOwnProperty(PARAM_METHOD)) {
				method = queryParams[PARAM_METHOD];
				delete queryParams[PARAM_METHOD];
			}

			response.contentType = getResponseContentType();

			resource.httpreq = request;
			resource.httpres = response;

			if (method == "GET" || method == "HEAD") {
				if (id) {
					body = resource.show(id, queryParams);
				} else {
					body = resource.index(queryParams);
				}

				if (body) {
					response.statusCode = 200; // OK
				} else {
					response.statusCode = 404; // Not Found
				}

			} else if (method == "POST") {
				body = resource.create(getRequestEntity(request), queryParams);

				if (response.location) {
					response.statusCode = 201; // Created
				} else if (body) {
					response.statusCode = 200; // OK
				} else {
					response.statusCode = 204; // No Content
				}

			} else if (method == "PUT" && id) {
				body = resource.update(id, getRequestEntity(request), queryParams);

				if (body) {
					response.statusCode = 200; // OK
				} else {
					response.statusCode = 204; // No Content
				}

			} else if (method == "DELETE" && id) {
				body = resource.destroy(id, getRequestEntity(request),
					request.queryParams);

				if (body) {
					response.statusCode = 200; // OK
				} else {
					response.statusCode = 204; // No Content
				}

			} else {
				response.statusCode = 405; // Method Not Allowed
			}

			if (body) {
				response.body = EntityUtil.getEntityBody(response.contentType, body);
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
				return ParamUtil.deserialize(bodystr);

			} else if (type == "xml") {
				return EntityUtil.fromXml(bodystr);

			} else if (type == "plain") {
				return bodystr;
			}

			return null;
		}

		private function getResponseContentType():String {
			if (_responseType == "xml") {
				return "application/xml";
			} else if (_responseType == "json") {
				return "application/json";
			} else {
				return "text/plain";
			}
		}
	}
}