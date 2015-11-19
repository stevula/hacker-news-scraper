class Comment
  attr_reader :comment_data, :author, :text

  def initialize(nokogiri_obj, comment_number)
    @document = nokogiri_obj
    @comment_number = comment_number
    @author = get_author
    @text = get_text
  end

  private

  def get_author
    all_comheads = @document.css('.comhead a:first-child')
    comment = all_comheads[1 + @comment_number].children.text
  end

  def get_text
    all_comment_texts = @document.css('.c00')
    all_comment_texts[@comment_number].children.text
  end
end

