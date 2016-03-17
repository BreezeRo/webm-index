#!/usr/bin/env ruby
# gen_website.rb -- generate the index.html + webm data as JSON files
# (c) 2016 nilsding
# Licensed under the terms of the FreeBSD license.  See the LICENSE file in
# the repository's root for the full license text.

require 'yaml'
require 'json'
require 'erb'
require 'etc'

CONFIG = YAML.load_file File.expand_path '../config.yml', __FILE__
DATA_OUT_FILE = File.expand_path '../public/js/data.js', __FILE__
INDEX_TEMPLATE = File.expand_path '../template.erb', __FILE__
INDEX_OUT_FILE = File.expand_path '../public/index.html', __FILE__

def make_json
  obj = {
    basedir: CONFIG[:site][:webm_basedir],
    videos: [],
    index: ''
  }
  webms = Dir[File.join CONFIG[:directory], '*.webm'].sort { |a, b| a.downcase <=> b.downcase }

  puts "Processing #{webms.length} files..."
  webms.each do |webm|
    if File.exists? webm + '.ignore'
      $stdout.print 'i'
      $stdout.flush
      next
    end

    webm_obj = {
      file_name: File.basename(webm),
      data: nil,
      uploaded_by: Etc.getpwuid(File.stat(webm).uid).name
    }
    c = '.'
    if File.exists? webm + '.desc'
      webm_obj[:data] = YAML.load_file webm + '.desc'
      c = '+'
    end

    obj[:videos] << webm_obj
    $stdout.print c
    $stdout.flush
  end
  puts " done"

  obj[:index] = obj[:videos].map do |webm|
    title = webm[:file_name].sub /\.webm$/, ''
    unless webm[:data].nil?
      title = webm[:data]['title'] unless webm[:data]['title'].nil?
    end

    "<li><a href=\"#\" onclick=\"playWebMByFileName('#{ERB::Util.url_encode webm[:file_name]}', event)\">#{title}</a></li>"
  end * ''

  obj.to_json
end

File.open DATA_OUT_FILE, 'w' do |f|
  f.puts make_json
end

File.open INDEX_OUT_FILE, 'w' do |f|
  f.write ERB.new(File.read INDEX_TEMPLATE).result binding
end
