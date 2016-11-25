mainBloque:
mem asd 64
s
t_0 =  78.12 * 234
s
t_1 =  45 + t_0
s
t_2 =  t_1 + 56
asd = t_2
mem asd2 32
asd2 = 7
mem b1 8
b1 = true
mem b2 8
s
t_3 =  true && b1
s
t_4 =  false || t_3
b2 = t_4
asd = 342
s
t_5 =  b1 == true
if t_5==false goto nif6
asd = 123.43
b2 = false
goto end_if6
nif6:
asd = 0
b2 = true
s
t_6 =  b1 == true
t_6
cloop7:
if t_6==false goto end_cloop7
s
t_8 =  asd + 1
asd = t_8
end_cloop7
end_if6
mainBloque end
