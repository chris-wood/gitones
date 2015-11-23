import os
import sys
import pandas as pd
import matplotlib.pyplot as plt

fname = sys.argv[1]
fhandle = open(fname, "r")

ticks = []
plotdata = []
index = 0
for line in fhandle:
    data = line.split(",")
    x = str(index)
    y = int(data[1])
    ticks.append(data[0])
    plotdata.append((x, y))
    index += 1

plt.close('all')
fig, ax = plt.subplots(1)
ax.plot(plotdata)

fig.autofmt_xdate()

import matplotlib.dates as mdates
ax.fmt_xdata = mdates.DateFormatter('%m-%d-%Y')
plt.title('fig.autofmt_xdate fixes the labels')
plt.xticks(range(1, index), ticks)

#plt.show()

plt.savefig(fname + ".png");

# plt.plot(plotdata)
# plt.ylabel('some sheet')
# plt.show()
