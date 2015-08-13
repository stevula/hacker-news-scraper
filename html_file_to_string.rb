module HTMLFileToString
  def self.read(path_to_file)
    text = file_read(path_to_file)
    remove_white_space_between_tags(text).strip
  end

  private
  TAGS_WITH_WHITE_SPACE_BETWEEN = />\s+</

  def self.file_read(path_to_file)
    File.read(path_to_file)
  end

  def self.remove_white_space_between_tags(string)
    string.gsub(TAGS_WITH_WHITE_SPACE_BETWEEN, "><")
  end
end
