echo -n 2>roth2.log
# 0x620e00 = GPIO ports 9,10,11,17,21,22
# 300 = 5 minutes
./counter 0x620e00 300 2>>roth2.log | tee roth2.dat | ../derived/buffer 2>>roth2.log | ./sender.sh 1 http://warlich.bplaced.net/Roth2/data.php 2>>roth2.log&
