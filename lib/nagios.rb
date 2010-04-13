class Nagios

  class << self
    def status
      doc = open(NAGIOS_URL, :http_basic_authentication => [NAGIOS_USER, NAGIOS_PW]) { |f| Hpricot(f) }

      totals, problems = doc.search("table.serviceTotals")
      {
        :system_count => totals.at("td.serviceTotalsOK").inner_html.to_i,
        :problem_count => (problems.at("td.serviceTotalsPROBLEMS") || problems.at("td.serviceTotals")).inner_html.to_i,
        :problems => doc.
                      search("table.status > tr")[1..-1].
                      select { |problem| problem.search("> td").size > 1 }.
                      map { |problem| "#{problem.search("> td")[1].inner_text.strip} (#{problem.search("> td")[0].inner_text.strip})" }
      }
    end
  end
end
