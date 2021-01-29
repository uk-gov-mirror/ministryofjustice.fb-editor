RSpec::Matchers.define :be_generated_in do |dir|
  match do |actual|
    @file = File.expand_path(File.join(dir, actual))

    if File.exist?(@file)
      @actual_content = YAML.load_file(@file)

      @actual_content == @content
    end
  end

  chain :with_content do |content|
    @content = content
  end

  failure_message do |actual|
    message = "expected '#{actual}' to be generated in '#{dir}' with content '#{@content}'"
    message.tap do
      if File.exist?(@file)
        message << "\n Actual content: '#{@actual_content}'."
      else
        message << "\n but File did not exist in '#{dir}'"
        message << "\n Files in '#{dir}': #{Dir["#{dir}/*"]}"
      end
    end
  end
end
