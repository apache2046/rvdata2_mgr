#!/usr/bin/env ruby
# coding: utf-8
require 'yaml'
require 'zlib'
require_relative 'rgss'
[
  'Data/Actors.yml',
  'Data/Animations.yml',
  'Data/Armors.yml',
  'Data/Classes.yml',
  'Data/CommonEvents.yml',
  'Data/Enemies.yml',
  'Data/Items.yml',
  *Dir.glob('Data/Map[0-9][0-9][0-9].yml'),
  'Data/MapInfos.yml',
  'Data/Skills.yml',
  'Data/States.yml',
  'Data/System.yml',
  'Data/Tilesets.yml',
  'Data/Troops.yml',
  'Data/Weapons.yml'
].each do |yml|
  data = ''
  data = YAML.load_file(yml)
  File.open('Data/'+File.basename(yml,'.yml')+'.rvdata2', 'wb') do |file|
    file.write(Marshal.dump(data))
  end
end
data = YAML.load_file('Data/Scripts.yml')
Dir.glob('Data/Scripts/*.rb') do |rb|
  File.open(rb, 'rb') do |file|
    file.read.gsub(/(\r\n|\r|\n)/, "\n").split("# -*- END_OF_SCRIPT -*-\n\n").map do |src|
      head, lf, script = src.partition("\n")
      id = /id: (\d+)/.match(head).to_a.at(1).to_i
      name = File.basename(rb, '.rb')
      name = '' if name == "( NONAME )"
      data[data.index(id)] = [id, name, Zlib::Deflate.deflate(script.chop)]
    end
  end
end
File.open('Data/Scripts.rvdata2', 'wb') do |file|
  file.write(Marshal.dump(data))
end
