Dourly is not done.
Here's a list of why:
* Need ... to ... speed ... this ... puppy ... up
* Redirect suggestions are working, but need to avoid recommending trivial changes (http -> https & www -> root for instance)
* Incorrect parsing by the pdf-reader gem of a PDF (including adding proximal characters to a link address and prematurely terminating a link address).  This one's interesting.
* "Soft 404"s are not accounted for.  In other words, if a site has an internal error page that doesn't code 404, dourly labels it a success.
* Aliased hyperlinks (ones in which the link text is not the address) are not supported.
* General bug-checking is in order.  One link on the Road to Code PDF (http://www.learnstreet.com/lessons/study/ruby) causes an unknown exception.