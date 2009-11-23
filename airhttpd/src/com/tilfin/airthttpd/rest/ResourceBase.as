package com.tilfin.airthttpd.rest {
	import com.tilfin.airthttpd.rest.ClientError;

	public class ResourceBase {
		
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