# The provided files will be loaded when this file executes.
# Require any additional files that have been created.
require_relative 'html_whitespace_cleaner'
require_relative 'post'
require_relative 'comment'

require 'nokogiri'

html = File.read('html-samples/hacker-news-post.html')
clean_html = HTMLWhitespaceCleaner.clean(html)
nokogiri_document = Nokogiri.parse(clean_html)

post = Post.new(nokogiri_document)

comment_1 = Comment.new(nokogiri_document, 0)
comment_2 = Comment.new(nokogiri_document, 1)
comment_3 = Comment.new(nokogiri_document, 2)
comment_4 = Comment.new(nokogiri_document, 3)

post.add_comment(comment_1)
post.add_comment(comment_2)
post.add_comment(comment_3)
post.add_comment(comment_4)

post.comments.each {|comment_obj| p comment_obj.comment_data}
