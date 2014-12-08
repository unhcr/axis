module VisioModel
  def init_found_at
    self.found_at = Time.now
  end

  def self.included(base)
    base.extend(ClassMethods)
    base.before_create :init_found_at
  end

  def found
    self.update_column :found_at, Time.now
  end

  module ClassMethods
    # To be overloaded for eager joining
    def loaded; self; end

    def models(join_ids = nil, page = nil, where = {})
      models = self.where(where)
      models = models.page(page) unless page.nil?
      models = join_habtm(models, join_ids) if join_ids

      models
    end

    def search_models(query, options = {})
      return [] if !query || query.empty?
      options[:page] ||= 1
      options[:per_page] ||= 6
      s = self.search(options) do
        query { string "name:#{query}" }

        highlight :name
      end
      s
    end

    private

      def join_habtm(query, join_ids)
        join_ids.each do |id_name, value|
          name = id_name.to_s.sub(/_id[s]*/, '')
          join_table = [self.table_name, name.pluralize].sort.join('_')
          table_name_singular = self.table_name.singularize
          query = query.joins(
            "inner join (select distinct(#{table_name_singular}_id) from #{join_table} where
            #{id_name.to_s.singularize} in ('#{Array(value).join("','")}')) as #{join_table}_rel
            on #{self.table_name}.id = #{join_table}_rel.#{table_name_singular}_id")
        end

        query
      end
  end


end

