# From HTML to Ruby Objects

##Learning Competencies
- Install a gem
- Use the Nokogiri gem to parse CSS elements
- Map data within a given object (ie Nokogiri object) to a customized object
- Use ARGV to take in user input from the command line
- Use the OpenURI built-in module to open and read live URLs

## Summary
We've been creating custom Ruby objects that have both *state* and *behavior*.  State is the data internal to an object—think instance variables in Ruby.  Behavior is what the object can do, and we think about behavior as the methods to which an object responds.

From where do we get the data that that becomes the state of our objects?  In a [previous challenge][parsing-data-1-csv-in-csv-out-challenge], we've seen that we can create Ruby objects from the data is a CSV file.  As we continue through Dev Bootcamp, we'll be creating objects based on data in a variety of formats:  a simple text file, JSON, a database, etc.

In this challenge, we're going to use HTML as a data source.  We'll take a webpage and parse the markup into Ruby objects.  Extracting information from websites as we'll be doing is known as [web scraping][]. 

We're going to write a web scraper to grab information from [Hacker News][].  We'll translate data from Hacker News comment threads (see [example][HN Comment Thread]) into Ruby objects.  Given the technical challenges that we'll encounter, it will be easy for us to lose focus on our main goal: building custom Ruby objects based on pre-existing data. 


### The Nokogiri Gem
We won't be building an HTML parser ourselves.  Instead, we'll rely on the [Nokogiri][] gem.  It's likely we've never used Nokogiri, and one of the technical challenges we'll face is simply learning how to use this library.  

It might feel like Nokogiri is the focus of this challenge, but it's not.  Nokogiri is a tool to help us get from HTML to our own custom Ruby objects.  We'll be passing HTML to Nokogiri, and it will translate that HTML into its own custom Nokogiri Ruby objects.  We'll take those Nokogiri Ruby objects and convert them into our objects.


## Releases
### Pre-release:  Install the Nokogiri Gem
```bash
$ gem list nokogiri

*** LOCAL GEMS ***

nokogiri (1.6.6.2, 1.6.5, 1.6.0)
```
*Figure 1*.  Checking to see which, if any, versions of Nokogiri are installed.

Before we begin with this challenge we need to have the Nokogiri gem installed.  It should be installed on the Dev Bootcamp workstations.  If we're working on a personal machine, we can check to see which, if any, versions of Nokogiri are installed (see Figure 1).  If any versions of Nokogiri are installed, they will be listed under the local gems heading.

```
$ gem install nokogiri
```
*Figure 2*.  Installing Nokogiri from the command line.

If no versions of Nokogiri are installed, we'll need to install one (see Figure 2).  Unfortunately, installing Nokogiri does not always go smoothly.  If we run into issues, we should begin troubleshooting by referencing Nokogiri's [installation instructions][Nokogiri installation].  If we still have issues, we should seek help from an instructor.


### Release 0:  Explore Nokogiri
Before we begin working with the Hacker News markup, let's first build a little familiarity with Nokogiri.  We'll use Nokogiri to parse the HMTL in the file `html-samples/example.html` into Nokogiri Ruby objects and then explore those objects a bit.

![HTML Tree](readme-assets/html-tree.png)

*Figure 3*. Tree depicting the `<body>` tag in `html-samples/example.html`.

If we look at the file `html-samples/example.html`, we can see that it's a small, simple HTML document.  Let's take a look at the `<body>` tag and the tags that are nested within it.  The `<body>` tag has one child, the `<main>` tag.  And the main tag has three children of its own:  a heading and two paragraphs.  We can think of this as a tree structure (see Figure 3).

When Nokogiri parses HTML, it returns a model of that HTML.  It returns one object, but the object has child objects, and these children have child objects of their own, etc.  When we parse `html-samples/example.html`, we'll get one object to represent the document.  It will have a child node named `'html'` that has a child node named `'body'` that has a child node named `'main'` that has child nodes named `'h1'`, `'p'`, and `'p'`.  It's the same tree structure we saw in Figure 3.

```ruby
require 'nokogiri'
# => true
load 'html_file_to_string.rb'
# => true
string_of_html = HTMLFileToString.read('html-samples/example.html')
# => "<!doctype html><html><head> ... </html>"
nokogiri_document = Nokogiri.parse(string_of_html)
# => #<Nokogiri::HTML::Document:0x3fe7de194e38 name="document" children=[ ... ]>
html_node = nokogiri_document.children.last
# => #<Nokogiri::XML::Element:0x3fe7de1948c0 name="html" children=[ ... ]>
body_node = html_node.children.last
# => => #<Nokogiri::XML::Element:0x3fe7ddda8f90 name="body" children=[ ... ]>
main_node = body_node.children.first
# => => #<Nokogiri::XML::Element:0x3fe7ddda8db0 name="main" children=[ ... ]>
names_of_main_nodes_children = main_node.children.map(&:name)
# => ["h1", "p", "p"]
```
*Figure 4*.  Using Nokogiri to traverse the HTML tree structure.

Let's open up IRB and use Nokogiri to parse our HTML example file; follow the commands displayed in Figure 4.  The first thing we need to do is require the Nokogiri gem.  Now, when we ask Nokogiri to parse HTML for us, one type of argument we can pass is a string.  We're loading and then using a custom object, `HTMLFileToString` to read in a file and convert it into a scrubbed string; Nokogiri will create separate nodes for whitespace characters between tags—even the newline characters—and this object will clean that up for us (see the tests in `spec/html_file_to_string_spec.rb`).

We then ask Nokogiri to parse the scrubbed string for us, and Nokogiri returns a document object to us. With this object, we can begin to traverse the tree of our HTML from the document to the node representing the `<html>` tag to that node's child, and so forth.  Do we understand how to traverse this representation of our HTML from the document object through generations of children down to specific nodes?

```ruby
paragraphs = nokogiri_document.css('p')
# => [#<Nokogiri::XML::Element:0x3fe7ddda8874 name="p" ... >, #<Nokogiri::XML::Element:0x3fe7ddda8270 name="p" ... >] 
```
*Figure 5*. Selecting all elements that match a CSS selector.

Sometimes we want to search for specific nodes, like all the nodes representing paragraph tags.  We could traverse all the nodes Nokogiri created and find them that way, but Nokogiri provides a more convenient method.  We can use the `#css` method with [CSS selectors][] to retrieve a set of all the nodes that match the selector.

In Figure 5, we select a set of all the Nokogiri objects that represent paragraph tags.  Let's grab some other elements.  Can we grab a set of all the objects with the class `text`?

We've walked through the basics of working with Nokogiri.  We'll learn some more as we work through this challenge.  If we get stuck, we can always return to IRB and/or use a debugger to explore the objects Nokogiri creates for us.  In addition, we can search for references online, such as The Bastard's Book of Ruby guide to [parsing HTML with Nokogiri][BBR Guide].


### Release 1: Modeling Posts and Comments
Before we can parse our HTML into Ruby objects, we have to design the Ruby objects.  We're going to write two classes that will represent a Hacker News comment thread:  a `Post` class and a `Comment` class.

If we take a look at a [comment thread][HN Comment Thread] on Hacker News, we'll see that users can post a link to another webpage.  And, we can gather information about the post:  the title, the URL to the other webpage, who posted the link, how many points the post has earned, etc.  We'll also find comments.  And, as with the post, we can find information on each individual comment:  the text of the comment, the username of the commenter, etc.

Test and develop a `Post` and `Comment` class to represent the data seen on Hacker News.  What state should each of them hold?  Do they need any behaviors?

**Requirements**
- At a minimum, a post should have these attributes ...
  - title: the title on Hacker News.
  - url: the URL to which the post points.
  - points: the number of points the post currently has.
  - author username: the username of the post's author.
  - item id: the post's Hacker News item ID.
- The relationship between posts and comments is such that a post has many comments and an individual comment belongs to one post.  We need to write at least two methods that control a post's behavior relating to its comments:
  - `Post#comments`: returns the post's collection of comments.
  - `Post#add_comment`: takes a `Comment` object as its input and adds it to the post's collection of comments. This only affects a post object in our Ruby program, it doesn't do anything to the Hacker News page.


### Release 2: Hacker News HTML to Post and Comment Objects
We've explored Nokogiri a bit and have designed `Post` and `Comment` classes.  Now it's time to take some Hacker News HTML and parse it into our Ruby objects.  To avoid repeatedly hitting the Hacker News servers and getting the DBC network temporarily banned, we'll start by scraping an HTML file that we've saved locally (see `html-samples/hacker-news-post.html`).  We will we move on to parsing live webpages once we're able to successfully parse the local file.

We'll need an object to parse the HTML into our post and comment objects.  Do we already have an object that should have that responsibility?  Would it make sense to design a new object to do the parsing?  Let's ensure that we follow object-oriented principles and that we understand and can explain why we're making decisions.

We'll also want to test that our parsing is working as we expect.  Given a specific set of HTML, the object that does our parsing should create a post object with specific attributes (e.g. title, url, etc.).  The post should also have a specific set of comments.

```ruby
# Assume the code in 'html-samples/hacker-news-post.html' 
# has been parsed into a Nokogiri document object 
# and stored in the variable 'nokogiri_document'.

nokogiri_document.css('.subtext > span:first-child').first.inner_text
nokogiri_document.css('.subtext > a:nth-child(3)').first.attributes['href'].value
nokogiri_document.css('.title > a').first.inner_text
nokogiri_document.css('.title > a').first['href']
```
*Figure 6*.  Pulling specific pieces of information from a Nokogiri document object.

One of the challenges in parsing the Hacker News HTML will be how to extract the information that we need.  How do we grab the username of the post's author?  The Hacker News item ID?  How do we get nodes represent all of the comments?  Figure 6 shows some examples for pulling out pieces of information that we'll need to build our objects.  What does each line return?

We'll need to figure out for ourselves how to get the rest of the information.  We should read through the source code to figure out which selectors will lead us to the information we need.

**Tips**
```ruby
first_comment = nokogiri_document.css('.default').first
first_comment.css('.comhead a:first-child')
```
*Figure 7*. Calling the `#css` method on a specific node, not the document object.

- Each comment in the HTML is wrapped in a tag with the class `default`.
- When we use the `#css` method to search the document for nodes matching a CSS selector, any match in the document is returned.  We can also call the `#css` method on a specific node, which will narrow our search to the children, grandchildren, etc. of that specific node (see Figure 7).


 





###Release 1: Objectify a live Hacker News page

#### Command line + parsing the actual Hacker News

We're going to learn two new things: the basics of parsing command-line arguments and how to fetch HTML for a website using Ruby.  We want to end up with a command-line program that works like this:

```text
$ ruby hn_scraper.rb https://news.ycombinator.com/item?id=5003980
Post title: XXXXXX
Number of comments: XXXXX
... some other statistics we might be interested in -- your choice ...
$
```
First, [read this blog post about command-line arguments in Ruby](http://alvinalexander.com/blog/post/ruby/how-read-command-line-arguments-args-script-program).  How can you use `ARGV` to get the URL passed in to your Ruby script?

Second, read about Ruby's [OpenURI](http://www.ruby-doc.org/stdlib-1.9.3/libdoc/open-uri/rdoc/OpenURI.html) module.  By requiring `'open-uri'` at the top of your Ruby program, you can use open with a URL:

```ruby
require 'open-uri'

html_file = open('http://www.ruby-doc.org/stdlib-1.9.3/libdoc/open-uri/rdoc/OpenURI.html')
puts html_file.read
```

This captures the html from that URL as a `StringIO` object, which NokoGiri accepts as an argument to `NokoGiri::HTML`.

Combine these two facts to let the user pass a URL into your program, parse the given Hacker News URL into objects, and print out some useful information for the user.


##Resources
* [Nokogiri documentation about parsing an HTML document](http://nokogiri.org/tutorials/parsing_an_html_xml_document.html)
* [Parsing HTML with Nokogiri](http://ruby.bastardsbook.com/chapters/html-parsing/)
* [CSS selectors](http://css.maxdesign.com.au/selectutorial/)
* [Command-line arguments in Ruby](http://alvinalexander.com/blog/post/ruby/how-read-command-line-arguments-args-script-program)
* [OpenURI](http://www.ruby-doc.org/stdlib-1.9.3/libdoc/open-uri/rdoc/OpenURI.html)


[BBR Guide]: http://ruby.bastardsbook.com/chapters/html-parsing/
[CSS selectors]: https://developer.mozilla.org/en-US/docs/Web/Guide/CSS/Getting_started/Selectors
[Hacker News]: http://news.ycombinator.com
[HN Comment Thread]: https://news.ycombinator.com/item?id=5003980
[Nokogiri]: https://github.com/sparklemotion/nokogiri
[Nokogiri installation]: http://www.nokogiri.org/tutorials/installing_nokogiri.html
[parsing-data-1-csv-in-csv-out-challenge]: ../../../parsing-data-1-csv-in-csv-out-challenge
[web scraping]: https://en.wikipedia.org/wiki/Web_scraping




