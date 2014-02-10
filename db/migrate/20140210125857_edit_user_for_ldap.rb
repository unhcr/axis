class EditUserForLdap < ActiveRecord::Migration
  def up
    if index_exists?(:users, :reset_password_token)
      remove_index :users, :reset_password_token
    end
    if index_exists?(:users, :email)
      remove_index :users, :email
      remove_column :users, :email
    end

    unless column_exists? :users, :login
      add_column :users, :login, :string, :null => false, :default => "", :unique => true
    end
    unless index_exists?(:users, :login)
      add_index :users, :login
    end
  end

  def down
    unless index_exists?(:users, :reset_password_token)
      add_index :users, :reset_password_token
    end
    unless column_exists?(:users, :email)
      add_column :users, :email, :string, :null => false, :default => "", :unique => true
    end

    unless index_exists?(:users, :email)
      add_index :users, :email
    end

    if index_exists?(:users, :login)
      remove_index :users, :login
    end
    remove_column :users, :login
  end
end
