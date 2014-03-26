echo -n 2>roth1.log
# 0x390 = GPIO ports 8,11,12,13
# 300 = 5 minutes
./counter 0x390 300 2>>roth1.log | tee roth1.dat | ../derived/buffer 2>>roth1.log | ./sender.sh 1 http://warlich.bplaced.net/Roth2/data.php 2>>roth1.log&
