class UserStrategy < ActiveRecord::Base

  set_table_name 'users_strategies'
  attr_accessible :user_id, :strategy_id, :permission

  belongs_to :shared_strategy, :class_name => 'Strategy', :foreign_key => 'strategy_id'
  belongs_to :shared_user, :class_name => 'User', :foreign_key => 'user_id'

end
