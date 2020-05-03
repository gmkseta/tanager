module Callable
  extend ActiveSupport::Concern

  class_methods do
    def call(*args, **kwargs)
      if kwargs.any?
        new(*args, **kwargs).run
      else
        new(*args).run
      end
    end
  end
end
