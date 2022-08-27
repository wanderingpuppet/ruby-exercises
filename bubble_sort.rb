def bubble_sort(arr)
    arr = arr.dup   # Don't modify the original array
    loop do
        swaps = 0
        0.upto(arr.length - 2) do |i|
            if arr[i] > arr[i + 1]
                arr[i], arr[i + 1] = arr[i + 1], arr[i]
                swaps += 1
            end
        end
        break if swaps == 0
    end
    arr
end
