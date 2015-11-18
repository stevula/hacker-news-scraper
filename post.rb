class Post
  attr_reader :title, :url, :points, :author, :post_id, :comments
  def initialize(nokogiri_obj)
    @document = nokogiri_obj
    get_title
    get_url
    get_points
    get_author
    get_post_id
    @comments = []
  end

  def add_comment(comment_obj)
    @comments << comment_obj
  end

  private

  def get_title
    @title = @document.css('.title a').text
  end

  def get_url
    @url = @document.css('.title a')[0].attributes["href"].value
  end

  def get_points
    @points = @document.css('.score').text.delete(" points").to_i
  end

  def get_author
    @author = @document.css('.subtext:nth-child(2) a').children.first.text
  end

  def get_post_id
    @post_id = @document.css('td center a').first.attributes["href"].value[-7..-1]
  end
end
