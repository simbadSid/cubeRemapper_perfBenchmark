import numpy as np
import matplotlib.pyplot as plt




nbrValues   = 200
fileName    = "values.txt"
fd          = open(fileName, 'r')
axis        = [0] * nbrValues
ordinate    = [0] * nbrValues

for i in range(0, nbrValues):
	axis[i]     = int(fd.readline())
	ordinate[i] = float(fd.readline())
	if (i > 0 and axis[i] < axis[i-1]):
		print("*****")
		print(axis[i])
		print(axis[i-1])
		print("-----")



plt.figure()
line = plt.plot(axis, ordinate, '-', marker='h', linewidth=2)
plt.grid()
plt.title('Fragmentation representation for \"worst fit\" allocator');
plt.xlabel('Total amount of used memory (bytes)')
plt.ylabel('Fragmentation')
plt.show()



