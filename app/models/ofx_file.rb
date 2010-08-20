require 'rubygems'
require 'ofx-parser'

class OfxFile
  def self.parse_file file
    ofx = OfxParser::OfxParser.parse(file)
  end
end