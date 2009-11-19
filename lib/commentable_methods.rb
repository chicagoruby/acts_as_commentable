require 'activerecord'
require 'optparse'

# ActsAsCommentable
module Juixe
  module Acts #:nodoc:
    module Commentable #:nodoc:

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_commentable(association_name = nil)
          association_name = :comments if association_name.nil?
          raise OptionParser::InvalidArgument, :association_name if association_name.blank?

          association_name = association_name.to_s
          has_many association_name, :as => :commentable, :dependent => :destroy, :class_name => 'Comment', :conditions => {:comment_type => association_name}

          self.class_eval do
            # Helper method to sort comments by date
            define_method "#{association_name}_ordered_by_submitted" do
              self.send(association_name).recent
            end

            # Helper method that defaults the submitted time.
            define_method "add_#{association_name.singularize}" do |comment|
              self.send("#{association_name}") << comment
            end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Juixe::Acts::Commentable)
