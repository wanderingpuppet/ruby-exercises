# frozen_string_literal: true

def stock_picker(arr)
  buy_day = 0
  sell_day = 0

  (0...(arr.length - 1)).each do |i|
    ((i + 1)...arr.length).each do |j|
      next unless arr[j] - arr[i] > arr[sell_day] - arr[buy_day]

      buy_day = i
      sell_day = j
    end
  end

  [buy_day, sell_day]
end
