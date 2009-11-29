package com.tilfin.airthttpd.rest {
	import mx.events.ResizeEvent;

	public class ResourceContainer {

		private var _container:Object;

		public function ResourceContainer() {
			_container = new Object();
		}
		
		/**
		 *
		 * @param className
		 * @return
		 *
		 */
		public function getResource(path:String):ResourceBase {
			if (_container.hasOwnProperty(path)) {
				return _container[path] as ResourceBase;
			} else {
				return null;
			}
		}
		
		public function addResource(path:String, instance:ResourceBase):void {
			_container[path] = instance;
		}
		
		public function loadMapping(map:Object):void {
			var val:* = map[path];
			var klass:Class;
			var instance:ResourceBase;
			
			for (var path:String in map) {
				val = map[path];
				if (val is Class) {
					klass = val as Class;
					instance = new klass();
				} else {
					instance = val as ResourceBase;
				}
				
				addResource(path, instance);
			}
		}

	}
}