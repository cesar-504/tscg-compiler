mainBloque:
mem asd 64
t_0 =  78.12 * 234
t_1 =  45 + t_0
t_2 =  t_1 + 56
asd = t_2
mem asd2 32
asd2 = 7
mem b1 8
b1 = true
mem b2 8
t_3 =  true && b1
t_4 =  false || t_3
b2 = t_4
asd = 342
t_5 =  b1 == true
if t_5==false goto nif6
asd = 123.43
b2 = false
goto end_if5
nif5:
asd = 0
b2 = true
t_7 =  b1 == true
t_7
cloop8:
if t_7==false goto end_cloop8
t_6 =  asd + 1
asd = t_6
end_if6:
end_cloop8:
mainBloque end
