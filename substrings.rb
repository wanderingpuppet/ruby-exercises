# frozen_string_literal: true

def substrings(string, dictionary)
  string = string.downcase
  dictionary.each_with_object({}) do |substring, counts|
    substring_count = count_substring(string, substring.downcase)
    counts[substring] = substring_count if substring_count.positive?
  end
end

def count_substring(string, substring)
  count = 0
  limit = string.length - substring.length

  0.upto(limit) do |i|
    count += 1 if string[i, substring.length] == substring
  end
  count
end
