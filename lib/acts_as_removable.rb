require 'active_support/concern'
require 'active_record'
require "acts_as_removable/version"

module ActsAsRemovable
  extend ActiveSupport::Concern

  included do
    extend(ClassMethods)
  end

  module ClassMethods
    def acts_as_removable(options={})
      self.class_eval do
        @_acts_as_removable_column_name = options[:column_name] || 'removed_at'
        def self._acts_as_removable_column_name
          @_acts_as_removable_column_name
        end

        default_scope -> {where("#{self.table_name}.#{self._acts_as_removable_column_name} IS NULL")}
        scope :removed, -> {where("#{self.table_name}.#{self._acts_as_removable_column_name} IS NOT NULL")}

        define_callbacks :remove

        def self.before_remove(*args, &block)
          set_callback :remove, :before, *args, &block
        end

        def self.after_remove(*args, &block)
          set_callback :remove, :after, *args, &block
        end

        def removed?
          self.send(self.class._acts_as_removable_column_name).present?
        end

        def remove
          run_callbacks :remove do
            self.update_attributes(self.class._acts_as_removable_column_name => Time.now)
          end
        end

        def remove!
          run_callbacks :remove do
            self.update_attributes!(self.class._acts_as_removable_column_name => Time.now)
          end
        end
      end
    end
  end

end

ActiveRecord::Base.send(:include, ActsAsRemovable)
