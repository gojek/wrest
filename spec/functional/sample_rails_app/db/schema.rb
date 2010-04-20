# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100128091628) do

  create_table "bottles", :force => true do |t|
    t.string  "type"
    t.string  "name"
    t.integer "universe_id"
  end

  create_table "comments", :force => true do |t|
    t.integer  "commentworthy_id"
    t.string   "commentworthy_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oogas", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resource_full_mock_addresses", :force => true do |t|
    t.string   "street"
    t.string   "city"
    t.string   "state_code"
    t.integer  "zip"
    t.integer  "resource_full_mock_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resource_full_mock_employers", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resource_full_mock_users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.date     "birthdate"
    t.string   "email"
    t.string   "join_date"
    t.integer  "income"
    t.integer  "resource_full_mock_employer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "undo_actions", :force => true do |t|
    t.string "description", :limit => 100
  end

  create_table "undo_records", :force => true do |t|
    t.string   "operation"
    t.string   "undoable_type",  :limit => 100
    t.integer  "undoable_id"
    t.integer  "revision"
    t.binary   "data",           :limit => 5242880
    t.integer  "undo_action_id",                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "undo_records", ["undoable_type", "undoable_id", "revision"], :name => "undoable", :unique => true

end
