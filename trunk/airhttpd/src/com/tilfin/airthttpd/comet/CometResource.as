package com.tilfin.airthttpd.comet {
	import com.tilfin.airthttpd.events.BlockResponseSignal;
	import com.tilfin.airthttpd.rest.ResourceBase;
	
	/**
	 * Resource for Comet.
	 * 
	 * @author tilfin
	 * 
	 */
	public class CometResource extends ResourceBase {
		
		private var _provider:CometCastProvider;
		
		public function CometResource(provider:CometCastProvider) {
			super();
			
			_provider = provider;
		}
		
		override public function index(params:Object):Object {
			_provider.setCometResponse(response);
			throw new BlockResponseSignal();
		}

		override public function show(id:String, params:Object):Object {
			return _provider.messageStore[id];
		}
	}
}