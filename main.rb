#main
require_relative 'expressions'
require_relative 'lexer'

lex = Lexer.new("/home/cesar/Documentos/Proyectos/ruby/tscg-compiler/ejemplos/main.tscg")

puts lex

puts "fin"
