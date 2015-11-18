class Comment
  attr_reader :comment_data

  def initialize(nokogiri_obj, comment_number)
    @document = nokogiri_obj
    @comment_number = comment_number
    @comment_data = {get_author => get_text}
  end

  private

  def get_author
    all_comheads = @document.css('.comhead a')
    comment = all_comheads[@comment_number * 2].children.text
  end

  def get_text
    all_comment_texts = @document.css('.c00')
    all_comment_texts[@comment_number].children.text
  end
end

