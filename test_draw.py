import numpy as np
from draw_lines import draw_lines
import matplotlib.pyplot as plt


""" A simple test for the line drawing Fortran code """

X = np.zeros((100, 100, 100, 3), dtype='float32', order='F')

points = np.array([[10,10,10],[20,60,10],[80,80,10]], dtype='float64', order='F')


draw_lines(X, points, 10)

fig, axes = plt.subplots(1)
axes.imshow(X[:,:,10,:])

fig.savefig('test_draw_fig.png')
plt.show()

