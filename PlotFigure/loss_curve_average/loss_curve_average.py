import csv
import matplotlib.pyplot as plt
import string
import numpy as np


with open('loss.csv', 'r') as f:
    reader = csv.reader(f)
    y_val_loss = np.zeros(43375)
    place = 0
    for irow, (row) in enumerate(reader):
        # the type of the input data is string, convert it to float
        y_val_loss[irow] = string.atof(row[1])

interval = 5
points, remain = divmod(len(y_val_loss), interval)
loss_data = y_val_loss[:points*interval]

# separate the array into several equal sub-arrary
data = loss_data[::interval]
for i in range(1, interval):
    sel = loss_data[i::interval]
    data += sel
# calculate average loss
data /= interval
# convert array to list
data = data.tolist()

coord = range(0, points*interval, interval)

plt.plot(coord[20:-1500], data[20:-1500])

plt.xlabel('Iteration')
plt.ylabel('Loss')
plt.show()

