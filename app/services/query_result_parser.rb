# frozen_string_literal: true

class QueryResultParser
  class << self
    SEPARATOR = '|'

    def parse(file_path)
      verify_file_path_exists!(file_path)

      headers = []
      records = []

      File.open(file_path, 'r') do |file|
        file.each_line do |line|
          next if ['(', '-'].include?(line.first)

          fields = line.chomp.split(SEPARATOR).map { |field| sanitize_field(field) }

          if headers.empty?
            headers = fields
          else
            records << headers.zip(fields).to_h
          end
        end
      end

      records
    end

  private

    def verify_file_path_exists!(file_path)
      return if File.exists?(file_path)
      raise(ArgumentError, "File #{file_path} does not exist")
    end

    def sanitize_field(field)
      field.strip
    end
  end
end
