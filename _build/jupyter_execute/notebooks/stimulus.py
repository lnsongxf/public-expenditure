#!/usr/bin/env python
# coding: utf-8

# # Optimal Stimulus
# 
# This section computes the optimal level of public expenditure for any given current unemployment rate by using the sufficient-statistics formula. Before we start, we set up the libraries and read in the helper functions. 

# In[11]:


# %load setup.py
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import matplotlib.ticker as mtick
get_ipython().run_line_magic('run', 'helpers.ipynb')


# ## Calculating Optimal Stimulus
# 
# First, we load the calibrated parameter values from our previous section. 

# In[12]:


params = pd.read_csv('output/params_suffstat.csv')
params = dict(params.values)
params


# We want to find out what the optimal stimulus is for any deviation from the steady state. Here, we set $u_0 = 9\%$, which means we want to calculate the optimal stimulus when current unemployment rate is around $3$ percentage points higher than the steady-state value. Feel free to change this value to see how optimal stimulus changes. 
# 
# We also set $\eta = 0.6$ and calculate $m$'s for a given range of $M$'s:

# In[13]:


u0 = 0.09
M_vals = np.linspace(start=params['M_bar_l'], stop=params['M_bar_h'], num=101)
m_vals = m_func(which='M', M=M_vals, u=params['u_bar'], GY=GY_func(params['GC_bar']), **params)


# We now calculate optimal stimulus with the following equation:
# 
#                 $\frac{g/c - (g/c)^*}{(g/c)^*} \approx \frac{z_0 \epsilon m}{1 + z_1 z_0\epsilon m^2}\cdot \frac{u_0 - \bar{u}}{\bar{u}}.$          [![Generic badge](https://img.shields.io/badge/MS19-Eq%2023-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)  
# 
# For convenience, we define the following wrapper, which calculates optimal stimulus as a percentage of GDP for different $\epsilon$'s from the LHS of the equation above using accounting identities:

# In[14]:


stim_func = lambda epsilon:GY_func((suffstat_func(m=m_vals, z0=params['z0'], z1=params['z1'],
                                                  epsilon=epsilon, u0=u0, u_bar=params['u_bar']) + 1)*params['GC_bar']) - GY_func(params['GC_bar'])


# Below is what optimal stimulus spending looks like for different unemployment multipliers and elasticities of substitution between public and private consumption. For a more detailed discussion of the implications of this graph, go to page 1325 of [Michaillat and Saez (2019](https://www.pascalmichaillat.org/6.html)).

# In[15]:


stim_vals = stim_func(epsilon=params['epsilon'])
stim_vals_h = stim_func(epsilon=params['epsilon_h'])
stim_vals_l = stim_func(epsilon=params['epsilon_l'])
stim_range = pd.DataFrame(index=M_vals,
                          data={f'$\epsilon = ${params["epsilon_h"]}':stim_vals_h, 
                                f'$\epsilon = ${params["epsilon"]}':stim_vals,
                                f'$\epsilon = ${params["epsilon_l"]}':stim_vals_l})
stim_range_ax = stim_range.plot(title=r"Optimal Stimulus Spending", color=['red', 'blue', 'orange'])
stim_range_ax.set(xlabel='Unemployment Multiplier', ylabel='Optimal stimulus spending (% of GDP)', ylim=[0, 0.06])
stim_range_ax.yaxis.set_major_formatter(mtick.PercentFormatter(1.0, decimals=0))

