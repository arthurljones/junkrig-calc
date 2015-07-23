require "options_initializer"

class Crane
  include OptionsInitializer

  attr_reader *%i(
    saltwater_displaced
  )

  options_initialize(

  ) do |options|

  end
end
