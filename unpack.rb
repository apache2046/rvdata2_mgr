#!/usr/bin/env ruby
# coding: utf-8
require 'yaml'
require 'zlib'
require_relative 'rgss'

def load_rvdata2(file)
  Marshal.load(File.open(file, 'rb'))
end

def save_yaml(file, data)
  File.open(file, 'w') do |f|
    f.write(YAML.dump(data))
  end
end

DATA_NAMES = %w{
  Actors    Animations    Armors
  Classes   CommonEvents  Enemies
  Items     MapInfos      Skills
  States    System        Tilesets
  Troops    Weapons
}
DATA_NAMES.each do |name|
  rvdata_filename = 'Data/' + name + '.rvdata2'
  yaml_filename =   'Data/' + name + '.yml'

  puts "Unpacking... #{name}"
  data = load_rvdata2(rvdata_filename)
  save_yaml(yaml_filename, data)
end

# Map
Dir.glob('Data/Map[0-9][0-9][0-9].rvdata2').each do |rvdata_filename|
  yaml_filename = 'Data/' + File.basename(rvdata_filename,'.rb') + '.yml'

  puts "Unpacking... #{rvdata_filename}"
  data = load_rvdata2(rvdata_filename)
  save_yaml(yaml_filename, data)
end

def cleanup_scripts_rb
  if File.exists?('Data/Scripts')
    Dir.glob('Data/Scripts/*.rb') do |file|
      File::delete(file)
    end
  else
    Dir.mkdir('Data/Scripts')
  end
end

# Scripts
def unpack_scripts
  data = load_rvdata2('Data/Scripts.rvdata2')

  indexes = []
  data.each do |id, name, script|
    name = '( NONAME )' if name.empty?
    #puts "Unpacking... Scripts/#{name}"
    indexes << id

    File.open('Data/Scripts/'+name+'.rb', 'wb') do |f|
      f.write "# -*- id: #{id} -*-\n" +
        Zlib::Inflate.inflate(script) +
        "\n# -*- END_OF_SCRIPT -*-\n\n"
    end
  end

  File.open('Data/Scripts.yml', 'wb') do |file|
    file.write(YAML.dump(indexes))
  end
end

puts "Unpacking... Scripts"
cleanup_scripts_rb
unpack_scripts
