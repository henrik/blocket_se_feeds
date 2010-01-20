# Blocket.se Feeds

Ruby CGI script that uses `mechanize` and `Builder` to provide an Atom (RSS, kind of) feed of Blocket.se searches. Blocket.se is a Swedish classifieds site.

Use it something like this (see the included .htaccess for Apache):

    http://example.com/blocket.atom/stockholm?q=fisk
    
The last part of the URL path should be identical to the Blocket.se search URL, e.g.

    http://www.blocket.se/stockholm?q=fisk

Since it seems Blocket.se actively try to block or break attempts to provide feeds of their classifieds, I'm not offering a public hosted version of this script. Set it up on your own server. If they break it, we can all patch it up again.


## Example screenshot

Example screenshot in Google Reader:

![Screenshot](http://henrik.nyh.se/uploads/blocket_se_feeds.png)


## Credits and license

By [Henrik Nyh](http://henrik.nyh.se/) under the MIT license:

>  Copyright (c) 2010 Henrik Nyh
>
>  Permission is hereby granted, free of charge, to any person obtaining a copy
>  of this software and associated documentation files (the "Software"), to deal
>  in the Software without restriction, including without limitation the rights
>  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
>  copies of the Software, and to permit persons to whom the Software is
>  furnished to do so, subject to the following conditions:
>
>  The above copyright notice and this permission notice shall be included in
>  all copies or substantial portions of the Software.
>
>  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
>  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
>  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
>  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
>  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
>  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
>  THE SOFTWARE.
