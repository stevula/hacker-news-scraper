require_relative '../html_file_to_string'

describe HTMLFileToString do
  describe '.read' do
    let(:path_to_support_directory) { File.expand_path '../support', __FILE__ }
    let(:text_from_file) { HTMLFileToString.read("#{path_to_support_directory}/test.html") }

    it 'removes white space from between closing and opening tags' do
      expect(text_from_file).to_not match />\s+</
    end

    it 'strips any white space from the start and end' do
      expect(text_from_file).to_not match /\A\s+/
      expect(text_from_file).to_not match /\s+\z/
    end

    it 'returns the text in file' do
      condensed_test_html_text = "<!doctype html><html><head><title>Example Domain</title></head><body><main><h1>Example Domain</h1><p class='text'>Lorem ipsum.</p></main></body></html>"
      expect(text_from_file).to eq condensed_test_html_text
    end
  end
end
