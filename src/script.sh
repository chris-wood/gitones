set terminal png
set datafile sep ','
set output 'test.png'
set timefmt '%m-%d-%Y'
set xdata time
plot 'test.csv' using 1:2 with lines