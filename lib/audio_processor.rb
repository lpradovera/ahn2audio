require 'yaml'
require 'fileutils'

class AudioProcessor
  attr_accessor :audio

  def initialize(yaml_file, root_element = 'en', voice='Victoria', sox_opts="-r 8000 -c1")
    @audio = YAML.load_file(ARGV[0])
    @root_element = root_element
    @voice = voice
    @sox_opts = sox_opts
  end

  def run
    destination = File.expand_path(File.join(File.dirname(__FILE__), "../tmp"))

    add_audio @root_element, @audio, destination

    new_locale = @audio.to_yaml line_width: 1_000_000
    puts new_locale
    File.open(File.join(destination, 'en.yml'), 'w') {|f| f.write new_locale }
  end

private

  def add_audio(key, node, path)
    if node.has_key?('text')
      val = node['text']
      tempfile = path + '.aiff'
      destfile = path + '.wav'
      puts "Generating #{destfile} with content #{val}"
      FileUtils.mkdir_p File.dirname(tempfile)
      `say -v #{@voice} "#{val}" -o #{tempfile}`
      `sox #{tempfile} #{@sox_opts} #{destfile} && rm #{tempfile}`
      puts "#{destfile} created\n\n"
      node['audio'] = destfile
      return
    end
    node.each_pair { |key, node| add_audio key, node, File.join(path, key) }
  end
end
