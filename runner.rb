# The provided files will be loaded when this file executes.
# Require any additional files that have been created.
require_relative 'html_whitespace_cleaner'
require_relative 'post'
require_relative 'comment'

require 'nokogiri'
require 'open-uri'

html = open(ARGV[0])

nokogiri_document = Nokogiri.parse(html)

post = Post.new(nokogiri_document)

number_of_comments = nokogiri_document.css('.default .comhead a:first-child').length

number_of_comments.times do |i|
  post.add_comment(Comment.new(nokogiri_document, i))
end

post.comments.each {|comment_obj| puts comment_obj.comment_data}

