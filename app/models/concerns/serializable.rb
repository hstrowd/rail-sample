module Serializable
  extend ActiveSupport::Concern

  def as_json(options={include_root: false})
    if ActiveModel::Serializer.serializer_for(self).present?
      ActiveModelSerializers::SerializableResource.new(self, options).as_json
    else
      self.attributes
    end
  end

  # By default the serializer should be named by appending 'Serializer' to the model name.
  def serializer_class
    "#{self.class.to_s}Serializer".constantize
  end
end
