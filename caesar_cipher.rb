def caesar_cipher(string, shift_factor)
    shifted_chars = []
    string.each_char do |char|
        shifted_chars << shift_letter(char, shift_factor)
    end
    shifted_chars.join("")
end

def shift_letter(char, shift_factor)
    char_ord = char.ord
    if char_ord.between?(97, 122)
        base_ord = 97
    elsif char_ord.between?(65, 90)
        base_ord = 65
    else
        return char
    end

    shifted_ord = (char_ord - base_ord + shift_factor)%26 + base_ord
    shifted_ord.chr(Encoding::UTF_8)
end
