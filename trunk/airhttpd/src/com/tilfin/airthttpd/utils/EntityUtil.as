package com.tilfin.airthttpd.utils {
	import flash.utils.ByteArray;
	import flash.xml.XMLDocument;
	
	import mx.rpc.xml.SimpleXMLDecoder;
	import mx.rpc.xml.SimpleXMLEncoder;


	/**
	 * Entity utility provides mutual converting xml from entity. 
	 * 
	 * @author tilfin
	 * 
	 */
	public class EntityUtil {

		/**
		 * parse XML string to ActionScript plain object.
		 *  
		 * @param xmlstr XML string
		 * @return AS plain object
		 * 
		 */		
		public static function fromXml(xmlstr:String):Object {
			var xmldoc:XMLDocument = new XMLDocument();
			xmldoc.ignoreWhite = true;
			try {
				xmldoc.parseXML(xmlstr);
			} catch (parseError:Error) {
				return null;
			}

			var xmldecoder:SimpleXMLDecoder = new SimpleXMLDecoder(false);
			return xmldecoder.decodeXML(xmldoc);
		}


		/**
		 * parses ActionScript plain object to XML string.
		 * 
		 * @param entity AS plain object
		 * @return XML string
		 * 
		 */
		public static function toXml(entity:Object):String {
			var xmldoc:XMLDocument = new XMLDocument();
			var xmlencoder:SimpleXMLEncoder = new SimpleXMLEncoder(xmldoc);
			xmlencoder.encodeValue(entity, new QName("root"), xmldoc);
			return xmldoc.toString();
		}

		/**
		 * returns content representing string adapted by content type.
		 * 
		 * @param contentType Content-Type of entity
		 * @param entity AS plain object
		 * @return content string or ByteArray
		 * 
		 */
		public static function getEntityBody(contentType:String, entity:Object):* {
			if (contentType == "application/xml") {
				return EntityUtil.toXml(entity);

			} else if (contentType == "application/json") {
				return JsonUtil.generate(entity);
			
			} else if (contentType == "application/x-amf") {
				var bytes:ByteArray = new ByteArray();
				bytes.writeObject(entity);
				return bytes; 
				
			} else {
				return entity.toString();
			}
		}
	}
}