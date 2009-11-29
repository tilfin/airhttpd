package com.tilfin.airthttpd.rest {
	import com.tilfin.airthttpd.server.HttpRequest;
	import com.tilfin.airthttpd.server.HttpResponse;

	public class ResourceBase {
		
		internal var httpreq:HttpRequest;
		internal var httpres:HttpResponse;
		
		protected function get request():HttpRequest {
			return httpreq;
		}

		protected function get response():HttpResponse {
			return httpres;
		}
		
		public function index(params:Object):Object {
			throw new ClientError(405); // Method Not Allowed
		}

		public function show(id:String, params:Object):Object {
			throw new ClientError(405); // Method Not Allowed
		}

		public function create(body:Object, params:Object):Object {
			throw new ClientError(405); // Method Not Allowed
		}

		public function update(id:String, body:Object, params:Object):Object {
			throw new ClientError(405); // Method Not Allowed
		}

		public function destroy(id:String, body:Object, params:Object):Object {
			throw new ClientError(405); // Method Not Allowed
		}
	}
}