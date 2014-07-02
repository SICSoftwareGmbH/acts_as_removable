require 'spec_helper'

describe 'acts_as_removable' do
  class MyModel < ActiveRecord::Base
    acts_as_removable
    attr_accessor :callback_before_remove, :callback_after_remove, :callback_before_unremove, :callback_after_unremove
    before_remove do |r|
      r.callback_before_remove = true
    end
    after_remove do |r|
      r.callback_after_remove = true
    end

    before_unremove do |ur|
      ur.callback_before_unremove = true
    end
    after_unremove do |ur|
      ur.callback_after_unremove = true
    end
  end

  class MySecondModel < ActiveRecord::Base
    acts_as_removable column_name: :use_this_column, without_default_scope: true
  end

  before do
    # setup database
    db_file = File.expand_path(File.join(File.dirname(__FILE__), '..', 'tmp', 'acts_as_removable.db'))
    Dir::mkdir(File.dirname(db_file)) unless File.exists?(File.dirname(db_file))
    ActiveRecord::Base.establish_connection(
      :adapter => 'sqlite3',
      :database => "#{File.expand_path(File.join(File.dirname(__FILE__), '..'))}/tmp/acts_as_removable.db"
    )
    ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'my_models'")
    ActiveRecord::Base.connection.create_table(:my_models) do |t|
      t.timestamp :removed_at
    end
    ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'my_second_models'")
    ActiveRecord::Base.connection.create_table(:my_second_models) do |t|
      t.string :name
      t.timestamp :use_this_column
    end
  end

  it 'test column and check method' do
    [[MyModel.create!, :removed_at], [MySecondModel.create!, :use_this_column]].each do |r, column_name|
      r.removed?.should be_false
      r.send(column_name).should be_nil

      r.remove
      r.removed?.should be_true
      r.send(column_name).should be_a(Time)
    end
  end

  it 'test scopes' do
    MyModel.delete_all
    MySecondModel.delete_all

    MyModel.create!
    MyModel.create!.remove!
    MySecondModel.create!
    MySecondModel.create!.remove!

    MyModel.count.to_i.should be(1)
    MyModel.actives.count.should be(1)
    MyModel.removed.count.should be(1)
    MyModel.unscoped.count.should be(2)

    MySecondModel.count.to_i.should be(2)
    MySecondModel.actives.count.should be(1)
    MySecondModel.removed.count.should be(1)
    MySecondModel.unscoped.count.should be(2)
  end

  it 'test callbacks' do
    r = MyModel.create!
    r.callback_before_remove.should be_false
    r.callback_after_remove.should be_false
    r.callback_before_unremove.should be_false
    r.callback_after_unremove.should be_false

    r.remove

    r.callback_before_remove.should be_true
    r.callback_after_remove.should be_true
    r.callback_before_unremove.should be_false
    r.callback_after_unremove.should be_false

    r.unremove

    r.callback_before_remove.should be_true
    r.callback_after_remove.should be_true
    r.callback_before_unremove.should be_true
    r.callback_after_unremove.should be_true
  end
end
