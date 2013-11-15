# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131115124631) do

  create_table "budget_lines", :id => false, :force => true do |t|
    t.string   "id"
    t.string   "scenerio"
    t.string   "type"
    t.string   "cost_center"
    t.string   "implementer_code"
    t.string   "implementer_name"
    t.string   "account_code"
    t.string   "account_name"
    t.integer  "quantity"
    t.integer  "unit"
    t.string   "currency"
    t.integer  "unit_cost"
    t.integer  "local_cost"
    t.integer  "amount"
    t.text     "comment"
    t.string   "output_id"
    t.string   "problem_objective_id"
    t.string   "rights_group_id"
    t.string   "goal_id"
    t.string   "ppg_id"
    t.string   "plan_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "goals", :id => false, :force => true do |t|
    t.string   "id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "goals_ppgs", :id => false, :force => true do |t|
    t.string "goal_id", :null => false
    t.string "ppg_id",  :null => false
  end

  create_table "goals_rights_groups", :id => false, :force => true do |t|
    t.string "goal_id",         :null => false
    t.string "rights_group_id", :null => false
  end

  create_table "indicator_data", :id => false, :force => true do |t|
    t.string   "id"
    t.integer  "standard"
    t.boolean  "reversal"
    t.integer  "comp_target"
    t.integer  "yer"
    t.integer  "baseline"
    t.integer  "stored_baseline"
    t.integer  "threshold_green"
    t.integer  "threshold_red"
    t.string   "indicator_id"
    t.string   "output_id"
    t.string   "problem_objective_id"
    t.string   "rights_group_id"
    t.string   "goal_id"
    t.string   "ppg_id"
    t.string   "plan_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "indicators", :id => false, :force => true do |t|
    t.string   "id"
    t.string   "name"
    t.boolean  "is_performance"
    t.boolean  "is_gsp"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "indicators_outputs", :id => false, :force => true do |t|
    t.string "output_id",    :null => false
    t.string "indicator_id", :null => false
  end

  create_table "indicators_problem_objectives", :id => false, :force => true do |t|
    t.string "problem_objective_id", :null => false
    t.string "indicator_id",         :null => false
  end

  create_table "operations", :id => false, :force => true do |t|
    t.string   "id"
    t.string   "name"
    t.text     "years"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "outputs", :id => false, :force => true do |t|
    t.string   "id"
    t.string   "name"
    t.string   "priority"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "outputs_problem_objectives", :id => false, :force => true do |t|
    t.string "problem_objective_id", :null => false
    t.string "output_id",            :null => false
  end

  create_table "plans", :id => false, :force => true do |t|
    t.string   "id"
    t.string   "operation_name"
    t.string   "name"
    t.integer  "year"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "operation_id"
  end

  create_table "plans_ppgs", :id => false, :force => true do |t|
    t.string "plan_id", :null => false
    t.string "ppg_id",  :null => false
  end

  create_table "ppgs", :id => false, :force => true do |t|
    t.string   "id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "problem_objectives", :id => false, :force => true do |t|
    t.string   "id"
    t.string   "problem_name"
    t.string   "objective_name"
    t.boolean  "is_excluded"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "problem_objectives_rights_groups", :id => false, :force => true do |t|
    t.string "problem_objective_id", :null => false
    t.string "rights_group_id",      :null => false
  end

  create_table "rights_groups", :id => false, :force => true do |t|
    t.string   "id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "firstname"
    t.string   "lastname"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
