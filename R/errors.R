
##
##  defines some error object constructors, error functions, and
##  error chaining functions
##


#######################################
#   assert error object and methods   #
#######################################
# used by "assert" and "insist"
make.assertr.assert.error <- function(name.of.predicate,
                                      column,
                                      num.violations,
                                      index.of.violations,
                                      offending.elements){
  time.or.times <- ifelse(num.violations==1, "time", "times")
  msg <- paste0("Column '", column, "' violates assertion '",
                name.of.predicate,"' ", num.violations, " ", time.or.times)

  this_error <- list()

  this_error$error_df <- data.frame(index=index.of.violations,
                                    value=offending.elements)
  this_error$message <- msg
  this_error$num.violations <- num.violations
  this_error$call <- name.of.predicate

  class(this_error) <- c("assertr_assert_error", "assertr_error",
                         "error", "condition")
  return(this_error)
}

# used by "assert_rows" and "insist_rows"
make.assertr.assert_rows.error <- function(name.of.rowredux.fn,
                                           name.of.predicate,
                                           num.violations,
                                           loc.violations){
  time.or.times <- ifelse(num.violations==1, "time", "times")

  msg <- paste0("Data frame row reduction '", name.of.rowredux.fn,
                "' violates predicate '", name.of.predicate,
                "' ", num.violations, " ", time.or.times)
  this_error <- list()

  this_error$error_df <- data.frame(rownumber=loc.violations)

  this_error$message <- msg
  this_error$num.violations <- num.violations
  this_error$call <- name.of.predicate

  class(this_error) <- c("assertr_assert_error", "assertr_error",
                         "error", "condition")
  return(this_error)
}


#' Printing assertr's assert errors
#'
#' `print` method for class "assertr_assert_error"
#' This prints the error message and the entire two-column
#' `data.frame` holding the indexes and values of the offending
#' data.
#'
#' @param x An assertr_assert_error object
#' @seealso \code{\link{summary.assertr_assert_error}}
#'
#' @export
print.assertr_assert_error <- function(error){
  cat(error$message)
  cat("\n")
  print(error$error_df)
}

#' Summarizing assertr's assert errors
#'
#' `summary` method for class "assertr_assert_error"
#' This prints the error message and the first five
#' rows of the two-column `data.frame` holding the
#' indexes and values of the offending data.
#'
#' @param x An assertr_assert_error object
#' @seealso \code{\link{print.assertr_assert_error}}
#'
#' @export
summary.assertr_assert_error <- function(error){
  cat(error$message)
  cat("\n")
  numrows <- nrow(error$error_df)
  print(head(error$error_df, n=5))
  if(numrows > 5)
    cat(paste0("  [omitted ", numrows-5, " rows]\n\n"))
}


#####################
#   verify errors   #
#####################
# used by "verify"

make.assertr.verify.error <- function(num.violations, the_call){
  sing.plur <- ifelse(num.violations==1, " failure)", " failures)")
  msg <- paste0("verification [", the_call, "] failed! (", num.violations, sing.plur)
  this_error <- list()
  this_error$message <- msg
  this_error$num.violations <- num.violations
  this_error$call <- the_call
  class(this_error) <- c("assertr_verify_error", "assertr_error",
                         "error", "condition")
  return(this_error)
}

#' Printing assertr's verify errors
#'
#' `summary` method for class "assertr_verify_error"
#'
#' @param x An assertr_verify_error object
#' @seealso \code{\link{summary.assertr_verify_error}}
#'
#' @export
print.assertr_verify_error <- function(error){
  cat(error$message)
  cat("\n\n")
}

#' Summarizing assertr's verify errors
#'
#' `summary` method for class "assertr_verify_error"
#'
#' @param x An assertr_verify_error object
#' @seealso \code{\link{print.assertr_verify_error}}
#'
#' @export
summary.assertr_verify_error <- function(error){ print(error) }




## DO THESE NEED TO BE EXPORTED!?!!?!

#########################
#   success functions   #
#########################

success_logical <- function(data, ...){ return(TRUE) }

success_continue <- function(data, ...){ return(data) }


#######################
#   error functions   #
#######################

error_stop <- function(errors, data=NULL, ...){
  if(!is.null(data) && !is.null(attr(data, "assertr_errors")))
    errors <- append(attr(data, "assertr_errors"), errors)
  lapply(errors, summary)
  stop("assertr stopped execution", call.=FALSE)
}
# for backwards compatibility
assertr_stop <- error_stop

error_report <- function(errors, data=NULL, ...){
  if(!is.null(data) && !is.null(attr(data, "assertr_errors")))
    errors <- append(attr(data, "assertr_errors"), errors)
  cat(sprintf("There are %d errors:\n\n", length(errors)))   #### plural
  lapply(errors, function(x){cat("- "); print(x)})
  stop("assertr stopped execution", call.=FALSE)
}

error_append <- function(errors, data=NULL){
  if(is.null(attr(data, "assertr_errors")))
    attr(data, "assertr_errors") <- list()
  attr(data, "assertr_errors") <- append(attr(data, "assertr_errors"), errors)
  return(data)
}

error_return <- function(errors, data=NULL){
  if(!is.null(data) && !is.null(attr(data, "assertr_errors")))
    errors <- append(attr(data, "assertr_errors"), errors)
  return(errors)
}

error_logical <- function(errors, data=NULL, ...){
  return(FALSE)
}
