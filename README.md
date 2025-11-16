README
================

`{r setup, include=FALSE} knitr::opts_chunk$set(echo = TRUE)`

## Community data analysis lab

This is a repo that contains materials for a hands on exercise on
analysis of microbial community data. The materials for this exercise
were developed by Dr. Juan F. Dueñas in collaboration with Dr. Judith
Riedo. The lab was part of the Fungal Biology & Ecology course dictated
by Prof. Dr. Matthias Rillig on the winter Semester of 2022-2024 at the
Institute for Biology at FU Berlin.

The class exercise consist in a lecture, and a hands on exercise where
students will be able to analyze microbial community data derived from a
real experiment. The experiment was performed at AG Rillig, while the
data went through a bioinformatic process during which it was curated
and prepared for the present exercise. The details of the experiment,
final results and the raw data can be found in [Lozano et
al. 2024](https://doi.org/10.1111/1462-2920.16549).

If you use this code, data or presentation, please cite Lozano et
al. 2024.

## Requirements

A working install of R in each students computer is required to be able
to work through the scripts. Rstudio is the recommended IDE to manage
the code and files.

The exercise requires package vegan, tidyverse and remotes to be
installed. These can be installed using the following code:

\`\`\`{r} pkgs \<- c(“vegan”, “tidyverse”, “remotes”)

install.packages(pkgs) \# install the packages above

remotes::install_github(“jfq3/ggordiplots”) \# install package directly
from developers’ Github instead of CRAN \`\`\`
