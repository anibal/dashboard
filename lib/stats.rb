require 'nokogiri'

class Stats

  class << self
    def status_for(id)
      stats = File.expand_path(File.join(File.dirname(__FILE__), "..", "stats", "#{id}.html"))
      return [] unless File.exist?(stats)

      doc = Nokogiri::HTML.parse(File.open(stats))
      doc.xpath(".//table/tr").first.xpath(".//td").map { |col| col.text }.map { |v| v.to_i }[-15..-1]
    end
  end
end
