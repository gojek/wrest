# Caching in Wrest #

[RFC 2616's Caching section ](http://www.w3.org/Protocols/rfc2616/rfc2616-sec13.html) describes in detail how Caching is to be implemented by the clients.

A response should obey the following conditions to be considered cacheable by Wrest:

 * Only responses to GET requests are cached.
 * The response code must be 200, 203, 300, 301, 302, 304 or 307.
 * The Cache-Control headers should not have neither no-cache nor no-store flag.
 * There should not be Pragma: no-cache header. (this header is only used by HTTP 1.0 servers)
 * Either Cache-Control: max-age or the Expires headers (or both) should be set. (Cache-control: max-age always take priority over Expires header.)
 * If only Expires header is set, it should not be lesser than the response's Date header. It should also be greater than the time when the response was received by the client.
 * The date headers (Date, Expires) should be in [RFC 1123 format](http://www.ietf.org/rfc/rfc1123.txt).
 * The Vary header should not be present at all. (The Vary mechanism is used to conditionally control caching, which Wrest does not currently implement. Section 14.44 of the RFC 2616 describes the Vary tag in detail)

Whenever a GET request is sent to Wrest, it consults the Cache Store for a matching entry. If an entry is found and has not expired, it is returned back as the response without making a request to the server.

A cache entry is considered to be fresh (not expired) if:
	
 * Its freshness lifetime is greater than zero.
   * Freshness lifetime of a cache entry is its Cache-control: max-age if max-age is defined. If max-age is not defined, it would be the cache entry's Expires header-Current Time.
	(note: either max-age or Expires header is liable to be present for the cache entry since only such response's are cached at all).
	
	**AND**
	
 * Its freshness lifetime is greater than the cache entry's age.
   * Age of a cache entry is: Current Date & Time - the cached response's Date header, or the value of the Age header in the cached response, whichever is greater.

If a cache entry is available, but expired, Wrest sees if the entry can be validated. A cache entry can be validated if:

 * It has a Last-Modified header, or an ETag header, or both.
 
If a cache-entry can be validated, Wrest sends the actual GET request to the server, alongwith:

 * If-Modified-Since : <Last-Modified value of the cache entry> (if the header Last-Modified was present in the cache entry), and/or
 * If-None-Match: <ETag of the cache entry> (if ETag was present in the cache entry)

The server determines whether the response cached at the client is still valid by looking at the values of the If-Modified-Since/If-None-Match headers. It sends a 304 (Not Modified) response without a body, if the response available with the client is still valid.

Wrest, upon receiving the 304 will update the existing cache entry with the headers provided in the 304 (RFC 2616 13.5.3 Combining Headers) and return the cached response to the client.

If the server determines the cached entry at the client side is invalid, it sends a full response (usually 200 Ok), which Wrest passes to the client after updating the existing cache entry with the new response.

If the cache-entry is expired, but cannot be validated, then Wrest sends a full blown GET request to the server. The response is passed to the client after updating the existing cache entry with the new response.

#### Edge Case for HTML documents ####

	   <META HTTP-EQUIV="Pragma" CONTENT="no-cache">

Firefox respects the Pragma header in the HTML document (nsHttpResponseHead.h:NoCache). Wrest cannot since it does not parse the response body.


## A Rough note on how the browsers (Firefox and Chrome) implement caching ##

Browsers usually cache all responses including non-cacheable ones. These are for use in the browser History (Forward, Back buttons). [ [RFC 2616](http://www.ietf.org/rfc/rfc2616.txt) 13.13 History Lists]
The non-cachebility restriction is usually observed after fetching a cache entry - if the stored response was not cacheable, it is not used.

A large chunk of caching logic for Firefox 3 is in the file netwerk/protcols/http/nsHttpChannel.cpp inside its source tree.

The browsers are optimistic with respect to caching - if a response does not explicitly specify an Expiration mechanism, it uses its own heuristics to calculate an Expiry time. However Wrest is pessimistic - if a document does not specifiy an explicit cache expiration mechanism, the response is not cached at all.

The following is a rough outline that I'd written to understand how the browsers implement caching. However, they do not necessarily reflect the browsers' behaviour accurately and has been heaviliy adapted to suit Wrest.

## Firefox: nsHttpChannell::CheckCache() ##

do_fetch if method.head != cache.head
do_fetch if not (method.head = 'GET' || method.head = 'HEAD')

use_cache if Cache-Control: max-age validates. Refer cache_expired?

re_validate if:

 * Expires: header is a past date OR cache_expired?
 * the cache entry has 'must-revalidate' header.  [RFC 2616 14.9.4](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.9.4)

## doValidation ##

Add an If-Modified-Since to the request if the cache has a Last-Modified value.
Add an If-None-Match to the request if the cache had an ETag

Send Request.

If a full response is received, update cache and return the result.
If a Not-Modified received, return the cache itself.

## Do Not Store in Cache If ##

 * Original request was not (GET or HEAD)

 * Any response with a code other than given MUST NOT be cached.
  (success codes) 200,203 (cacheable redirects) 300, 301, 302, 304, 307.
  [from Mozilla: nsHttpResponseHead.cpp::MustValidate(), also we cannot support 206 (partial content)]

 * this is a response to a cache validation request: ie: the original request contained
  an 'if-modified-since' or 'if-match' (http://codesearch.google.com/codesearch/p#OAMlx_jo-ck/src/net/http/http_cache_transaction.cc&l=45)

 * has tags 'cache-control: no-cach or no-store', or 'pragma: no-cache' [HTTP 1.0]

 * does not provide any explicit expiration time. to maintain maximum semantic transparency, we only cache those responses that explicitly permit caching. [RFC 2616 13.2.2](http://www.w3.org/Protocols/rfc2616/rfc2616-sec13.html#sec13.2.2)

 * if no max-age defined AND the cache expires in its past itself: cache.expires < cache.date

 * the response has the Vary tag at all
     [TODO: implement fully.
      (http://www.subbu.org/blog/2007/12/vary-header-for-restful-applications)
      (http://devel.squid-cache.org/vary/vary-header.html) ]

	
## cache_expired? ##

Firefox: nsHttpResponseHead.cpp: ComputeCurrentAge
[Chrome: RequiresValidation in http_response_headers.cc](http://codesearch.google.com/codesearch/p?hl=en#OAMlx_jo-ck/src/net/http/http_response_headers.cc&q=RequiresValidation&exact_package=chromium&sa=N&cd=2&ct=rc)	

	freshness_time=freshness_lifetime
	if fresh <= 0
	  return true
	end

	return freshness_time <= current_age


## current_age ##

Verbatim from [Chrome's http_response_headers.cc](http://codesearch.google.com/codesearch/p?hl=en#OAMlx_jo-ck/src/net/http/http_response_headers.cc&q=RequiresValidation&exact_package=chromium&l=817)

	date_value = headers['Date'] || response_time;
	age_value=headers['Age'] || 0

	apparent_age = response_time - date_value
	corrected_received_age = max(apparent_age, age_value);
	response_delay = response_time - request_time;
	corrected_initial_age = corrected_received_age + response_delay;
	resident_time = Time.now - response_time;

	corrected_initial_age + resident_time;


## freshness_lifetime ##

This is a [link to Chrome source code](http://codesearch.google.com/codesearch/p?hl=en#OAMlx_jo-ck/src/net/http/http_response_headers.cc&q=GetFreshnessLifetime&exact_package=chromium&l=848) where freshness_lifetime is defined. 

# References #

* [RFC 2616 Section 13 : HTTP Caching protocol](http://www.w3.org/Protocols/rfc2616/rfc2616-sec13.html)
* [Mozilla HTTP Caching FAQ](http://www.mozilla.org/projects/netlib/http/http-caching-faq.html)
* [Mark Nottingham's Caching Tutorial](http://www.mnot.net/cache_docs/)
* [Redbot for analyzing HTTP headers](http://redbot.org)


### Alternate Cache Implementations ###

[Resourceful - Ruby HTTP client that does caching](https://github.com/pezra/resourceful/blob/master/lib/resourceful/response.rb#L25)

[Python Httplib2 library](http://code.google.com/p/httplib2/source/browse/python3/httplib2/__init__.py?r=c86239ee0b6271309be2374f0ebfffd4455b7fb7#237)