import csv
import matplotlib.pyplot as plt

doc_file = '/disk2/yangle/result/LearnModel/QNet_box/models_batch/history.csv'
with open(doc_file, 'r') as f:
    reader = csv.reader(f)
    epoch = []
    loss = []
    for row in reader:
        epoch.append(int(row[0]))
        loss.append(float(row[1]))
plt.plot(epoch[-200:], loss[-200:])
plt.show()

