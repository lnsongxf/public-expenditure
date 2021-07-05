#!/usr/bin/env python
# coding: utf-8

# # Additional Calibration
# 
# This section implements additional calibration of the supply and demand side of the matching model. The additional calibration calculates additional parameters such as target macroeconomic variables, price rigidities, and different elasticities on the supply and demand sides that are needed for the simulations. 
# 
# First, we read in the calibrated parameters.

# In[6]:


get_ipython().run_line_magic('store', '-r params')
params


# ## Additional Parameters
# We want to first calculate the additional parameters needed for the simulations. 
# 1. $\bar{Y}$ : average output
# 1. $\gamma$ : preference parameter
# 1. $k$ : productive capacity, which can also be endogenized by adding a labor market where firms hire workers

# In[9]:


k = 1 # normalization
Y_bar = k*(1 - params['u_bar'])
gamma = 1/(1 + 1/params['GC_bar']) 


# In[11]:


GY_bar = GY_func(params['GC_bar'])
CY_bar = CY_func(params['GC_bar'])
G_bar = GY_bar*Y_bar
C_bar = CY_bar*Y_bar


# We can also calculate the price rigidity $r$. At the efficient level, we have that
# 
#                 $M = \frac{r}{\gamma r + (1-\gamma)\epsilon},$              [![Generic badge](https://img.shields.io/badge/MS19-Eq%20A4-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)  
# 
# which implies that:
# 
#                 $r = \frac{(1-\gamma)\epsilon M}{1 - \gamma M} = \frac{\overline{C/Y}\epsilon M}{1 - \overline{G/Y} M}.$

# In[12]:


r = (params['M_bar']*params['epsilon']*CY_bar)/(1 - params['M_bar']*GY_bar)


# In[ ]:


dUdc_bar = dUdc(GC_bar)
p0 = dUdc_bar**r/(1 + tau_bar) 


# In[14]:


u = lambda x:s/(s + f(x))  # unemployment rate
Y = lambda x:(1 - u(x))*k  # output
dlnydlnx = lambda x:(1-eta)*u(x) - eta*tau(x) #elasticity of output to tightness


# ### Equilibrium Tightness and Public Spending
# 
# To determine equilibrium under different aggregate demand/government spending, we need to find where aggreagte demand is equal to aggregate supply, which happens when 
# 
#                 $\frac{dU}{dc} - G = (1+\tau)\frac{p(G)}{\alpha}$                       [![Generic badge](https://img.shields.io/badge/MS19-Eq%2013-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)

# In[21]:


findeq = lambda G, x, alpha:abs(dUdc(G/(Y(x) - G)) - ((1 + tau(x))*p(G)/alpha))


# We can now proceed to run our simulations.
