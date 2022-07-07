# frozen_string_literal: true

# Hash extension
class Hash
  def self.grid(rows, columns)
    position = 1
    {}.tap do |hsh|
      (1..rows).each do |row|
        (1..columns).each do |column|
          yield(position, row, column) if block_given?
          hsh[position] = [row, column]
          position += 1
        end
      end
    end
  end
end
