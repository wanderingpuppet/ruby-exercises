# frozen_string_literal: true

def bubble_sort(arr)
  arr = arr.dup   # Don't modify the original array
  loop do
    swaps = bubble_swaps(arr)
    break if swaps.zero?
  end
  arr
end

def bubble_swaps(arr)
  swaps = 0
  0.upto(arr.length - 2) do |i|
    if arr[i] > arr[i + 1]
      arr[i], arr[i + 1] = arr[i + 1], arr[i]
      swaps += 1
    end
  end
  swaps
end
