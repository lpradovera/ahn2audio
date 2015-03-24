require 'yaml'

class AudioProcessor
  attr_accessor :audio

  def initialize(yaml_file, root_element = 'en', voice='Victoria', sox_opts="-r 8000 -c1")
    @audio = YAML.load_file(ARGV[0])
    @new_audio = Marshal.load(Marshal.dump(@audio))
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
      puts "#{destfile} created"
    end
    puts @new_audio.to_yaml
    File.open(File.join(destination, 'en.yml'), 'w') {|f| f.write @new_audio.to_yaml }
  end

  def flatten_hash(my_hash, parent=[])
    my_hash.flat_map do |key, value|
      case value
        when Hash then flatten_hash( value, parent+[key] )
        else
          temp = @new_audio["en"]
          parent.each do |pr|
            temp = temp[pr]
          end
          temp["audio"] = parent.join('_') + '.wav'
          [(parent+[key]).join('_'), value]
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
