# frozen_string_literal: true

class Path
  module VERSION
    MAJOR = 1
    MINOR = 0
    PATCH = 1
    STAGE = nil
    STRING = [MAJOR, MINOR, PATCH, STAGE].reject(&:nil?).join('.').freeze

    def self.to_s
      STRING
    end
  end
end
