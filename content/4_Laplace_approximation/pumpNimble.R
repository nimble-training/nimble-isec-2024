rm(list=ls())
library(nimble)
nimbleOptions(buildDerivs = TRUE)

code <- nimbleCode({ 
  for (i in 1:N){
    theta[i] ~ dgamma(alpha, beta)
    lambda[i] <- theta[i] * t[i]
    x[i] ~ dpois(lambda[i])
  }
  alpha ~ dexp(1.0)
  beta ~ dgamma(0.1, 1.0)
})
## Prepare constants, data, and initial values
consts <- list(N = 10, t = c(94.3, 15.7, 62.9, 126, 5.24, 31.4, 1.05, 1.05, 2.1, 10.5))
dat <- list(x = c(5, 1, 5, 14, 3, 19, 1, 1, 4, 22))
inits <- list(alpha = 0.1, beta = 0.1, theta = rep(0.1, consts$N))

## Build and compile the model
pump <- nimbleModel(code, consts, dat, inits, buildDerivs = TRUE)
Cpump <- compileNimble(pump)

## Build and compile Laplace approximation
laplace <- buildLaplace(pump)
cLaplace <- compileNimble(laplace, project = pump)

## Run Laplace to find MLEs
mleres <- runLaplace(cLaplace)

mleres$summary$params
mleres$summary$randomEffects

## Use Laplace with within MCMC:
## 1: Integrate out all elements of theta and use MCMC for parameters
llFun_Laplace <- nimbleFunction(
  setup = function(model, paramNodes, randomEffectsNodes, calcNodes) {
    laplace <- buildLaplace(model, paramNodes, randomEffectsNodes, calcNodes)
  },
  run = function() {
    pvals <- values(model, paramNodes)
    ll <- laplace$calcLaplace(pvals)
    returnType(double())
    return(ll)
  }
)
randomEffectsNodes <- "theta[1:10]"
paramNodes <- c("alpha", "beta")
calcNodes <- pump$getDependencies(randomEffectsNodes)
Rll_Laplace <- llFun_Laplace(pump, paramNodes, randomEffectsNodes, calcNodes)
mcmcConf1 <- configureMCMC(pump, nodes = NULL)
for(tarNode in c("alpha", "beta")){
  mcmcConf1$addSampler(target = tarNode, type = "RW_llFunction",
                      control = list(llFunction = Rll_Laplace, includesTarget = FALSE))
}
## Build and run MCMC
mcmc1 <- buildMCMC(mcmcConf1)
Cmcmc1 <- compileNimble(mcmc1, project = pump, resetFunctions = T)
time1 <- system.time(
  MCMCres1 <- runMCMC(Cmcmc1, 
                     niter = 10000, 
                     nchains = 1, 
                     samplesAsCodaMCMC = TRUE)
)
summRes1 <- summary(MCMCres1)

## 2: Run MCMC for all of the nodes 
mcmcConf2 <- configureMCMC(pump, monitors = c("alpha", "beta", "theta[1:10]"))
mcmc2 <- buildMCMC(mcmcConf2)
Cmcmc2 <- compileNimble(mcmc2, project = pump, resetFunctions = T)
time2 <- system.time(
  MCMCres2 <- runMCMC(Cmcmc2, 
                      niter = 10000, 
                      nchains = 1, 
                      samplesAsCodaMCMC = TRUE)
)
summRes2 <- summary(MCMCres2)

## 3: Integrate out some elements of theta and use MCMC for the remaining ones
randomEffectsNodes <- "theta[1:8]" ## Nodes to integrate out using Laplace 
paramNodes <- c("alpha", "beta")
calcNodes <- pump$getDependencies("theta[1:8]")
otherNodes <- pump$expandNodeNames("theta[9:10]") 
llFun_Laplace <- nimbleFunction(
  setup = function(model, paramNodes, randomEffectsNodes, calcNodes, otherNodes) {
    laplace <- buildLaplace(model, paramNodes, randomEffectsNodes, calcNodes, control = list(check=FALSE))
  },
  run = function() {
    ll <- model$calculate(otherNodes)
    pvals <- values(model, paramNodes)
    ll <- ll + laplace$calcLaplace(pvals)
    returnType(double())
    return(ll)
  }
)
Rll_Laplace <- llFun_Laplace(pump, paramNodes, randomEffectsNodes, calcNodes, otherNodes)
mcmcConf3 <- configureMCMC(pump, nodes = "theta[9:10]")
for(tarNode in c("alpha", "beta")){
  mcmcConf3$addSampler(target = tarNode, type = "RW_llFunction",
                       control = list(llFunction = Rll_Laplace, includesTarget = FALSE))
}
mcmcConf3$addMonitors("theta[9]", "theta[10]") 
## Build and run MCMC
mcmc3 <- buildMCMC(mcmcConf3)
Cmcmc3 <- compileNimble(mcmc3, project = pump, resetFunctions = T)
time3 <- system.time(
  MCMCres3 <- runMCMC(Cmcmc3, 
                      niter = 10000, 
                      nchains = 1, 
                      samplesAsCodaMCMC = TRUE)
)
summRes3 <- summary(MCMCres3)

