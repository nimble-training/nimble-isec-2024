# nimble-isec-2024

This repository contains Materials for the NIMBLE workshop at the 2024 ISEC conference at Swansea University, Wales.

*Change of time* - The workshop time has been changed to the **afternoon** of 13 July 2024 from **12:00 – 15:00 BST**.

*Lunch* - In addition, all participants are invited to attend lunch prior to the workshop at 13:00.

To prepare for the workshop:

 - Install NIMBLE (see below)
 - Install additional packages (see below)
 - Download the materials provided in this repository

All materials for the workshop will be in this GitHub repository. If you're familiar with Git/GitHub, you already know how to get all the materials on your computer. If you're not, go [here](https://github.com/nimble-training/nimble-isec-2024), click the (green) "Code" button, and choose the "Download ZIP" option.

This workshop is organized into four modules:

1. Overview of `nimble` in the context of capture-recapture
2. Using `nimbleEcology` for common ecological model structures
3. Introduction to `nimbleHMC` for Hamiltonian Monte Carlo (HMC) sampling
4. Introduction to Laplace approximation for marginalisation over latent states

## Background for the workshop

This workshop will focus on the `nimble` software package, not on developing statistical models.  The material assumes attendees have basic knowledge of:

- Ecological statistical models such as capture-recapture, occupancy, N-mixture, and hidden Markov models
- Writing models in the "BUGS language", as used in WinBUGS, OpenBUGS, JAGS, and NIMBLE software packages

You will still be able to follow the workshop without this background, but the workshop is geared towards participants already familiar with these topics.

## Help with NIMBLE

The NIMBLE web site is [here](https://r-nimble.org).

The NIMBLE user manual is [here](https://r-nimble.org/html_manual/cha-welcome-nimble.html).

A NIMBLE "cheatsheet" is available [here](https://r-nimble.org/documentation).

For those of you who are not already familiar with writing models in WinBUGS, JAGS, or NIMBLE, you may want to look through the first module (Introduction to NIMBLE) or Section 5.2 of our user manual in advance.

We're happy to answer questions about writing models as we proceed through the workshop, but if you have no experience with hierarchical modelling, we suggest reviewing the materials in advance of the workshop.

## Installing NIMBLE

NIMBLE is an R package available on CRAN, so in general it will be straightforward to install as with any R package. However, NIMBLE does require a compiler and related tools installed on your system.

The steps to install NIMBLE are:

1. Install compiler tools on your system. [https://r-nimble.org/download](https://r-nimble.org/download) will point you to more details on how to install *Rtools* on Windows and how to install the command line tools of *Xcode* on a Mac. Note that if you have packages requiring a compiler (e.g., *Rcpp*) on your computer, you should already have the compiler tools installed.

2. Install the *nimble* package from CRAN in the usual fashion of installing an R package (e.g. `install.packages("nimble")`). More details (including troubleshooting tips) can also be found in Section 4 of the [NIMBLE manual](https://r-nimble.org/html_manual/cha-installing-nimble.html).

3) Test that the installation is working, by running the following code in R:

```
library(nimble)
code <- nimbleCode({ x ~ dnorm(0, 1) })
model <- nimbleModel(code)
cModel <- compileNimble(model)
```

If the above code runs without error, you're all set. If not, please see the troubleshooting tips.  The most common problems have to do with proper installation of the compiler tools.  On Windows, the `PATH` system variable must be set (see link to Rtools installation details from our download linked above).  On Mac OSX, command line tools must be installed as part of Xcode.  If you still have problems, please email the [nimble-users group](https://r-nimble.org/more/issues-and-groups) for help.

In general, we encourage you to update to the most recent version of NIMBLE (version 1.1.0).

## Installing additional packages

Prior to the workshop, you should also install the following R packages (beyond those automatically installed with `nimble`), which can be installed as follows:

```
install.packages(c("nimbleHMC", "mcmcplots", "coda", "nimbleEcology"))
```

