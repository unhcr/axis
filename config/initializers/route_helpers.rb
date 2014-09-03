module RouteHelpers
  def visio_resources(*res)
    res.each do |r|
      resources(r) do
        # Can no longer create by POST, but that's OK since we should never be doing that anyways
        post 'index', on: :collection
        get 'search', on: :collection
      end
    end
  end
end

class ActionDispatch::Routing::Mapper
  include RouteHelpers
end

