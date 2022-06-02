#!/usr/bin/env python3

import numpy as np

csv = np.genfromtxt ('cordic_results.csv', delimiter=",")
cordic = csv[:,0]
exact = csv[:,1]

assert len(cordic) == len(exact)

error = np.subtract(exact, cordic)
relative_error = np.abs(error) / exact
print("MSE = ", np.square(error).mean())

try:
  import matplotlib.pyplot as plt

  dt = 1
  t = np.arange(0, len(cordic), dt)

  fig, axs = plt.subplots(3, 1)
  axs[0].plot(t, cordic, label='CORDIC')
  axs[0].plot(t, exact, label='exact')
  axs[0].set_xlim(1, len(cordic))
  axs[0].set_xlabel('Samples')
  axs[0].set_ylabel('CORDIC vs. exact')
  axs[0].grid(True)
  axs[0].legend()

  axs[1].plot(t, error)
  axs[1].set_xlim(1, len(error))
  axs[1].set_xlabel('Samples')
  axs[1].set_ylabel('Absolute Error')
  axs[1].grid(True)

  axs[2].plot(t, relative_error)
  axs[2].set_xlim(1, len(relative_error))
  axs[2].set_xlabel('Samples')
  axs[2].set_ylabel('Relative Error')
  axs[2].grid(True)

  plt.show()
except Exception:
  print("Unable to import matplotlib")
