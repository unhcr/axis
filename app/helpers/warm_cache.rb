module WarmCache
  def self.warm
    Strategy.all.each do |s|
      # Warm narratives
      Narrative.summarize s.parameter_ids
    end
  end
end
