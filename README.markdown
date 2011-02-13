# Blocket.se Feeds

Ruby script that uses `mechanize` and `Builder` to provide an Atom (RSS, kind of) feed of Blocket.se search results. Blocket.se is a Swedish classifieds site.

Use it something like this (Sinatra app suitable for [Heroku](http://heroku.com)):

    http://example.com/stockholm?q=fisk

Or this (CGI script, see the included `.htaccess` for Apache):

    http://example.com/blocket.atom/stockholm?q=fisk

The last part of the URL path should be identical to the Blocket.se search URL, e.g.

    http://www.blocket.se/stockholm?q=fisk

Blocket.se seem to actively try to block or break attempts to provide feeds of their classifieds.
There is a hosted version of this script on <http://blocket.heroku.com>, but you may want to set it up on your own server if they block it.


## Example screenshot

Example screenshot in Safari:

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
