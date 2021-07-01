#!/usr/bin/env python
# coding: utf-8

# # Additional Calibration
# 
# This section implements additional calibration of the supply and demand side of the matching model. The additional calibration calculates additional parameters such as target macroeconomic variables, price rigidities, and different elasticities on the supply and demand sides that are needed for the simulations. 

# ## Additional Parameters
# We want to first calculate the additional parameters needed for the simulations. 
# 1. $\bar{Y}$ : average output
# 1. $\gamma$ : preference parameter
# 1. $k$ : productive capacity, which can also be endogenized by adding a labor market where firms hire workers

# In[9]:


k = 1 # normalization
Y_bar = k*(1 - u_bar)
gamma = 1/(1 + 1/GC_bar) 


# For convenience, we define the functions to calculate key macroeconomic variables  $G/Y, C/Y$, and $G/C$. The expressions for them simply follow from accounting identity.    

# In[10]:


GY = lambda gc:gc/(1 + gc) # G/Y
CY = lambda gc:1 - GY(gc)  # C/Y
GC = lambda GY:GY/(1 - GY) # G/C


# We then use these functions to calculate target macroeconomic variables.

# In[11]:


GY_bar = GY(GC_bar)
CY_bar = CY(GC_bar)
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


r = (M_bar*epsilon*CY_bar)/(1 - M_bar*GY_bar)


# We now move to derive functions that are useful for finding equilibrium labor market tightness and government spending. We do this by looking at both the supply side and the demand side of the economy.  

# ## Supply Side   [![Generic badge](https://img.shields.io/badge/MS19-Section%202.2-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)
# 
# We set up the following functions for the supply side of our model. 
# 
# The buying rate $q$, as a function of labor market tightness $x$, is:
# 
#                 $q(x(t)) = \frac{h(t)}{v(t)}=\omega x(t)^{-\eta}.$        [![Generic badge](https://img.shields.io/badge/MS19-p.%201305-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)  
#                 
# The selling rate $f$, as a function of labor market tightness $x$, is:
# 
#                 $f(x) = \omega x^{1-\eta}.$             [![Generic badge](https://img.shields.io/badge/MS19-p.%201305-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html) 
#                 
# The matching wedge $\tau$ is:
# 
#                 $\tau(x) = \frac{\rho s}{q(x) - \rho s}, $             [![Generic badge](https://img.shields.io/badge/MS19-Eq%203-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html) 

# In[13]:


q = lambda x:omega*x**(-eta) #buying rate
f = lambda x:omega*x**(1 - eta) #selling rate
tau = lambda x:s*rho/(q(x) - s*rho) #matching wedge


# We can also calculate the elasticity of output to tightness. 
# 
# First, we have that unemployment rate is: 
# 
#                 $u(x) = \frac{s}{s+f(x)}.$              [![Generic badge](https://img.shields.io/badge/MS19-Eq%202-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)  
#                 
# 
# Also, output is given by:
# 
#                 $Y(x, k) = \frac{f(x)}{s+f(x)}k = (1-u(x))\cdot k.$    [![Generic badge](https://img.shields.io/badge/MS19-Eq%201-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html) 
# 
# Thus, the elasticity of output to tightness is:
# 
#                 $\frac{d\ln{y}}{d\ln{x}} = (1-\eta) * u(x) - \eta * \tau(x).$

# In[14]:


u = lambda x:s/(s + f(x))  # unemployment rate
Y = lambda x:(1 - u(x))*k  # output
dlnydlnx = lambda x:(1-eta)*u(x) - eta*tau(x) #elasticity of output to tightness


# ## Demand Side and Equilibrium   [![Generic badge](https://img.shields.io/badge/MS19-Appendix%20A-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)
# 
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

# In[15]:


if epsilon == 1:
    scalar = (1 - gamma)**(1 - gamma)*gamma**gamma
    U = lambda c, g:c**(1 - gamma)*g**(gamma)/scalar
else:
    U = lambda c, g:((1 - gamma)**(1/epsilon)*c**((epsilon - 1)/epsilon) + 
                     gamma**(1/epsilon)*g**((epsilon - 1)/epsilon))**(epsilon/(epsilon - 1))


# With the given utility function, we have the following first derivatives:
# 
#                 $\frac{\delta \ln{\mathcal{U}}}{\delta \ln{c}} = (1-\gamma)^{{1/\epsilon}} \left(\frac{c}{\mathcal{U}}\right)^{\frac{\epsilon-1}{\epsilon}},\quad \mathcal{U}_c \equiv \frac{\delta \mathcal{U}}{\delta c} = \left((1-\gamma) \frac{\mathcal{U}}{c}\right)^{1/\epsilon},$
# 
#                 $\frac{\delta \ln{\mathcal{U}}}{\delta \ln{g}} = \gamma^{{1/\epsilon}} \left(\frac{g}{\mathcal{U}}\right)^{\frac{\epsilon-1}{\epsilon}},\quad \mathcal{U}_g \equiv \frac{\delta \mathcal{U}}{\delta g} = \left(\gamma \frac{\mathcal{U}}{g}\right)^{1/\epsilon}.$           [![Generic badge](https://img.shields.io/badge/MS19-p.%20A1-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)
# 
# which gives the marginal rate of substitution:
# 
#                 $MRS_{gc} = \frac{\mathcal{U}_g}{\mathcal{U}_c}  = \frac{\gamma^{1/\epsilon}}{(1-\gamma)^{1/\epsilon}}*(gc)^{1/\epsilon}.$
# 
# We also have the following second derivatives:
# 
#                 $\frac{\delta \ln{\mathcal{U}_c}}{\delta \ln{c}} = \frac{1}{\epsilon}\left(\frac{\delta \mathcal{U}}{\delta c} -1 \right),$                      
# 
#                 $\frac{\delta \ln{\mathcal{U}_c}}{\delta \ln{g}} = \frac{1}{\epsilon}\left(\frac{\delta \mathcal{U}}{\delta g} \right).$                        [![Generic badge](https://img.shields.io/badge/MS19-p.%20A2-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)
#                 
# These derivatives are useful for calculating unemployment multipliers.

# In[16]:


dUdc = lambda gc:((1-gamma)*U(1,gc))**(1/epsilon)
dUdc_bar = dUdc(GC_bar)
dUdg = lambda gc:(gamma*U(1/gc, 1))**(1/epsilon)
MRS = lambda gc:gamma**(1/epsilon)/(1-gamma)**(1/epsilon)*gc**(-1/epsilon)
dlnUdlnc = lambda gc:(1 - gamma)**(1/epsilon)*(U(1, gc))**((1 - epsilon)/epsilon)
dlnUdlng = lambda gc:gamma**(1/epsilon)*(U(1/gc, 1))**((1 - epsilon)/epsilon)
dlnUcdlnc = lambda gc:(dlnUdlnc(gc) - 1)/epsilon
dlnUcdlng = lambda gc:dlnUdlng(gc)/epsilon


# ### Unemployment Multipliers   [![Generic badge](https://img.shields.io/badge/MS19-p.%20A2~A3-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)
# 
# We now move on to compute the theoretical unemployment multiplier and the output multiplier.
# 
# First, we want to compute the effect of public consumption on the price of services, which requires us to look at the price mechanism. It is rigid since it does not respond to demand shocks, and is an expression of the multiplier:
# 
#                 $p(G) = p_0 \left\{ (1-\gamma) + \gamma ^{\frac{1}{\epsilon}}\left[(1-\gamma)\frac{g}{y^*-g}\right]^{\frac{\epsilon-1}{\epsilon}}\right \}^\frac{1-r}{\epsilon - 1}.$   [![Generic badge](https://img.shields.io/badge/MS19-Eq%2015-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)
# 
# which gives us:
# 
#                 $\frac{d\ln{p}}{d\ln{g}} = (1-r) \left[ \frac{\delta\ln{\mathcal{U}_c}}{\delta \ln{g}} - \frac{G}{y^* - G} \frac{\delta\ln{\mathcal{U}_c}}{\delta \ln{c}}  \right].$      [![Generic badge](https://img.shields.io/badge/MS19-Eq%20A4-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)

# In[17]:


# initial price level
p0 = dUdc_bar**r/(1 + tau_bar) 
p = lambda G:p0*dUdc(G/(Y_bar-G))**(1 - r)
dlnpdlng = lambda G:(1 - r)*(dlnUcdlng(G/(Y_bar - G)) - dlnUcdlnc(G/(Y_bar - G))*(G/(Y_bar - G)))


# Then we want to compute the effects of public consumption and tightness on private demand, which are:
# 
#                 $\frac{\delta\ln{c}}{\delta \ln{x}} = \frac{\eta \tau(x)}{\delta \ln{\mathcal{U}_c}/\delta\ln(c)},$                        [![Generic badge](https://img.shields.io/badge/MS19-Eq%20A6-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)
# 
# and
# 
#                 $\frac{\delta\ln{c}}{\delta \ln{g}} = \frac{d \ln{p}/d\ln(g) - \delta \ln{\mathcal{U}_c}/\delta\ln(g)}{\delta \ln{\mathcal{U}_c}/\delta\ln(c)}.$                   [![Generic badge](https://img.shields.io/badge/MS19-Eq%20A7-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)
# 
# 

# In[18]:


dlncdlnx = lambda G, x:eta*tau(x)/dlnUcdlnc(G/(Y(x)-G))
dlncdlng = lambda G, x:(dlnpdlng(G)-dlnUcdlng(G/(Y(x)-G)))/dlnUcdlnc(G/(Y(x)-G))


# We can also determine the effect of public consumption on equilibrium tightness, which is:
# 
#                 $\frac{\delta\ln{x}}{\delta \ln{g}} = \frac{(g/y) + (c/y)\delta\ln{c}/\delta\ln{g}}{\delta\ln{y}/\delta\ln{x} - (c/y)\delta\ln{c}/\delta\ln{x}}.$                   [![Generic badge](https://img.shields.io/badge/MS19-Eq%20A9-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)

# In[19]:


dlnxdlng = lambda G, x:(G/Y(x) + (1 - G/Y(x))*dlncdlng(G, x))/(dlnydlnx(x) - (1-G/Y(x))*dlncdlnx(G, x))


# Thus, we can compute the theoretical unemployment multiplier
# 
#                 $m = (1-\eta) (1-u) u \frac{y}{g}\frac{d\ln{x}}{d\ln{g}},$
# 
# and the empirical unemployment multiplier
# 
#                 $M = \frac{m}{1- u + \frac{g}{y}\frac{\eta}{1-\eta}\frac{\tau}{u}m}.$                         [![Generic badge](https://img.shields.io/badge/MS19-Eq%20A11-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)
# 

# In[20]:


m = lambda G, x:(1 - eta)*u(x)*(1 - u(x))*dlnxdlng(G, x)*Y(x)/G 
M = lambda G, x:m(G, x)/(1 - u(x) + G/Y(x)*eta*tau(x)/(1 - eta)/u(x)*m(G, x))


# ### Equilibrium Tightness and Public Spending
# 
# To determine equilibrium under different aggregate demand/government spending, we need to find where aggreagte demand is equal to aggregate supply, which happens when 
# 
#                 $\frac{dU}{dc} - G = (1+\tau)\frac{p(G)}{\alpha}$                       [![Generic badge](https://img.shields.io/badge/MS19-Eq%2013-purple?logo=read-the-docs)](https://www.pascalmichaillat.org/6.html)

# In[21]:


findeq = lambda G, x, alpha:abs(dUdc(G/(Y(x) - G)) - ((1 + tau(x))*p(G)/alpha))


# We can now proceed to run our simulations.
