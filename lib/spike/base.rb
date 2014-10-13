require 'spike/api'
require 'spike/associations'
require 'spike/attributes'
require 'spike/scopes'

module Spike
  module Base
    extend ActiveSupport::Concern
    include Api
    include Associations
    include Attributes
    include Scopes
    private

      def method_missing(name, *args, &block)
        if has_association?(name)
          build_association(name)
        elsif has_attribute?(name)
          build_attribute(name)
        else
          super
        end
      end

  end
end