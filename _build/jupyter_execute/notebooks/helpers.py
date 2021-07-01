#!/usr/bin/env python
# coding: utf-8

# # Helper Functions
# 
# This section serves as a directory of the functions that are used in our calculations. 

# ## Model Parameters

#  ### Calculation of $\omega$   [![Generic badge](https://img.shields.io/badge/LMS18a-p.%20G28-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/5.html) 
# 
#  
# The parameter $\omega$ denotes matching efficacy in the matching function. 
# 
# We calculate $\omega$ by using the following equation: 
# 
#                 $\omega = \bar{x}^{\eta - 1}\cdot \frac{s\cdot (1-\bar{u})}{\bar{u}\cdot e}, $            [![Generic badge](https://img.shields.io/badge/MS19-Eq%203-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)  
#      
# where $e$ is the average job-search effort, which is normalized to $1$. 

# In[1]:


def omega_func(eta, x_bar, u_bar, e=1):
    return x_bar**(eta - 1)*s*(1 - u_bar)/(u_bar*e)


# ### Calculation of $\rho$
# 
# To calculate $\rho$, we use the following relationship between the recruiter-producer ratio ($\tau$) and labor market tightness ($x$):
# 
#                 $\tau(x) = \frac{\rho s}{q(x) - \rho s}. $              [![Generic badge](https://img.shields.io/badge/MS19-Eq%203-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)  
#                 
# This gives us that:
# 
#                 $\rho = \frac{\omega x^{-\eta}\tau}{(1+\tau)s}.$
#                 

# In[2]:


def rho_func(eta, s, u, x, omega, tau):
    return omega*x**(-1*eta)*tau/((1 + tau)*s)


# ### Calculation of $\bar{\tau}$
# When labor market tightness is efficient, we have:
# 
#                 $(1-\eta)\bar{u}-\eta\bar{\tau} = 0, $            [![Generic badge](https://img.shields.io/badge/MS19-Eq%205-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)  
# 
# which can be re-arranged into:
# 
#                 $\bar{\tau} = \frac{(1-\eta)\bar{u}}{\eta}.$ 

# In[3]:


def tau_bar_func(eta, u_bar):
    return (1 - eta)*u_bar/eta


# ### Calculation of q
# 
# The buying rate $q$, as a function of labor market tightness $x$, is:
# 
#                 $q(x(t)) = \frac{h(t)}{v(t)}=\omega x(t)^{-\eta}.$        [![Generic badge](https://img.shields.io/badge/MS19-p.%201305-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)  
#                 

# In[4]:


def q_func(x, omega, eta):
    return omega*x**(-eta)


# ### Calculation of $\tau$
# $\tau$ is the recruiter-producer ratio, where
# 
#                 $\tau(x) = \frac{\rho s}{q(x) - \rho s}. $              [![Generic badge](https://img.shields.io/badge/MS19-Eq%203-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html) 

# In[5]:


def tau_func(s, rho, q):
    return s*rho/(q - s*rho)


# ### Calculation of Output Identity
# 
# Since output consists of government spending and consumption, we have the following identities:

# In[6]:


GY_func = lambda GC:GC/(1 + GC) # G/Y
CY_func = lambda GC:1 - GY(GC)  # C/Y
GC_func = lambda GY:GY/(1 - GY) # G/C


# ### Calculation of $m$
# 
# $m$ is the theoretical unemployment multiplier, which measures the response of unemployment to changes in public consumption. $m$ is calculated by using the following equation:
# 
#                 $ m = \frac{(1-u)\cdot M}{1- \frac{G}{Y}\cdot \frac{\eta}{1-\eta}\cdot \frac{\tau}{u}\cdot M},$          [![Generic badge](https://img.shields.io/badge/MS19-Eq%2026-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)

# In[7]:


def m_func(M, eta, u, GY, tau):
    return (1 - u)*M/(1 - GY*eta/(1 - eta)*tau*u*M)


# ## Calculation of $z_0$ and $z_1$
# 
# $z_0$ and $z_1$ can be calculated by using the following equations:
# 
#                 $z_0 = \frac{1}{(1-\eta)(1-\bar{u})^2},$         [![Generic badge](https://img.shields.io/badge/MS19-p.%201315-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)  
# 
# and 
# 
# 
#                 $z_1 = \frac{\overline{g/y}\cdot \overline{c/y}}{\bar{u}}.$           [![Generic badge](https://img.shields.io/badge/MS19-p.%201316-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)  

# In[8]:


def z0_func(eta, u_bar):
    return 1/((1 - eta)*(1 - u_bar)**2)
def z1_func(GY_bar, u_bar):
    return GY_bar*(1 - GY_bar)/u_bar

