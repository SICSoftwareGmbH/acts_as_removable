require 'active_support/concern'
require 'active_record'
require "acts_as_removable/version"

module ActsAsRemovable
  extend ActiveSupport::Concern

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
    def acts_as_removable(options = {})
      _acts_as_removable_options.merge!(options)

      scope :removed, -> {
        removed_at_column_name = _acts_as_removable_options[:column_name]
        query = where(all.table[removed_at_column_name].not_eq(nil).to_sql)
        _removable_where_values(query, removed_at_column_name, all.table[removed_at_column_name].eq(nil).to_sql)
      }

      scope :actives, -> {
        removed_at_column_name = _acts_as_removable_options[:column_name]
        query = where(all.table[removed_at_column_name].eq(nil).to_sql)
        _removable_where_values(query, removed_at_column_name, all.table[removed_at_column_name].not_eq(nil).to_sql)
      }

      default_scope -> {where(all.table[_acts_as_removable_options[:column_name]].eq(nil).to_sql)} unless _acts_as_removable_options[:without_default_scope]

      define_model_callbacks :remove, :unremove

      class_eval do
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
          send(self.class._acts_as_removable_options[:column_name]).present?
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

        def _update_remove_attribute(callback, value, with_bang=false, options={})
          run_callbacks callback.to_sym do
            send("#{self.class._acts_as_removable_options[:column_name]}=", value)
            with_bang ? save!(options) : save(options)
          end
        end
      end
    end

    def _acts_as_removable_options
      @_acts_as_removable_options ||= {
          column_name: 'removed_at'
        }
    end

    # Delete where statements from query
    def _removable_where_values(query, column_name, remove_where)
      query = query.with_default_scope if query.respond_to?(:with_default_scope)
      query.where_values.delete(remove_where)
      query
    end
  end
end

ActiveRecord::Base.send(:include, ActsAsRemovable)
