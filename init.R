suppressPackageStartupMessages({
  library(logger, quietly = TRUE)
  library(plumber, quietly = TRUE)
  library(tictoc, quietly = TRUE)
})

options(plumber.maxRequestSize = 1e8L)

convert_empty <- function(x) switch(paste0(".", x), . = "-", x)

status_dir <- Sys.getenv("STATUS_DIR", "status")

log_dir <- Sys.getenv("LOG_DIR", "logs")

if (!dir.exists(status_dir)) {

  stopifnot(
    "Status dir creation failed" = dir.create(status_dir, recursive = TRUE)
  )

}

if (!dir.exists(log_dir)) {

  stopifnot(
    "Log dir creation failed" = dir.create(log_dir, recursive = TRUE)
  )

}

log_file <- tempfile("plumber_", log_dir, ".log")

log_appender(appender_tee(log_file))

p <- plumb("api.R")

p$registerHooks(
  list(
    preroute = function() tic(),
    postroute = function(req, res) {

      end <- toc(quiet = TRUE)

      log_fn <- log_info

      if (res$status >= 400L) log_fn <- log_error

      if (identical(req[["PATH_INFO"]], "/healthz")) log_fn <- \(.) {}

      if (identical(req[["HTTP_USER_AGENT"]], "Zabbix")) log_fn <- \(.) {}

      log_fn(
        paste0(
          '{convert_empty(req$REMOTE_ADDR)} ',
          '"{convert_empty(req$HTTP_USER_AGENT)}" ',
          '{convert_empty(req$HTTP_HOST)} ',
          '{convert_empty(req$REQUEST_METHOD)} ',
          '{convert_empty(req$PATH_INFO)} ',
          '{convert_empty(res$status)} ',
          '{round(end$toc - end$tic, digits = getOption("digits", 5L))}'
        )
      )

    }
  )
)

p$run(host = "0.0.0.0", port = 8000L, quiet = TRUE)
