import csv
import matplotlib.pyplot as plt
import string

with open('train.csv', 'r') as f:
    reader = csv.reader(f)
    x_train_iter = []
    y_train_loss = []
    for row in reader:
        x_train_iter.append(row[0])
        y_train_loss.append(row[1])
min_val_loss = 1
with open('val.csv', 'r') as f:
    reader = csv.reader(f)
    x_val_iter = []
    y_val_loss = []
    place = 0
    for irow, (row) in enumerate(reader):
    # for row in reader:
        x_val_iter.append(row[0])
        y_val_loss.append(row[1])
        val_loss = string.atof(row[1])
        # print(val_loss)
        if val_loss < min_val_loss:
            # print('here')
            place = irow + 1
            min_val_loss = val_loss

plt.plot(x_train_iter, y_train_loss)
plt.plot(x_val_iter, y_val_loss)
plt.xlabel('iteration')
plt.ylabel('loss')
plt.show()
print('the minimum validation loss is %f' % min_val_loss)
print(type(len(x_val_iter)))
patience = len(x_val_iter) - place
print('no improvement for %f iteration' % patience)

