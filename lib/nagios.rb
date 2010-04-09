class Nagios

  class << self
    def status
      doc = open(NAGIOS_URL, :http_basic_authentication => ["dashboard", "Sheinei3"]) { |f| Hpricot(f) }

      totals, problems = doc.search("table.serviceTotals")
      {
        :system_count => totals.at("td.serviceTotalsOK").innerHTML.to_i,
        :problem_count => problems.at("td.serviceTotals").innerHTML.to_i,
        :problems => doc.search("table.status tr")[1..-1].map { |problem| "#{problem.search("td")[0].innerHTML} (#{problem.search("td")[1].innerHTML})" }
      }
    end
  end
end
