#simulate random data
set.seed(40)
x1 <- runif(40, min = 20, max = 34)
epsilon <- rnorm(40, mean = 0, sd = 1)
y <- x1^2 + epsilon

#put it into a dataframe
raw_data <- data.frame(x1, y)

#Plot raw data
library(ggplot2)
raw_plot <- ggplot(raw_data, aes(x1, y)) + geom_point() + theme_classic() + xlab('Temperature') + ylab('Metabolic Rate')
raw_plot


#Maxmimum Likelihood Approaches for fitting the models and optimizing parameters

#Maximum likelihood approach using a linear model
Linear_max <- function(p, X, Y) {
  b0 <- p[1]; b1 <- p[2]; sd <- p[3]
  
  rsd <- (b0 + b1 * X ) - Y
  
  -sum(dnorm(rsd, mean = 0, sd = sd, log = T)) 
}

linear_optim <- optim(c(1, 0, 5), Linear_max, X = x1, Y = y)
linear_optim

#Maximum likelihood approach for the quadratic function
Quadratic_max <- function(p, X, Y) {
  a <- p[1]; b <- p[2]; c <- p[3]
  
  rsd2 <- (a * (X^2) + b * X + c) - Y
  
  -sum(dexp(rsd2, rate = X/Y, log = T))
}

quadratic_optim <- optim(c(1, 1, 1), Quadratic_max, X = x1, Y = y)
quadratic_optim

#Maximum likelihood approach for the Gaussian function
Gaussian_max <- function(p, X, Y) {
  a <- p[1]; b <- p[2]; c <- p[3]; sd <- p[4]
  
  rsd3 <- a * (exp( ((-0.5) * ((abs(X - b)) / c )^2))) - Y
  
  -sum(dnorm(rsd3, mean = 0, sd = sd, log = T)) 
}

gaussian_optim <- optim(c(0, 0, 0, 1), Gaussian_max, X = x1, Y = y)
gaussian_optim

#Maximum likelihood approach for the modified Gaussian function
modGaussian_max <- function(p, X, Y) {
  a <- p[1]; b <- p[2]; c <- p[3]; d <- p[4]; sd <- p[5]
  
  rsd4 <- a * (exp( ((-0.5) * ((abs(X - b)) / c )^d))) - Y
  
  -sum(dnorm(rsd4, mean = 0, sd = sd, log = T)) 
}

modgaussian_optim <- optim(c(0, 0, 0, 2, 1), modGaussian_max, X = x1, Y = y)
modgaussian_optim

#Maximum likelihood approach for the Weibull function
Weibull_max <- function(p, X, Y) {
  a <- p[1]; b <- p[2]; c <- p[3]; d <- p[4]; sd <- p[5]
  
  rsd5 <- ((a * (((d - 1) / d)^((1 - d) / d)) * (((X - b) / c) + ((d - 1) / d)^(1 / d))^(d - 1) *     (exp(-(((X - b) / c) + ((d - 1) / d)^(1 / d))^d)) ) + ((d-1) / d) ) - Y
  
  -sum(dnorm(rsd5, mean = 0, sd = sd, log = T)) 
}

weibull_optim <- optim(c(1, 1, 1, 2, 1), Weibull_max, X = x1, Y = y)
weibull_optim

#Collect log-likelihood values and the number of parameters of each model into vectors

#Likelihood values (mod_LLs)
mod_LLs <- c(linear_optim$value, quadratic_optim$value, gaussian_optim$value, modgaussian_optim$value, weibull_optim$value)

#Number of model parameters for each model above (mod_pars)
mod_pars <- c(length(linear_optim$par), length(quadratic_optim$par), length(gaussian_optim$par), length(modgaussian_optim$par), length(weibull_optim$par))

#Calculate AIC values for each model:
mod_AICs <- cbind(c('linear', 'quadratic', 'gaussian', 'modgaussian', 'weibull'),(2 * log(mod_LLs)) + 2 * (mod_pars) ) 
mod_AICs

#Graphing the best models onto the raw data

#Build their equations using the parameters from the MLE
#Linear Model
linear_eq <- function(x) (linear_optim$par[2] * x) + linear_optim$par[1]

#Quadratic Model
quadratic_eq <- function(x) (quadratic_optim$par[1] * (x^2)) + (quadratic_optim$par[2] * x) +   quadratic_optim$par[3] 


#Layer them on the raw data
model_plot <- raw_plot + stat_function(fun = linear_eq, color = 'blue') + stat_function(fun = quadratic_eq, color = 'red') 
model_plot 
