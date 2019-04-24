module Filterable
  extend ActiveSupport::Concern

  module ClassMethods
    def filter(filtering_params)
      filtering_params = filtering_params.to_h unless filtering_params.is_a?(ActionController::Parameters)
      results = where(nil)
      filtering_params.each do |key, value|
        results = results.public_send(key, value) if value.present?
      end
      results
    end
  end
end
