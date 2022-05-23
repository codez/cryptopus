module ::Teams
  class QuerySearch < ::FilteredList
    def filter_by_query(teams)
      teams.search_with_pg(query)
    end
  end
end

