#!/usr/bin/env ruby
# coding: utf-8
require 'yaml'
require 'zlib'
require_relative 'rgss'
[
  'Data/Actors.rvdata2',
  'Data/Animations.rvdata2',
  'Data/Armors.rvdata2',
  'Data/Classes.rvdata2',
  'Data/CommonEvents.rvdata2',
  'Data/Enemies.rvdata2',
  'Data/Items.rvdata2',
  *Dir.glob('Data/Map[0-9][0-9][0-9].rvdata2'),
  'Data/MapInfos.rvdata2',
  'Data/Skills.rvdata2',
  'Data/States.rvdata2',
  'Data/System.rvdata2',
  'Data/Tilesets.rvdata2',
  'Data/Troops.rvdata2',
  'Data/Weapons.rvdata2'
].each do |rvdata2|
  data = ''
  puts "Unpacking... #{rvdata2}"
  File.open(rvdata2, 'rb') do |file|
    data = Marshal.load(file.read)
  end
  File.open('Data/'+File.basename(rvdata2,'.rvdata2')+'.yml', 'w') do |file|
    file.write(YAML.dump(data))
  end
end
data = ''
index = []
File.open('Data/Scripts.rvdata2', 'rb') do |file|
  data = Marshal.load(file.read).map do |id, name, script|
    name = '( NONAME )' if name.empty?
    index << id
    [name, '# -*- id: ' +
           "#{id} -*-\n" +
           Zlib::Inflate.inflate(script) +
           "\n# -*- END_OF_SCRIPT -*-\n\n"
    ]
  end
end
if File.exists?('Data/Scripts')
  Dir.glob('Data/Scripts/*.rb') do |file|
    File::delete(file)
  end
else
  Dir.mkdir('Data/Scripts')
end
data.each do |name, script|
  File.open('Data/Scripts/'+name+'.rb', 'ab') do |file|
    file.write(script)
  end
end
File.open('Data/Scripts.yml', 'wb') do |file|
  file.write(YAML.dump(index))
end
