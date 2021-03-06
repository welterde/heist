# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/heist.rb'

Hoe.spec('heist') do |p|
  p.developer('James Coglan', 'jcoglan@gmail.com')
  p.extra_deps = [['oyster', '>= 0.9'], ['treetop', '>= 1.2']]
end

file "lib/builtin/library.rb" => "lib/builtin/library.scm" do |t|
  program = Heist.parse(File.read t.prerequisites.first).convert!
  File.open(t.name, 'w') { |f| f.write 'program ' + program.to_ruby.inspect }
end

task :compile => "lib/builtin/library.rb"

namespace :spec do
  task :r5rs do
    procedures = Dir['r5rs/*.html'].
                 map { |f| File.read(f) }.
                 join("\n").
                 split(/\n+/).
                 grep(/(syntax|procedure)\:/).
                 map { |s| s.gsub(/<\/?[^>]+>/, '').
                             scan(/\(([^\) ]+)/).
                             flatten.
                             first }.
                 uniq.
                 compact.
                 map { |s| s.gsub('&lt;', '<').
                             gsub('&gt;', '>') }
    
    scope = Heist::Runtime.new.top_level
    procedures.each do |proc|
      message = scope.defined?(proc) ? scope.exec(proc) : 'MISSING'
      puts "    %-32s %-48s" % [proc, message]
    end
  end
end

# vim: syntax=Ruby
