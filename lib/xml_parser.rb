class XmlParser < Mechanize::File
  attr_reader :xml
  def initialize(uri = nil, response = nil, body = nil, code = nil)
    @xml = Nokogiri::XML(body)
    super uri, response, body, code
  end
end
