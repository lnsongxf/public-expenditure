#!/usr/bin/env python
# coding: utf-8

# # Additional Calibration
# 
# This section calibrates additional parameters used for business cycle simulations. 
# 
# Before we start, we import the libraries we need and read in the helper functions.

# In[5]:


import pandas as pd
get_ipython().run_line_magic('run', 'helpers.ipynb')


# We also read in the calibrated parameters:

# In[6]:


params = pd.read_csv('output/params_suffstat.csv')
params = dict(params.values)
params


# ## Calibration of $\bar{Y}$
# 
# First, we calculate the average output. When calculating output, we use the following equation: 
# 
#                 $Y(x, k) = \frac{f(x)}{s+f(x)}k = (1-u(x))\cdot k,$                [![Generic badge](https://img.shields.io/badge/MS19-Eq%201-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)    
# 
# with the normalization $k = 1$.

# In[7]:


k = 1
Y_bar = k*(1 - params['u_bar'])


# ## Calibration of $\gamma$
# 
# We now calibrate the preference parameter $\gamma$. When the Samuelson rule holds:
# 
#                 $(g/c)^* = \frac{\gamma}{1-\gamma}.$                [![Generic badge](https://img.shields.io/badge/MS19-Eq%20A1-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)    
# 

# In[8]:


gamma = 1/(1 + 1/params['GC_bar']) 


# ## Calibration of $r$
# 
# $r$ is the price rigidity.  At the efficient level, we have that
# 
#                 $M = \frac{r}{\gamma r + (1-\gamma)\epsilon},$                [![Generic badge](https://img.shields.io/badge/MS19-Eq%20A4-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)    
# 
# 
# which implies that:
# 
#                 $r = \frac{(1-\gamma)\epsilon M}{1 - \gamma M} = \frac{\overline{C/Y}\epsilon M}{1 - \overline{G/Y} M}.$                

# In[9]:


CY_bar = CY_func(GC=params['GC_bar'])
r = (params['M_bar']*params['epsilon']*CY_bar)/(1 - params['M_bar']*params['GY_bar'])


# ## Calibration of $p_0$
# We also need to calibrate the initial price level $p_0$ for the price mechanism $p(G)$. 
# 
# Looking at private demand, we have: 
# 
#                 $\mathcal{U}_c = (1+\tau(x))p\alpha$.                [![Generic badge](https://img.shields.io/badge/MS19-Eq%2013-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)    
# 
# Thus, with $\alpha = 1$, at the efficient level, we have that:
# 
#                 $p_0 = \frac{\overline{\mathcal{U}_c}}{1+\bar\tau}$. 

# In[11]:


dUdc_bar = dUdc_func(gc=params['GC_bar'], gamma=gamma, **params)
p0 = dUdc_bar**r/(1 + params['tau']) 


# ## Storing Calibrated Values
# We now store the newly calibrated parameters and proceed to run our simulations.

# In[12]:


pd.DataFrame({'Name':['k', 'Y_bar', 'gamma', 'CY_bar', 'r', 'p0'],
              'Value':[k, Y_bar, gamma, CY_bar, r, p0]}).to_csv('output/params_sim.csv', index=False)

