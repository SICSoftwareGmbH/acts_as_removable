require 'active_support/concern'
require 'active_record'
require "acts_as_removable/version"

module ActsAsRemovable
  extend ActiveSupport::Concern

  included do
    extend(ClassMethods)
  end

  module ClassMethods

    # Add ability to remove ActiveRecord instances
    #
    #   acts_as_removable
    #   acts_as_removable column_name: 'other_column_name'
    #   acts_as_removable without_default_scope: true
    #
    # ===== Options
    #
    # * <tt>:column_name</tt> - A symbol or string with the column to use for removal timestamp.
    # * <tt>:without_default_scope</tt> - A boolean indicating to not set a default scope.
    def acts_as_removable(options={})
      self.class_eval do
        @_acts_as_removable_column_name = (options[:column_name] || 'removed_at').to_s
        def self._acts_as_removable_column_name
          @_acts_as_removable_column_name
        end

        scope :removed, -> {
          removed_at_column_name = self._acts_as_removable_column_name
          query = where(all.table[removed_at_column_name].not_eq(nil).to_sql)
          ::ActsAsRemovable.removable_where_values(query, removed_at_column_name, all.table[removed_at_column_name].eq(nil).to_sql)
        }

        scope :actives, -> {
          removed_at_column_name = self._acts_as_removable_column_name
          query = where(all.table[removed_at_column_name].eq(nil).to_sql)
          ::ActsAsRemovable.removable_where_values(query, removed_at_column_name, all.table[removed_at_column_name].not_eq(nil).to_sql)
        }

        default_scope -> {where(all.table[self._acts_as_removable_column_name].eq(nil).to_sql)} unless options[:without_default_scope]

        define_model_callbacks :remove, :unremove

        def self.before_remove(*args, &block)
          set_callback :remove, :before, *args, &block
        end

        def self.after_remove(*args, &block)
          set_callback :remove, :after, *args, &block
        end

        def self.before_unremove(*args, &block)
          set_callback :unremove, :before, *args, &block
        end

        def self.after_unremove(*args, &block)
          set_callback :unremove, :after, *args, &block
        end

        def removed?
          self.send(self.class._acts_as_removable_column_name).present?
        end

        def remove(options={})
          _update_remove_attribute(:remove, Time.now, false, options)
        end

        def remove!(options={})
          _update_remove_attribute(:remove, Time.now, true, options)
        end

        def unremove(options={})
          _update_remove_attribute(:unremove, nil, false, options)
        end

        def unremove!(options={})
          _update_remove_attribute(:unremove, nil, true, options)
        end

        private

        def _update_remove_attribute(callback, value, with_bang=false, options={})
          run_callbacks callback.to_sym do
            self.send("#{self.class._acts_as_removable_column_name}=", value)
            with_bang ? self.save!(options) : self.save(options)
          end
        end
      end
    end
  end

  # Helps deleting where statements from query
  def self.removable_where_values(query, column_name, remove_where)
    query = query.with_default_scope if query.respond_to?(:with_default_scope)
    query.where_values.delete(remove_where)
    query
  end
end

ActiveRecord::Base.send(:include, ActsAsRemovable)
