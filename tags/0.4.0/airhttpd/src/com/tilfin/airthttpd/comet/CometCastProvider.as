package com.tilfin.airthttpd.comet {
	import com.tilfin.airthttpd.server.HttpResponse;
	import com.tilfin.airthttpd.utils.EntityUtil;
	import com.tilfin.airthttpd.utils.JsonUtil;

	/**
	 * This class represents one Comet cast service.
	 * 
	 * <pre>
	 * var provider:CometCastProvider = new CometCastProvider();
	 * var restService:RestService = new RestService({"/tweet": tweetResource,
	 *                                                "/comet": provider.cometResource},
					                                 docroot, {"responseType": "json"});
	 * </pre>
	 * 
	 * @author tilfin
	 * 
	 */
	public class CometCastProvider {

		private var _responses:Array;
		private var _msgstore:Array;
		private var _resource:CometResource;

		/**
		 * constructor.
		 * 
		 */
		public function CometCastProvider() {
			_responses = new Array();
			_msgstore = new Array();
			_resource = new CometResource(this);
		}

		/**
		 * @return CometResource instance
		 *  
		 */
		public function get cometResource():CometResource {
			return _resource;
		}

		/**
		 * @return messages have been sent
		 *  
		 */
		public function get messageStore():Array {
			return _msgstore;
		}

		/**
		 * send message to all comet clients.
		 * 
		 * @param entity AS plain object
		 * 
		 */
		public function sendMessage(entity:Object):void {
			for each (var resp:HttpResponse in _responses) {
				if (resp.hasDone)
					continue;

				resp.statusCode = 200;
				resp.body = EntityUtil.getEntityBody(resp.contentType, entity);

				resp.completeComet();
			}

			_msgstore.push(entity);
			_responses.splice(0);
		}

		internal function setCometResponse(httpres:HttpResponse):void {
			httpres.comet = true;
			_responses.push(httpres);
		}
	}
}