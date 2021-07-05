#!/usr/bin/env python
# coding: utf-8

# # Helper Functions
# 
# This section serves as a directory of the functions that are used in our calculations. 
# 
# # To-DOs
# - Clean up title/organization
# - finish calculating m
# - taking in params as argument instead of individual parameter

# ## Model Parameters

#  ### $\omega$   [![Generic badge](https://img.shields.io/badge/LMS18a-p.%20G28-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/5.html) 
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


# ### $\rho$
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


# ### $\bar{\tau}$
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


# ### q
# 
# The buying rate $q$, as a function of labor market tightness $x$, is:
# 
#                 $q(x(t)) = \frac{h(t)}{v(t)}=\omega x(t)^{-\eta}.$        [![Generic badge](https://img.shields.io/badge/MS19-p.%201305-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)  
#                 

# In[4]:


def q_func(x, omega, eta):
    return omega*x**(-eta)


# ### u
# 
# The rate of unemployment is:
# 
#                 $u(x) = \frac{s}{s+f(x)},$              [![Generic badge](https://img.shields.io/badge/MS19-Eq%202-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)  
# 
# where
# 
#                 $f(x) = \omega x^{1-\eta}.$             [![Generic badge](https://img.shields.io/badge/MS19-p.%201305-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html) 

# In[1]:


def u_func(x, s, eta, omega):
    f = omega*x**(1 - eta)
    return s/(s + f)


# ### $\tau$
# $\tau$ is the recruiter-producer ratio, where
# 
#                 $\tau(x) = \frac{\rho s}{q(x) - \rho s}. $              [![Generic badge](https://img.shields.io/badge/MS19-Eq%203-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html) 

# In[5]:


def tau_func(x, s, rho, q):
    return s*rho/(q - s*rho)


# ### $z_0$ and $z_1$
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


# ## Output Identity
# 
# ### Output
# 

# In[6]:


def Y_func(x, **params):
    s, eta, omega, k = params['s'], params['eta'], params['omega'], params['k']
    return (1 - u_func(x=x, eta=eta, omega=omega, s=s))*k


# ### Effect of Tightness on Output
# 
# From the output equation, we have:
# 
#                 $\frac{d\ln{y}}{d\ln{x}} = (1-\eta) * u(x) - \eta * \tau(x).$

# In[ ]:





# ### Ratios between Different Types of Consumption
# Since output consists of government spending and consumption, we have the following identities:

# In[ ]:


GY_func = lambda GC:GC/(1 + GC) # G/Y
CY_func = lambda GC:1 - GY(GC)  # C/Y
GC_func = lambda GY:GY/(1 - GY) # G/C


# ## Utility Function and its Derivatives

# ### Utility Function   [![Generic badge](https://img.shields.io/badge/MS19-p.%20A1~A2-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)
# 
# Given the elasticity of substitution between private and public consumption $\epsilon$, we have the following CES utility function:
# 
# 
#                 $\mathcal{U}(c, g) = \left((1-\gamma)^{1/\epsilon}c^{(\epsilon-1)/\epsilon} + \gamma ^{1/\epsilon}g^{(\epsilon - 1)/\epsilon}\right)^{\epsilon/(\epsilon - 1)}.$            [![Generic badge](https://img.shields.io/badge/MS19-Eq%208-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)  
# 
# When $\epsilon = 1$, the utility function is Cobb-Douglas:
# 
#                 $\mathcal{U}(c,g) = \frac{c^{1-\gamma} g^{\gamma}}{(1-\gamma)^{1-\gamma}\gamma^\gamma}.$
# 

# In[2]:


def U_func(c, g, **params):
    epsilon, gamma = params['epsilon'], params['gamma']
    if epsilon == 1:
        scalar = (1 - gamma)**(1 - gamma)*gamma**gamma
        return c**(1 - gamma)*g**(gamma)/scalar
    else:
        return ((1 - gamma)**(1/epsilon)*c**((epsilon - 1)/epsilon) + 
                gamma**(1/epsilon)*g**((epsilon - 1)/epsilon))**(epsilon/(epsilon - 1))


# ### Marginal Utility of Private Consumption

# From our utility function, we have:
# 
#                 $\frac{\delta \ln{\mathcal{U}}}{\delta \ln{c}} = (1-\gamma)^{{1/\epsilon}} \left(\frac{c}{\mathcal{U}}\right)^{\frac{\epsilon-1}{\epsilon}},\quad \mathcal{U}_c \equiv \frac{\delta \mathcal{U}}{\delta c} = \left((1-\gamma) \frac{\mathcal{U}}{c}\right)^{1/\epsilon}.$           [![Generic badge](https://img.shields.io/badge/MS19-p.%20A1-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)

# In[4]:


def dUdc_func(gc, **params):
    epsilon, gamma = params['epsilon'], params['gamma']
    return ((1-gamma)*U_func(1,gc))**(1/epsilon)
def dlnUdlnc(gc, **params):
    epsilon, gamma = params['epsilon'], params['gamma']
    return (1 - gamma)**(1/epsilon)*(U(1, gc))**((1 - epsilon)/epsilon)


# ### Marginal Utility of Public Consumption
# From our utility, we have:
# 
#                 $\mathcal{U}_g \equiv \frac{\delta \mathcal{U}}{\delta g} = \left(\gamma \frac{\mathcal{U}}{g}\right)^{1/\epsilon}.$           [![Generic badge](https://img.shields.io/badge/MS19-p.%20A1-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)

# In[5]:


def dlnUdlng_func(gc, **params):
    epsilon, gamma = params['epsilon'], params['gamma']
    return gamma**(1/epsilon)*(U(1/gc, 1))**((1 - epsilon)/epsilon)


# ### Marginal Rate of Substitution

# From the first-order derivates above, we have:
# 
#                 $MRS_{gc} = \frac{\mathcal{U}_g}{\mathcal{U}_c}  = \frac{\gamma^{1/\epsilon}}{(1-\gamma)^{1/\epsilon}}*(gc)^{1/\epsilon}.$
#                

# In[16]:


def MRS_func(gc, **params):
    epsilon, gamma = params['epsilon'], params['gamma']
    return gamma**(1/epsilon)/(1-gamma)**(1/epsilon)*gc**(-1/epsilon)


# ### Derivatives of Marginal Utility of Private Consumption
# 
# We also have the following:
# 
#                 $\frac{\delta \ln{\mathcal{U}_c}}{\delta \ln{c}} = \frac{1}{\epsilon}\left(\frac{\delta \mathcal{U}}{\delta c} -1 \right),$                      
# 
#                 $\frac{\delta \ln{\mathcal{U}_c}}{\delta \ln{g}} = \frac{1}{\epsilon}\left(\frac{\delta \mathcal{U}}{\delta g} \right).$                        [![Generic badge](https://img.shields.io/badge/MS19-p.%20A2-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)

# In[4]:


def dlnUcdlnc_func(gc, **params):
    epsilon = params['epsilon']
    return (dlnUdlnc_func(gc, **params) - 1)/epsilon
def dlnUcdlng_func(gc, **params):
    epsilon = params['epsilon']
    return dlnUdlng_func(gc, **params)/epsilon


# ## Prices  [![Generic badge](https://img.shields.io/badge/MS19-p.%20A2~A3-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)
# 
# ### Price Mechanism
# 
# We have the foloowing price mechanism. It is rigid since it does not respond to demand shocks, and is an expression of the multiplier:
# 
#                 $p(G) = p_0 \left\{ (1-\gamma) + \gamma ^{\frac{1}{\epsilon}}\left[(1-\gamma)\frac{g}{y^*-g}\right]^{\frac{\epsilon-1}{\epsilon}}\right \}^\frac{1-r}{\epsilon - 1}.$   [![Generic badge](https://img.shields.io/badge/MS19-Eq%2015-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)

# In[2]:


def p_func(G, **params):
    r, p0, Y_bar = params['r'], params['p0'], params['Y_bar']
    return p0*dUdc_func(gc=G/(Y_bar-G), **params)**(1 - r)


# ### Effects of Public Consumption on Prices
# 
# From the price mechanism, we have:
# 
#                 $\frac{d\ln{p}}{d\ln{g}} = (1-r) \left[ \frac{\delta\ln{\mathcal{U}_c}}{\delta \ln{g}} - \frac{G}{y^* - G} \frac{\delta\ln{\mathcal{U}_c}}{\delta \ln{c}}  \right].$      [![Generic badge](https://img.shields.io/badge/MS19-Eq%20A4-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)

# In[ ]:


def dlnpdlng_func(G, **params):
    r,  Y_bar = params['r'],  params['Y_bar']
    return (1 - r)*(dlnUcdlng_func(gc=G/(Y_bar - G), **params) - dlnUcdlnc(gc=G/(Y_bar - G), params)*(G/(Y_bar - G)))


# ## Unemployment Multipliers
# ### $m$
# 
# $m$ is the theoretical unemployment multiplier, which measures the response of unemployment to changes in public consumption. $m$ can be calculated in two ways. For a given $M$, $m$ can be calculated as:
# 
#                 $ m = \frac{(1-u)\cdot M}{1- \frac{G}{Y}\cdot \frac{\eta}{1-\eta}\cdot \frac{\tau}{u}\cdot M},$          [![Generic badge](https://img.shields.io/badge/MS19-Eq%2026-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)

# $m$ can also be calculated with the effect of public consumption on equilibrium tightness:
# 
#                 $m = (1-\eta) (1-u) u \frac{y}{g}\frac{d\ln{x}}{d\ln{g}}.$     [![Generic badge](https://img.shields.io/badge/MS19-Eq%2021-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)
# 
# The effect of public consumption on equilibrium tightness is given by the following equation:
# 
#                 $\frac{\delta\ln{x}}{\delta \ln{g}} = \frac{(g/y) + (c/y)\delta\ln{c}/\delta\ln{g}}{\delta\ln{y}/\delta\ln{x} - (c/y)\delta\ln{c}/\delta\ln{x}},$    [![Generic badge](https://img.shields.io/badge/MS19-Eq%20A9-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)
# 
# where 
# 
#                 $\frac{\delta\ln{c}}{\delta \ln{x}} = \frac{\eta \tau(x)}{\delta \ln{\mathcal{U}_c}/\delta\ln(c)},$         [![Generic badge](https://img.shields.io/badge/MS19-Eq%20A6-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)
# 
# 
#                 $\frac{\delta\ln{c}}{\delta \ln{g}} = \frac{d \ln{p}/d\ln(g) - \delta \ln{\mathcal{U}_c}/\delta\ln(g)}{\delta \ln{\mathcal{U}_c}/\delta\ln(c)}.$    [![Generic badge](https://img.shields.io/badge/MS19-Eq%20A7-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)

# In[7]:


def m_func(which, **params):
    if which == 'M':
        u, M, GY, eta, tau = params['u'], params['M'], params['GY'], params['eta'], params['tau']
        return (1 - u)*M/(1 - GY*eta/(1 - eta)*tau/u*M)
    elif which == 'dlnxdlng':
        G, x, s, rho, omega, eta = params['G'], params['x'], params['s'], params['rho'], params['omega'], params['eta']
        q = q_func(x=x, omega=omega, eta=eta)
        u = u_func(x=x, s=s, eta=eta, omega=omega)
        tau = tau_func(s=s, rho=rho, q=q)
        dlncdlnx = eta*tau/dlnUcdlnc_func(gc=G/(Y(x)-G), **params)
        dlncdlng = (dlnpdlng_func(G=G, **params)-dlnUcdlng_func(gc=G/(Y(x)-G), **params))/dlnUcdlnc_func(gc=G/(Y(x)-G), **params)
        dlnxdlng = (G/Y(x) + (1 - G/Y(x))*dlncdlng)/(dlnydlnx(x=x, **params) - (1-G/Y(x))*dlncdlnx)
        return (1 - eta)*u*(1 - u)*dlnxdlng*Y_func(x)/G 


# ### $M$
# Then, we can compute the empirical unemployment multiplier
# 
#                 $M = \frac{m}{1- u + \frac{g}{y}\frac{\eta}{1-\eta}\frac{\tau}{u}m}.$                         [![Generic badge](https://img.shields.io/badge/MS19-Eq%20A11-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)
# 

# In[20]:


def M_func(G, x):
    s, rho, omega, eta = params['s'], params['rho'], params['omega'], params['eta']
    q = q_func(x=x, omega=omega, eta=eta)
    u = u_func(x=x, s=s, eta=eta, omega=omega)
    return m(G, x)/(1 - u + G/Y(x)*eta*tau(s=s, rho=rho, q=q)/(1 - eta)/u*m(G, x))


# ## Calculating Equilibrium Labor Market Tightness
# 
# To determine equilibrium under different aggregate demand/government spending, we need to find where aggreagte demand is equal to aggregate supply, which happens when 
# 
#                 $\frac{dU}{dc} - G = (1+\tau)\frac{p(G)}{\alpha}$                       [![Generic badge](https://img.shields.io/badge/MS19-Eq%2013-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)
#                 
# First, we derive the marginal utility of consumption. 
# 
# Given the elasticity of substitution between private and public consumption $\epsilon$, we have the following CES utility function:
# 
# 
#                 $\mathcal{U}(c, g) = \left((1-\gamma)^{1/\epsilon}c^{(\epsilon-1)/\epsilon} + \gamma ^{1/\epsilon}g^{(\epsilon - 1)/\epsilon}\right)^{\epsilon/(\epsilon - 1)}.$            [![Generic badge](https://img.shields.io/badge/MS19-Eq%208-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)  
# 
# When $\epsilon = 1$, the utility function is Cobb-Douglas:
# 
#                 $\mathcal{U}(c,g) = \frac{c^{1-\gamma} g^{\gamma}}{(1-\gamma)^{1-\gamma}\gamma^\gamma}.$
# 
# This gives us that:
# 
#                 $\mathcal{U}_c \equiv \frac{\delta \mathcal{U}}{\delta c} = \left((1-\gamma) \frac{\mathcal{U}}{c}\right)^{1/\epsilon}.$
#                 
# We also have the following pricing mechanism:
# 
#                 $p(G) = p_0 \left\{ (1-\gamma) + \gamma ^{\frac{1}{\epsilon}}\left[(1-\gamma)\frac{g}{y^*-g}\right]^{\frac{\epsilon-1}{\epsilon}}\right \}^\frac{1-r}{\epsilon - 1}.$   [![Generic badge](https://img.shields.io/badge/MS19-Eq%2015-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)
#                 
# We now define the following function such that the function returns zero when the economy is at equilibrium.

# In[ ]:


def find_eq(G, x, alpha, **params):
    s, rho, omega, eta = params['s'], params['rho'], params['omega'], params['eta']
    q = q_func(x=x, omega=omega, eta=eta)
    return abs(dUdc_func(G/(Y_func(x) - G, params)) - ((1 + tau(s=s, rho=rho, q=q))*p(G)/alpha))


# ## Optimal Stimulus
# 
# ### The Sufficient Statistics Approach
# 
# The sufficient-statistics formula is as follows:
# 
#                 $\frac{g/c - (g/c)^*}{(g/c)^*} \approx \frac{z_0 \epsilon m}{1 + z_1 z_0\epsilon m^2}\cdot \frac{u_0 - \bar{u}}{\bar{u}}.$          [![Generic badge](https://img.shields.io/badge/MS19-Eq%2023-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)  

# In[ ]:


def suffstat_func(u0, u_bar, z0, z1, m, epsilon):
    du = (u0 - u_bar)/u_bar
    return epsilon*z0*m/(1 + z1*z0*epsilon*m**2)*du

