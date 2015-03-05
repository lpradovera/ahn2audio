require 'yaml'

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
    tempfile = File.join(destination, 'temp.aiff')

    generate_list.each_pair do |key, val|
      destfile = File.join(destination, "#{key}.wav")
      `say -v #{@voice} "#{val}" -o #{tempfile}`
      `sox #{tempfile} #{@sox_opts} #{destfile}`
      p "#{destfile} created"
    end
  end

  def flatten_hash(my_hash, parent=[])
    my_hash.flat_map do |key, value|
      case value
        when Hash then flatten_hash( value, parent+[key] )
        else [(parent+[key]).join('_'), value]
      end
    end
  end

  def generate_list
    result = {}
    flatten_hash(@audio[@root_element]).each_slice(2) do |a, b|
      result[a.gsub('_text', '')] = b
    end
    result
  end
end
