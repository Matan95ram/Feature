import smtplib
my_email = "testemail@gmail.com"
password = "mypw123"

connection = smtplib.SMTP("smtp.gmail.com",587)
connection.starttls()
connection.login(user=my_email, password=password)
connection.sendmail(from_addr=my_email,
                    to_addrs="test2@gmail.com",
                    msg="Hello this is a TEST")

connection.close()
