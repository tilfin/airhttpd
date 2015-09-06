# Overview #
airhttpd is a simple HTTP server, based on Adobe AIR 2.0 (public beta). This functionality is a part of HTTP version 1.1.

## Implements ##
  * HTTP methods only GET, HEAD, POST, PUT and DELETE.
  * HTTP Authentication only Basic.
  * Keep-Alive processing.
  * partial GET.


## No Implements ##
  * Pipeline processing.
  * Chunked transfer encoding.
  * HTTPS.
  * Virtual hosting.
  * ETag header.


# How to use #

## Simple web server ##
```
  var listener:HttpListener = new HttpListener(function(message:String):void {
				logTextArea.text += message + "\n";
			};
  
  listener.service = new FileService(new File("C:\Web\root");
  listener.listen(8080);
```
