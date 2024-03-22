suppressPackageStartupMessages({
  library(emayili, warn.conflicts = TRUE, quietly = TRUE)
  library(logger, warn.conflicts = TRUE, quietly = TRUE)
  library(plumber, warn.conflicts = TRUE, quietly = TRUE)
  library(tictoc, warn.conflicts = TRUE, quietly = TRUE)
})

path <- Sys.getenv("API_PATH", "unset")

path <- switch(path, unset = NULL, path)

options(plumber.maxRequestSize = 1e8L, plumber.apiPath = path)

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

p[["registerHooks"]](
  list(
    preroute = function() tic(),
    postroute = function(req, res) {

      end <- toc(quiet = TRUE)

      f <- log_info

      if (res[["status"]] >= 400L) {

        f <- log_error

        host <- Sys.getenv("SMTP_SERVER")

        port <-  Sys.getenv("SMTP_PORT")

        to <- Sys.getenv("ERROR_EMAIL_TO")

        from <- Sys.getenv("ERROR_EMAIL_FROM")

        agent <- Sys.getenv("FINBIF_USER_AGENT")

        branch <- Sys.getenv("BRANCH")

        if (!any(c(host, port, to, from, agent, branch) == "")) {

          smtp <- server(host, port)

          subject <- sprintf("Error report: %s on branch %s", agent, branch)

          text <- sprintf(
            "At [%s]: %s %s (Status: %s)",
            format(Sys.time()),
            req[["REQUEST_METHOD"]],
            req[["PATH_INFO"]],
            res[["status"]]
          )

          message <- envelope(to, from, subject = subject, text = text)

          smtp(message)

        }

      }

      g <- function(...) {}

      if (identical(sub( "/api", "", req[["PATH_INFO"]]), "/healthz")) f <- g

      if (identical(req[["HTTP_USER_AGENT"]], "Zabbix")) f <- g

      f(
        paste(
          "{convert_empty(req[[\"REMOTE_ADDR\"]])}",
          "\"{convert_empty(req[[\"HTTP_USER_AGENT\"]])}\"",
          "{convert_empty(req[[\"HTTP_HOST\"]])}",
          "{convert_empty(req[[\"REQUEST_METHOD\"]])}",
          "{convert_empty(req[[\"PATH_INFO\"]])}",
          "{convert_empty(res[[\"status\"]])}",
          "{round(end[[\"toc\"]] - end[[\"tic\"]],",
          "digits = getOption(\"digits\", 5L))}"
        )
      )

    }
  )
)

p[["run"]](host = "0.0.0.0", port = 8000L, quiet = TRUE)
