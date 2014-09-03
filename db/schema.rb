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

ActiveRecord::Schema.define(:version => 20140901151919) do

  create_table "admin_configurations", :force => true do |t|
    t.integer  "startyear",                :default => 2012
    t.integer  "endyear",                  :default => 2015
    t.string   "default_reported_type",    :default => "yer"
    t.string   "default_aggregation_type", :default => "operations"
    t.integer  "default_date",             :default => 2013
    t.boolean  "default_use_local_db",     :default => true
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
  end

  create_table "budgets", :force => true do |t|
    t.string   "budget_type"
    t.string   "scenario"
    t.integer  "amount",               :default => 0
    t.string   "plan_id"
    t.string   "ppg_id"
    t.string   "goal_id"
    t.string   "output_id"
    t.string   "problem_objective_id"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.boolean  "is_deleted",           :default => false
    t.integer  "year"
    t.datetime "found_at"
    t.string   "operation_id"
    t.string   "pillar"
  end

  add_index "budgets", ["created_at"], :name => "index_budgets_on_created_at"
  add_index "budgets", ["goal_id"], :name => "index_budgets_on_goal_id"
  add_index "budgets", ["is_deleted"], :name => "index_budgets_on_is_deleted"
  add_index "budgets", ["output_id"], :name => "index_budgets_on_output_id"
  add_index "budgets", ["plan_id", "ppg_id", "goal_id", "problem_objective_id", "output_id", "scenario", "year", "budget_type"], :name => "by_uniqueness_bud", :unique => true
  add_index "budgets", ["plan_id", "ppg_id", "goal_id"], :name => "index_budgets_on_plan_id_and_ppg_id_and_goal_id"
  add_index "budgets", ["problem_objective_id"], :name => "index_budgets_on_problem_objective_id"

  create_table "countries", :force => true do |t|
    t.text     "latlng"
    t.string   "iso3"
    t.string   "iso2"
    t.string   "region"
    t.string   "subregion"
    t.text     "un_names"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "expenditures", :force => true do |t|
    t.string   "budget_type"
    t.string   "scenario"
    t.integer  "amount",               :default => 0
    t.string   "plan_id"
    t.string   "ppg_id"
    t.string   "goal_id"
    t.string   "output_id"
    t.string   "problem_objective_id"
    t.integer  "year"
    t.boolean  "is_deleted",           :default => false
    t.datetime "found_at"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.string   "operation_id"
  end

  add_index "expenditures", ["created_at"], :name => "index_expenditures_on_created_at"
  add_index "expenditures", ["goal_id"], :name => "index_expenditures_on_goal_id"
  add_index "expenditures", ["is_deleted"], :name => "index_expenditures_on_is_deleted"
  add_index "expenditures", ["output_id"], :name => "index_expenditures_on_output_id"
  add_index "expenditures", ["plan_id", "ppg_id", "goal_id", "problem_objective_id", "output_id", "scenario", "year", "budget_type"], :name => "by_uniqueness_exp", :unique => true
  add_index "expenditures", ["problem_objective_id"], :name => "index_expenditures_on_problem_objective_id"

  create_table "export_modules", :force => true do |t|
    t.text     "state"
    t.string   "title"
    t.text     "description"
    t.boolean  "include_parameter_list", :default => false
    t.boolean  "include_explaination",   :default => false
    t.text     "figure_config"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.integer  "user_id"
    t.text     "figure_type"
  end

  create_table "fetch_monitors", :force => true do |t|
    t.datetime "starttime"
    t.text     "plans"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "goals", :id => false, :force => true do |t|
    t.string   "id",                            :null => false
    t.string   "name"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "is_deleted", :default => false
    t.datetime "found_at"
  end

  add_index "goals", ["id"], :name => "index_goals_on_id", :unique => true

  create_table "goals_indicators", :id => false, :force => true do |t|
    t.string "goal_id",      :null => false
    t.string "indicator_id", :null => false
  end

  add_index "goals_indicators", ["goal_id", "indicator_id"], :name => "goals_indicators_uniq", :unique => true

  create_table "goals_operations", :id => false, :force => true do |t|
    t.string "goal_id",      :null => false
    t.string "operation_id", :null => false
  end

  add_index "goals_operations", ["goal_id", "operation_id"], :name => "goals_operations_uniq", :unique => true
  add_index "goals_operations", ["goal_id"], :name => "index_goals_operations_on_goal_id"
  add_index "goals_operations", ["operation_id"], :name => "index_goals_operations_on_operation_id"

  create_table "goals_outputs", :id => false, :force => true do |t|
    t.string "goal_id",   :null => false
    t.string "output_id", :null => false
  end

  add_index "goals_outputs", ["goal_id", "output_id"], :name => "goals_outputs_uniq", :unique => true

  create_table "goals_plans", :force => true do |t|
    t.string "goal_id", :null => false
    t.string "plan_id", :null => false
  end

  add_index "goals_plans", ["goal_id", "plan_id", "id"], :name => "goals_plans_uniq", :unique => true
  add_index "goals_plans", ["plan_id", "goal_id"], :name => "index_goals_plans_on_plan_id_and_goal_id", :unique => true

  create_table "goals_ppgs", :id => false, :force => true do |t|
    t.string "goal_id", :null => false
    t.string "ppg_id",  :null => false
  end

  add_index "goals_ppgs", ["goal_id", "ppg_id"], :name => "goals_ppgs_uniq", :unique => true

  create_table "goals_problem_objectives", :id => false, :force => true do |t|
    t.string "goal_id",              :null => false
    t.string "problem_objective_id", :null => false
  end

  add_index "goals_problem_objectives", ["goal_id", "problem_objective_id"], :name => "goals_problem_objectives_uniq", :unique => true

  create_table "goals_rights_groups", :id => false, :force => true do |t|
    t.string "goal_id",         :null => false
    t.string "rights_group_id", :null => false
  end

  add_index "goals_rights_groups", ["goal_id", "rights_group_id"], :name => "goals_rights_groups_uniq", :unique => true

  create_table "goals_strategies", :id => false, :force => true do |t|
    t.integer "strategy_id", :null => false
    t.string  "goal_id",     :null => false
  end

  create_table "goals_strategy_objectives", :id => false, :force => true do |t|
    t.integer "strategy_objective_id", :null => false
    t.string  "goal_id",               :null => false
  end

  create_table "indicator_data", :id => false, :force => true do |t|
    t.string   "id",                                      :null => false
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
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.string   "operation_id"
    t.boolean  "is_deleted",           :default => false
    t.integer  "myr"
    t.boolean  "is_performance"
    t.integer  "year"
    t.datetime "found_at"
    t.boolean  "missing_budget",       :default => false
    t.integer  "imp_target"
    t.string   "priority"
    t.boolean  "excluded",             :default => false
    t.string   "indicator_type"
  end

  add_index "indicator_data", ["created_at"], :name => "index_indicator_data_on_created_at"
  add_index "indicator_data", ["goal_id"], :name => "index_indicator_data_on_goal_id"
  add_index "indicator_data", ["id"], :name => "index_indicator_data_on_id", :unique => true
  add_index "indicator_data", ["indicator_id", "plan_id", "ppg_id", "goal_id", "problem_objective_id", "operation_id"], :name => "by_uniqueness"
  add_index "indicator_data", ["indicator_id"], :name => "index_indicator_data_on_indicator_id"
  add_index "indicator_data", ["is_deleted"], :name => "index_indicator_data_on_is_deleted"
  add_index "indicator_data", ["is_performance"], :name => "index_indicator_data_on_is_performance"
  add_index "indicator_data", ["output_id"], :name => "index_indicator_data_on_output_id"
  add_index "indicator_data", ["plan_id"], :name => "index_indicator_data_on_plan_id"
  add_index "indicator_data", ["problem_objective_id"], :name => "index_indicator_data_on_problem_objective_id"

  create_table "indicators", :id => false, :force => true do |t|
    t.string   "id",                                :null => false
    t.string   "name"
    t.boolean  "is_performance"
    t.boolean  "is_gsp"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.boolean  "is_deleted",     :default => false
    t.datetime "found_at"
  end

  add_index "indicators", ["id"], :name => "index_indicators_on_id", :unique => true

  create_table "indicators_operations", :id => false, :force => true do |t|
    t.string "operation_id", :null => false
    t.string "indicator_id", :null => false
  end

  add_index "indicators_operations", ["indicator_id"], :name => "index_indicators_operations_on_indicator_id"
  add_index "indicators_operations", ["operation_id", "indicator_id"], :name => "indicators_operations_uniq", :unique => true
  add_index "indicators_operations", ["operation_id"], :name => "index_indicators_operations_on_operation_id"

  create_table "indicators_outputs", :id => false, :force => true do |t|
    t.string "output_id",    :null => false
    t.string "indicator_id", :null => false
  end

  add_index "indicators_outputs", ["output_id", "indicator_id"], :name => "indicators_outputs_uniq", :unique => true

  create_table "indicators_plans", :force => true do |t|
    t.string "plan_id",      :null => false
    t.string "indicator_id", :null => false
  end

  add_index "indicators_plans", ["plan_id", "indicator_id", "id"], :name => "indicators_plans_uniq", :unique => true
  add_index "indicators_plans", ["plan_id", "indicator_id"], :name => "index_indicators_plans_on_plan_id_and_indicator_id", :unique => true

  create_table "indicators_ppgs", :id => false, :force => true do |t|
    t.string "ppg_id",       :null => false
    t.string "indicator_id", :null => false
  end

  add_index "indicators_ppgs", ["ppg_id", "indicator_id"], :name => "indicators_ppgs_uniq", :unique => true

  create_table "indicators_problem_objectives", :id => false, :force => true do |t|
    t.string "problem_objective_id", :null => false
    t.string "indicator_id",         :null => false
  end

  add_index "indicators_problem_objectives", ["problem_objective_id", "indicator_id"], :name => "indicators_problem_objectives_uniq", :unique => true

  create_table "indicators_strategies", :id => false, :force => true do |t|
    t.integer "strategy_id",  :null => false
    t.string  "indicator_id", :null => false
  end

  add_index "indicators_strategies", ["strategy_id"], :name => "index_indicators_strategies_on_strategy_id"

  create_table "indicators_strategy_objectives", :id => false, :force => true do |t|
    t.integer "strategy_objective_id", :null => false
    t.string  "indicator_id",          :null => false
  end

  create_table "narratives", :id => false, :force => true do |t|
    t.string   "id",                   :null => false
    t.datetime "found_at"
    t.string   "operation_id"
    t.string   "plan_id"
    t.string   "goal_id"
    t.string   "ppg_id"
    t.string   "problem_objective_id"
    t.string   "output_id"
    t.string   "elt_id"
    t.text     "usertxt"
    t.string   "createusr"
    t.string   "report_type"
    t.string   "plan_el_type"
    t.integer  "year"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "narratives", ["id"], :name => "index_narratives_on_id", :unique => true

  create_table "offices", :id => false, :force => true do |t|
    t.string   "id",               :null => false
    t.string   "name"
    t.string   "parent_office_id"
    t.boolean  "head"
    t.datetime "found_at"
    t.string   "operation_id"
    t.string   "plan_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "status"
    t.integer  "year"
  end

  add_index "offices", ["id"], :name => "index_offices_on_id", :unique => true

  create_table "operations", :id => false, :force => true do |t|
    t.string   "id",                            :null => false
    t.string   "name"
    t.text     "years"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "is_deleted", :default => false
    t.datetime "found_at"
    t.integer  "country_id"
  end

  add_index "operations", ["id"], :name => "index_operations_on_id", :unique => true

  create_table "operations_outputs", :id => false, :force => true do |t|
    t.string "operation_id", :null => false
    t.string "output_id",    :null => false
  end

  add_index "operations_outputs", ["operation_id", "output_id"], :name => "operations_outputs_uniq", :unique => true
  add_index "operations_outputs", ["operation_id"], :name => "index_operations_outputs_on_operation_id"
  add_index "operations_outputs", ["output_id"], :name => "index_operations_outputs_on_output_id"

  create_table "operations_ppgs", :id => false, :force => true do |t|
    t.string "operation_id", :null => false
    t.string "ppg_id",       :null => false
  end

  add_index "operations_ppgs", ["operation_id", "ppg_id"], :name => "operations_ppgs_uniq", :unique => true
  add_index "operations_ppgs", ["operation_id"], :name => "index_operations_ppgs_on_operation_id"
  add_index "operations_ppgs", ["ppg_id"], :name => "index_operations_ppgs_on_ppg_id"

  create_table "operations_problem_objectives", :id => false, :force => true do |t|
    t.string "problem_objective_id", :null => false
    t.string "operation_id",         :null => false
  end

  add_index "operations_problem_objectives", ["operation_id"], :name => "index_operations_problem_objectives_on_operation_id"
  add_index "operations_problem_objectives", ["problem_objective_id", "operation_id"], :name => "operations_problem_objectives_uniq", :unique => true
  add_index "operations_problem_objectives", ["problem_objective_id"], :name => "index_operations_problem_objectives_on_problem_objective_id"

  create_table "operations_rights_groups", :id => false, :force => true do |t|
    t.string "operation_id",    :null => false
    t.string "rights_group_id", :null => false
  end

  add_index "operations_rights_groups", ["operation_id", "rights_group_id"], :name => "operations_rights_groups_uniq", :unique => true

  create_table "operations_strategies", :id => false, :force => true do |t|
    t.integer "strategy_id",  :null => false
    t.string  "operation_id", :null => false
  end

  add_index "operations_strategies", ["strategy_id"], :name => "index_operations_strategies_on_strategy_id"

  create_table "operations_strategy_objectives", :id => false, :force => true do |t|
    t.integer "strategy_objective_id", :null => false
    t.string  "operation_id",          :null => false
  end

  create_table "outputs", :id => false, :force => true do |t|
    t.string   "id",                            :null => false
    t.string   "name"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "is_deleted", :default => false
    t.datetime "found_at"
  end

  add_index "outputs", ["id"], :name => "index_outputs_on_id", :unique => true

  create_table "outputs_plans", :force => true do |t|
    t.string "plan_id",   :null => false
    t.string "output_id", :null => false
  end

  add_index "outputs_plans", ["plan_id", "output_id", "id"], :name => "outputs_plans_uniq", :unique => true
  add_index "outputs_plans", ["plan_id", "output_id"], :name => "index_outputs_plans_on_plan_id_and_output_id", :unique => true

  create_table "outputs_ppgs", :id => false, :force => true do |t|
    t.string "ppg_id",    :null => false
    t.string "output_id", :null => false
  end

  add_index "outputs_ppgs", ["ppg_id", "output_id"], :name => "outputs_ppgs_uniq", :unique => true

  create_table "outputs_problem_objectives", :id => false, :force => true do |t|
    t.string "problem_objective_id", :null => false
    t.string "output_id",            :null => false
  end

  add_index "outputs_problem_objectives", ["problem_objective_id", "output_id"], :name => "outputs_problem_objectives_uniq", :unique => true

  create_table "outputs_strategies", :id => false, :force => true do |t|
    t.integer "strategy_id", :null => false
    t.string  "output_id",   :null => false
  end

  add_index "outputs_strategies", ["strategy_id"], :name => "index_outputs_strategies_on_strategy_id"

  create_table "outputs_strategy_objectives", :id => false, :force => true do |t|
    t.integer "strategy_objective_id", :null => false
    t.string  "output_id",             :null => false
  end

  create_table "plans", :id => false, :force => true do |t|
    t.string   "id",                                                 :null => false
    t.string   "operation_name"
    t.string   "name"
    t.integer  "year"
    t.string   "operation_id"
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
    t.boolean  "is_deleted",                      :default => false
    t.integer  "country_id"
    t.datetime "found_at"
    t.integer  "custom_ppgs_count",               :default => 0,     :null => false
    t.integer  "custom_indicators_count",         :default => 0,     :null => false
    t.integer  "custom_outputs_count",            :default => 0,     :null => false
    t.integer  "custom_problem_objectives_count", :default => 0,     :null => false
    t.integer  "custom_goals_count",              :default => 0,     :null => false
  end

  add_index "plans", ["id"], :name => "index_plans_on_id", :unique => true
  add_index "plans", ["operation_id"], :name => "index_plans_on_operation_id"

  create_table "plans_ppgs", :force => true do |t|
    t.string "plan_id", :null => false
    t.string "ppg_id",  :null => false
  end

  add_index "plans_ppgs", ["plan_id", "ppg_id", "id"], :name => "plans_ppgs_uniq", :unique => true
  add_index "plans_ppgs", ["plan_id", "ppg_id"], :name => "index_plans_ppgs_on_plan_id_and_ppg_id", :unique => true

  create_table "plans_problem_objectives", :force => true do |t|
    t.string "problem_objective_id", :null => false
    t.string "plan_id",              :null => false
  end

  add_index "plans_problem_objectives", ["plan_id", "problem_objective_id"], :name => "plans_objectives_index", :unique => true
  add_index "plans_problem_objectives", ["problem_objective_id", "plan_id", "id"], :name => "plans_problem_objectives_uniq", :unique => true

  create_table "plans_rights_groups", :id => false, :force => true do |t|
    t.string "plan_id",         :null => false
    t.string "rights_group_id", :null => false
  end

  add_index "plans_rights_groups", ["plan_id", "rights_group_id"], :name => "plans_rights_groups_uniq", :unique => true

  create_table "plans_strategies", :id => false, :force => true do |t|
    t.integer "strategy_id", :null => false
    t.string  "plan_id",     :null => false
  end

  add_index "plans_strategies", ["strategy_id"], :name => "index_plans_strategies_on_strategy_id"

  create_table "populations", :id => false, :force => true do |t|
    t.string   "ppg_code"
    t.string   "ppg_id"
    t.string   "operation_id"
    t.integer  "year"
    t.integer  "value"
    t.datetime "found_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "populations", ["year", "operation_id", "ppg_id"], :name => "populations_uniqueness", :unique => true

  create_table "positions", :id => false, :force => true do |t|
    t.string   "id",                                   :null => false
    t.string   "position_reference"
    t.string   "contract_type"
    t.string   "incumbent"
    t.string   "title"
    t.string   "grade"
    t.boolean  "head"
    t.boolean  "fast_track"
    t.string   "parent_position_id"
    t.string   "operation_id"
    t.string   "plan_id"
    t.datetime "found_at"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "office_id"
    t.boolean  "existing",           :default => true
  end

  add_index "positions", ["id"], :name => "index_positions_on_id", :unique => true

  create_table "ppgs", :id => false, :force => true do |t|
    t.string   "id",                                    :null => false
    t.string   "name"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.boolean  "is_deleted",         :default => false
    t.string   "population_type"
    t.string   "population_type_id"
    t.string   "operation_name"
    t.datetime "found_at"
    t.string   "msrp_code"
  end

  add_index "ppgs", ["id"], :name => "index_ppgs_on_id", :unique => true

  create_table "ppgs_problem_objectives", :id => false, :force => true do |t|
    t.string "ppg_id",               :null => false
    t.string "problem_objective_id", :null => false
  end

  add_index "ppgs_problem_objectives", ["ppg_id", "problem_objective_id"], :name => "ppgs_problem_objectives_uniq", :unique => true

  create_table "ppgs_strategies", :id => false, :force => true do |t|
    t.integer "strategy_id", :null => false
    t.string  "ppg_id",      :null => false
  end

  add_index "ppgs_strategies", ["strategy_id"], :name => "index_ppgs_strategies_on_strategy_id"

  create_table "ppgs_strategy_objectives", :id => false, :force => true do |t|
    t.integer "strategy_objective_id", :null => false
    t.string  "ppg_id",                :null => false
  end

  create_table "problem_objectives", :id => false, :force => true do |t|
    t.string   "id",                                :null => false
    t.string   "problem_name"
    t.string   "objective_name"
    t.boolean  "is_excluded"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.boolean  "is_deleted",     :default => false
    t.datetime "found_at"
  end

  add_index "problem_objectives", ["id"], :name => "index_problem_objectives_on_id", :unique => true

  create_table "problem_objectives_rights_groups", :id => false, :force => true do |t|
    t.string "problem_objective_id", :null => false
    t.string "rights_group_id",      :null => false
  end

  add_index "problem_objectives_rights_groups", ["problem_objective_id", "rights_group_id"], :name => "problem_objectives_rights_groups_uniq", :unique => true

  create_table "problem_objectives_strategies", :id => false, :force => true do |t|
    t.integer "strategy_id",          :null => false
    t.string  "problem_objective_id", :null => false
  end

  add_index "problem_objectives_strategies", ["strategy_id"], :name => "index_problem_objectives_strategies_on_strategy_id"

  create_table "problem_objectives_strategy_objectives", :id => false, :force => true do |t|
    t.integer "strategy_objective_id", :null => false
    t.string  "problem_objective_id",  :null => false
  end

  create_table "rights_groups", :id => false, :force => true do |t|
    t.string   "id",                            :null => false
    t.string   "name"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "is_deleted", :default => false
    t.datetime "found_at"
  end

  add_index "rights_groups", ["id"], :name => "index_rights_groups_on_id", :unique => true

  create_table "rights_groups_strategies", :id => false, :force => true do |t|
    t.integer "strategy_id",     :null => false
    t.string  "rights_group_id", :null => false
  end

  create_table "rights_groups_strategy_objectives", :id => false, :force => true do |t|
    t.integer "strategy_objective_id", :null => false
    t.string  "rights_group_id",       :null => false
  end

  create_table "strategies", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.text     "description"
    t.integer  "user_id"
    t.string   "dashboard_type"
  end

  create_table "strategy_objectives", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "strategy_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "users", :force => true do |t|
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
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
    t.boolean  "reset_local_db",         :default => false
    t.string   "login",                  :default => "",    :null => false
    t.boolean  "admin",                  :default => false
  end

  add_index "users", ["login"], :name => "index_users_on_login"

  create_table "users_strategies", :force => true do |t|
    t.integer  "user_id"
    t.integer  "strategy_id"
    t.integer  "permission",  :default => 0
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

end
