module SummarizeJob
  require 'open3'

  @queue = :summarize

  PROCESSING = 'processing'

  def self.perform(token, args)
    db_config = "#{Rails.root}/config/database.yml"

    summary = Redis.current.get token
    processing = Redis.current.get "#{token}_#{PROCESSING}"


    if !summary and !processing
      Redis.current.set "#{token}_#{PROCESSING}", token

      cmd = "python #{Rails.root}/script/python/summarizer/summarize.py \
          -a #{Shellwords.escape(args.to_json)} \
          -e #{Rails.env} \
          -d #{db_config}"

      summary = nil
      Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
        summary = stdout.read
      end
      Redis.current.del "#{token}_#{PROCESSING}"
    end

    Redis.current.set token, summary
    Redis.current.expire token, 1.week
  end
end
