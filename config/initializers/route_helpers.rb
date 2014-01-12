module RouteHelpers
  def syncable_resources(*res)
    res.each do |r|
      resources(r) do
        get 'synced', on: :collection
      end
    end
  end
end

class ActionDispatch::Routing::Mapper
  include RouteHelpers
end

