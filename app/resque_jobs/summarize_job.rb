module SummarizeJob
  @queue = :summarize

  def self.perform(token)
    summary = `summarize #{token}`

    summary_token = token.sub Narrative::ARG_PREFIX, Narrative::SUMMARY_PREFIX

    Redis.current.set summary_token, summary
  end
end
