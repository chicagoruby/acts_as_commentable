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
            # Helper method to lookup for comments for a given object.
            # This method is equivalent to obj.comments.
            define_method "find_#{association_name}_for" do |obj|
              commentable = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
              Comment.find_comments_for_commentable_by_type(commentable, obj.id, association_name)
            end

            # Helper class method to lookup comments for
            # the mixin commentable type written by a given user.
            # This method is NOT equivalent to Comment.find_comments_for_user
            define_method "find_#{association_name}_by_user" do |user|
              commentable = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
              Comment.find_comments_by_user_and_type(commentable, obj.id, association_name)
            end
          end

          # Helper method to sort comments by date
          define_method "#{association_name}_ordered_by_submitted" do
            Comment.find_comments_for_commentable_by_type(self.class.name, id, association_name).in_order
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

ActiveRecord::Base.send(:include, Juixe::Acts::Commentable)
