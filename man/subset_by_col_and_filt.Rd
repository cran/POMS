% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/preprocess.R
\name{subset_by_col_and_filt}
\alias{subset_by_col_and_filt}
\title{Subset dataframe by column names and then post-filter}
\usage{
subset_by_col_and_filt(in_tab, col2keep, verbose = TRUE)
}
\arguments{
\item{in_tab}{input dataframe}

\item{col2keep}{column names to retain in output (as long as they have at least one non-zero value).}

\item{verbose}{flag to indicate that the final number of rows and columns (as well as the number removed) should be reported.}
}
\value{
dataframe with subset of specified columns (if they have at least one non-zero value), also with rows that only contain 0's removed.
}
\description{
Subset table by set of column names. After doing this, it will remove any rows and columns that are all 0's.
}
