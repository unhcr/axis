module SummarizeJob
  @queue = :summarize

  def self.perform(token, args)
    db_config = "#{Rails.root}/config/database.yml"

    cmd = "python #{Rails.root}/script/python/summarizer/summarize.py \
        -a #{Shellwords.escape(args.to_json)} \
        -e #{Rails.env} \
        -d #{db_config}"

    summary = `#{cmd}`

    Redis.current.set token, summary
  end
end
