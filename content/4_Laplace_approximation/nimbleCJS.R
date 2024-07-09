rm(list=ls())
library(nimble)
library(nimbleEcology) ## version 0.5.0
load("cjsDataResults")

## Model code
code <- nimbleCode({
  ## Priors 
  for(i in 1:2){
    beta[i] ~ dnorm(0, sd = 10)
    gamma[i] ~ dnorm(0, sd = 10)
  }
  logSigma ~ dnorm(0, sd = 10)
  sigma <- exp(logSigma)
  for(i in 1:(nocca-1)){
    mu[i] ~ dnorm(0, sd = 10)
  }
  ## Likelihood
  for(i in 1:N){## for each of N individuals
    for(t in fi[i]:(nocca-1)){
      ## Latent process for individual covariate values
      x[i, t+1] ~ dnorm(x[i, t] + mu[t], sd = sigma)
      ## Survival and capture probs in terms of covariates
      logit(captProb[i, t]) <- gamma[1] + gamma[2] * x[i, t]
      logit(survProb[i, t]) <- beta[1] + beta[2] * x[i, t]
    }
    ## Capture prob for the last occasion
    logit(captProb[i, nocca]) <- gamma[1] + gamma[2] * x[i, nocca]
    ## Likelihood for the observed data of the i-th individual
    y[i, fi[i]:nocca] ~ dCJS_vv(probSurvive = survProb[i, fi[i]:(nocca-1)], 
                                probCapture = captProb[i, fi[i]:nocca], 
                                len = len[i])
  }
})

## Prepare data for building the model
N <- nrow(y)
nocca <- ncol(y)
len <- nocca - fi + 1
consts <- list(fi = fi, nocca = nocca, N = N, len = len)
data <- list(y = y, x = x)
inits <- list(beta = c(1,1), gamma = c(1,1), logSigma = 1, mu = rep(1,3))

## Build and compile the model
model <- nimbleModel(code, consts, data, inits, buildDerivs = TRUE)
cmodel <- compileNimble(model)

laplace <- buildLaplace(model, paramNodes = c("beta", "logSigma", "gamma", "mu"))
claplace <- compileNimble(laplace, project = model)

## Calculate MLEs
res <- runLaplace(claplace)

## Calculate CIs
paramCIs <- cbind(res$summary$params$estimate - qnorm(0.975)*res$summary$params$se, 
                  res$summary$params$estimate + qnorm(0.975)*res$summary$params$se)
rownames(paramCIs) <- rownames(res$summary$params)
colnames(paramCIs) <- c("95% lower", "95% upper")
## Transfer logSigma to sigma^2
paramCIs[3,] <- exp(paramCIs[3,])^2
rownames(paramCIs)[3] <- "sigma^2"
paramCIs


