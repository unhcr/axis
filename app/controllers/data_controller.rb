class DataController < ApplicationController
  before_filter :authenticate_user!
end


