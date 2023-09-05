import random

Lower = "abcdefghijklmnopqrstuvwxyz"
Upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
Numbers = "0123456789"
Symbols = "[]{}();*/-_"

All = Lower + Upper + Numbers + Symbols

Length = 14

Password = "".join(random.sample(All, Length))

print(Password)