module Searchable

  def paged(query, options = {})
    return [] if !query || query.empty?
    options[:page] ||= 1
    options[:per_page] ||= 6
    s = self.search(options) do
      query { string "name:#{query}" }

      highlight :name
    end
    s
  end
end
