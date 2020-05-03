module Service
  class Base
    include Callable
    extend Dry::Initializer
  end
end
