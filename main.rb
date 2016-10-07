#main
require_relative 'expressions'
require_relative 'lexer'

lex = Lexer.new("")

token=lex.next_token
while token!=nil
  puts token
  token=lex.next_token
end

puts "fin"