module Wrest
  module VERSION
    unless defined? MAJOR
      MAJOR  = 0
      MINOR  = 0
      TINY   = 1

      STRING = [MAJOR, MINOR, TINY].join('.')

      SUMMARY = "rspec #{STRING}"
    end
  end
end