README
================

## Community data analysis lab

This repo contains materials for a hands on exercise on
analysis of microbial community data. The materials for this exercise
were developed by Dr. Juan F. Dueñas in collaboration with Dr. Judith
Riedo. The lab was part of the Fungal Biology & Ecology course dictated
by Prof. Dr. Matthias Rillig during the winter semesters of 2022-2024 at the
Institute for Biology at FU Berlin.

The lab consist of a lecture, and a script that showcases how to analyze microbial community data derived from a
real experiment. The experiment was performed at AG Rillig, while the
data went through a bioinformatic process to curate and prepar it for the present exercise. 
The details of the experiment, final results and the raw data can be found in [Lozano et al. 2024](https://doi.org/10.1111/1462-2920.16549).

If you use this code, data or presentation, please acknowledge the authors and the source publication.

## Requirements

A working install of `R` in each student's computer is required to be able
to work through the scripts. I recommend using `Rstudio` to go through the code and files.

In addition, the exercise requires package vegan, tidyverse and remotes to be
installed. These can be installed running the following code:

```r 
pkgs <- c(“vegan”, “tidyverse”, “remotes”)

install.packages(pkgs) # install the packages above

remotes::install_github(“jfq3/ggordiplots”) # this line installs package directly from developers’ Github instead of CRAN 

```
