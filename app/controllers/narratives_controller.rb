class NarrativesController < ApplicationController

  def summary

    ids = params[:ids]

    Narrative.summarize ids

  end
end
