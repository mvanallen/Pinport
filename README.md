Pinport
=======

Overview
--------

Pinport migrates [Google Reader](https://www.google.com/reader) items (exported via [Google Takeout](https://www.google.com/takeout/)) to [Pinboard](https://pinboard.in/).

Main features:

* import of Google Reader .json exports
* configurable inclusion or removal of existing Reader item tags
* additional custom tags
* can automatically resolve FeedBurner redirects
* immediate upload to your Pinboard account

Requirements:

* MacOS X 10.7+ (due to ARC & Storyboards)

Uses:

* ARC
* Storyboards

Status: *Alpha*


FAQ
---

### So, do you have anything to share with the group?

Actually I do, so here goes:

I recently bought a [Pinboard](https://pinboard.in/) account and found that it took me less than 15 minutes to utterly fall in love with the service. It's fast, it's simple yet powerful and generally rather awesome, especially when integrated into practically everything using [IFTTT](https://ifttt.com). Also it doesn't want me to share everything I do on Facebook all the time. I've been searching for exactly that for years now, so I may be a bit enthusiastic about it.

As you may know, Google has decided to [discontinue Reader](http://googleblog.blogspot.com/2013/03/a-second-spring-of-cleaning.html) (..don't get me started on that..), which means that I had to find a new home for all the starred items I have - which are plenty b/c I've been using GReader daily for several years now as my main means of sifting through the daily stream of tech news while commuting.

I am a bit of a neat freak, so I'd rather do data migration myself instead of uploading first and sift through the data later. So I did.


### Why should I use this when Pinboard already has a convenient 'Import' functionality?

Two reasons:

First, Pinboard's import crapped out on me when I tried it on Google Takeout files.

Second, Pinport allows more control over how your imported items are added & tagged. Also, the automatic resolution of FeedBurner URLs is a big plus as I do not trust Google anymore to not suddenly shut down the service.

Bonus reason: it was a fun weekend project.


### The UI is lacking 'teh cool'!

I know.


### ‚Pinport‘? Really?

Yah, really. ‚Pinboard Import‘,.. get it? I am aware that it’s a *really* bad pun.


Credits
-------

* Icon created by [The Girl Tyler](http://www.thegirltyler.com) (Licence: [Free for non-commercial use.](http://www.iconarchive.com/show/brand-camp-icons-by-thegirltyler.html))

* [AFNetworking](https://github.com/AFNetworking/AFNetworking/) created by [Mattt Thompson](http://github.com/mattt) & [Scott Raymond](http://github.com/sco) (Licence: [MIT](https://github.com/AFNetworking/AFNetworking/blob/master/LICENSE))


Licence
-------

All sources are licenced under the MIT licence as reproduced below.

>Copyright (c) 2013 mvanallen
>
>Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
>
>The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
>
>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For brevity's sake, I only put a corresponding link into the source headers.
