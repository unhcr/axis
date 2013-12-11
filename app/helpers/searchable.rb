module Searchable

  def paged(query, options = {})
    s = self.search(options) do
      query { string "name:#{query}" }

      highlight :name
    end
    s
  end
end
