module Wrest
  module VERSION
    unless defined? MAJOR
      MAJOR  = 0
      MINOR  = 0
      TINY   = 2

      STRING = [MAJOR, MINOR, TINY].join('.')

      SUMMARY = "wrest #{STRING}"
    end
  end
end