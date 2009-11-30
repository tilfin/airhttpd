package com.tilfin.airthttpd.rest {
	import com.tilfin.airthttpd.server.HttpRequest;
	import com.tilfin.airthttpd.server.HttpResponse;

	/**
	 * Abstract class for RESTful resource.
	 * 
	 * <p>To extend me, method behaviors of a resource can be defined.</p> 
	 * 
	 * @author tilfin
	 * 
	 */
	public class ResourceBase {
		
		internal var httpreq:HttpRequest;
		internal var httpres:HttpResponse;
		
		/**
		 * @return HTTP request
		 */
		protected function get request():HttpRequest {
			return httpreq;
		}

		/**
		 * @return HTTP response
		 */
		protected function get response():HttpResponse {
			return httpres;
		}
		
		/**
		 * process when the request is 'GET /<i>path</i>'. 
		 * 
		 * @param params
		 * 		entity as query pamaters
		 * @return
		 * 		entity as response body
		 * 		The status code becomes '404 Not Found' if it return null.
		 */
		public function index(params:Object):Object {
			throw new ClientError(405); // Method Not Allowed
		}

		/**
		 * process when the request is 'GET /<i>path</i>/id'. 
		 * 
		 * @param params
		 * 		entity as query pamaters
		 * @return
		 * 		entity as response body
		 * 		The status code becomes '404 Not Found' if it return null.
		 */
		public function show(id:String, params:Object):Object {
			throw new ClientError(405); // Method Not Allowed
		}

		/**
		 * process when the request is 'POST /<i>path</i>'. 
		 * 
		 * @param body
		 * 		entity as request body
		 * @return
		 * 		If this method returns the URL is creating entity, the response becomes
		 * 		 the status code '201 Created' and 'Location' header is the URL.
		 * 		The status code becomes '204 No Content' as returned entity is null,
		 *      otherwise '200 OK'.
		 */
		public function create(body:Object, params:Object):Object {
			throw new ClientError(405); // Method Not Allowed
		}

		/**
		 * process when the request is 'UPDATE /<i>path</i>/id'. 
		 * 
		 * @param id
		 * 		item ID
		 * @param body
		 * 		entity as request body
		 * @return
		 * 		The status code becomes '204 No Content' as returned entity is null,
		 *      otherwise '200 OK'.
		 */
		public function update(id:String, body:Object, params:Object):Object {
			throw new ClientError(405); // Method Not Allowed
		}

		/**
		 * process when the request is 'DELETE /<i>path</i>/id'. 
		 * 
		 * @param id
		 * 		item ID
		 * @param body
		 * 		entity as request body
		 * @return
		 * 		The status code becomes '204 No Content' as returned entity is null,
		 *      otherwise '200 OK'.
		 */
		public function destroy(id:String, body:Object, params:Object):Object {
			throw new ClientError(405); // Method Not Allowed
		}
	}
}