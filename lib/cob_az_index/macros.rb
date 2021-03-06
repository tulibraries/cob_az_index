# frozen_string_literal: true

# Custom traject macros for cob_az_index
module CobAzIndex::Macros
  def truncate(max = 300)
    Proc.new do |rec, acc|
      acc.map! { |s| s.length > max ? s[0...max] + " ..." : s unless s.nil? }
    end
  end
end
