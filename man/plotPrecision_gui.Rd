% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotPrecision_gui.r
\name{plotPrecision_gui}
\alias{plotPrecision_gui}
\title{Plot Precision}
\usage{
plotPrecision_gui(
  env = parent.frame(),
  savegui = NULL,
  debug = FALSE,
  parent = NULL
)
}
\arguments{
\item{env}{environment in which to search for data frames.}

\item{savegui}{logical indicating if GUI settings should be saved in the environment.}

\item{debug}{logical indicating printing debug information.}

\item{parent}{widget to get focus when finished.}
}
\value{
TRUE
}
\description{
GUI simplifying the creation of plots from precision data.
}
\details{
Plot precision data for size, height, or data point as dotplot or
boxplot. Plot per marker or all in one. Use the mean value or the allele
designation as x-axis labels.
Automatic plot titles can be replaced by custom titles.
A name for the result is automatically suggested.
The resulting plot can be saved as either a plot object or as an image.
}
\seealso{
\url{https://ggplot2.tidyverse.org/} for details on plot settings.
}
