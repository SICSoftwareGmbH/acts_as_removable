# frozen_string_literal: true

require 'active_support/concern'
require 'active_record'
require 'acts_as_removable/version'

module ActsAsRemovable
  extend ActiveSupport::Concern

  module ClassMethods
    # Add ability to remove ActiveRecord instances
    #
    #   acts_as_removable
    #   acts_as_removable column_name: 'other_column_name'
    #
    # ===== Options
    #
    # * <tt>:column_name</tt> - A symbol or string with the column to use for removal timestamp.
    def acts_as_removable(options = {})
      _acts_as_removable_options.merge!(options)

      scope :removed, lambda {
        where(all.table[_acts_as_removable_options[:column_name]].not_eq(nil).to_sql)
      }

      scope :actives, lambda {
        where(all.table[_acts_as_removable_options[:column_name]].eq(nil).to_sql)
      }

      define_model_callbacks :remove, :unremove

      class_eval do
        def self.before_remove(*args, &block)
          set_callback(:remove, :before, *args, &block)
        end

        def self.after_remove(*args, &block)
          set_callback(:remove, :after, *args, &block)
        end

        def self.before_unremove(*args, &block)
          set_callback(:unremove, :before, *args, &block)
        end

        def self.after_unremove(*args, &block)
          set_callback(:unremove, :after, *args, &block)
        end

        def removed?
          send(self.class._acts_as_removable_options[:column_name]).present?
        end

        def remove(options = {})
          _update_remove_attribute(:remove, Time.now, false, options)
        end

        def remove!(options = {})
          _update_remove_attribute(:remove, Time.now, true, options)
        end

        def unremove(options = {})
          _update_remove_attribute(:unremove, nil, false, options)
        end

        def unremove!(options = {})
          _update_remove_attribute(:unremove, nil, true, options)
        end

        def _update_remove_attribute(callback, value, with_bang = false, options = {})
          self.class.transaction do
            run_callbacks callback.to_sym do
              send("#{self.class._acts_as_removable_options[:column_name]}=", value)

              # workaround for new argument handling
              if RUBY_VERSION.to_i < 3
                with_bang ? save!(options) : save(options)
              else
                with_bang ? save!(**options) : save(**options)
              end
            end
          end
        end
      end
    end

    def _acts_as_removable_options
      @_acts_as_removable_options ||= { column_name: 'removed_at' }
    end
  end
end

ActiveRecord::Base.send(:include, ActsAsRemovable)
