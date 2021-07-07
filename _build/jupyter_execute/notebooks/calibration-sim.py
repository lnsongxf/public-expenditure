#!/usr/bin/env python
# coding: utf-8

# # Additional Calibration
# 
# This section implements additional parameters needed for business cycle simulation. 
# 
# Before we start, we read in the calibrated parameters and the helper functions.

# In[11]:


get_ipython().run_line_magic('store', '-r params')
get_ipython().run_line_magic('run', 'helpers.ipynb')
params


# ## Calibration of $\bar{Y}$
# 
# First, we calculate average output. When calculating output, we use the following equation: 
# 
#                 $Y(x, k) = \frac{f(x)}{s+f(x)}k = (1-u(x))\cdot k,$                [![Generic badge](https://img.shields.io/badge/MS19-Eq%201-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)    
# 
# with the normalization $k = 1$
# 
# 1. $\gamma$ : preference parameter
# 1. $k$ : productive capacity, which can also be endogenized by adding a labor market where firms hire workers

# In[12]:


params['k'] = 1
params['Y_bar'] = params['k']*(1 - params['u_bar'])


# ## Calibration of $\gamma$
# 
# We now calibrate the preference parameter $\gamma$. When the Samuelson rule holds:
# 
#                 $(g/c)^* = \frac{\gamma}{1-\gamma}.$                [![Generic badge](https://img.shields.io/badge/MS19-Eq%20A1-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)    
# 

# In[13]:


params['gamma'] = 1/(1 + 1/params['GC_bar']) 


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

# In[14]:


CY_bar = CY_func(GC=params['GC_bar'])
params['r'] = (params['M_bar']*params['epsilon']*CY_bar)/(1 - params['M_bar']*params['GY_bar'])


# ## Calibration of $p_0$
# We also need to calibrate the initial price level $p_0$ for the price mechanism. 
# 
# Looking at private demand, we have: 
# 
#                 $\mathcal{U}_c = (1+\tau(x))p\alpha$.                [![Generic badge](https://img.shields.io/badge/MS19-Eq%2013-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)    
# 
# Thus, at the efficient level with $\alpha = 1$:
# 
#                 $p_0 = \frac{\overline{\mathcal{U}_c}}{1+\bar\tau}$. 

# In[15]:


dUdc_bar = dUdc_func(gc=params['GC_bar'], **params)
params['p0'] = dUdc_bar**params['r']/(1 + params['tau']) 


# We now store the updated parameters and proceed to run our simulations.

# In[16]:


params_full = params
get_ipython().run_line_magic('store', 'params_full')

