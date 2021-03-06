#!/usr/bin/bash Rscript
 
# Small R shebang script (useable from a shell) to convert R markdown files into HTML or PDF format
# using the knitr package.
#
# Place this file in a directory in your $PATH or create an alias to it, e.g. in your '.bashrc':
# alias knit='/path/to/script'
# alias knit2html='/path/to/script --html'
# alias knit2pdf='/path/to/script --pdf'
# This is gonna have to be changed to be more applicable to non local apps

# helper function to nicely quit the R session
exit = function(status, msg, ..., help = FALSE) {
  if (!missing(msg))
    cat(sprintf(msg, ...), "\n\n", sep = "")
  if (help)
    print_help(parser)
  quit(save = "no", status = status)
}

# try to load packages
if (!suppressPackageStartupMessages(require(optparse)))
  exit(1L, "Package optparse not found")
if (!suppressPackageStartupMessages(require(knitr)))
  exit(1L, "Package knitr not found")

# options list
option_list = list(
  make_option("--html", action = "store_true", default = FALSE,
    help = "Knit into HTML format. Cannot be used together with --pdf option."),
  make_option("--pdf", action = "store_true", default = FALSE,
    help = "Knit into PDF format. Cannot be used together with --html option."),
  make_option("--nokeeprunning", action = "store_false", default = TRUE,
    help = "Don't keep processing files if a parsing error occurs."))

# parse arguments
parser = OptionParser(usage = "knit [options] file1 [file2] [file3] ...", option_list = option_list)
arguments = parse_args(parser, positional_arguments = TRUE)
opt = arguments$options

# check if at least one file is provided
if (length(arguments$args) == 0L)
  exit(1L, "Error: Incorrect number of arguments", help = TRUE)

# check exclusive arguments
if (!xor(opt$html, opt$pdf))
  exit(1L, "Error: Either HTML or PDF output must be chosen", help = TRUE)

# check files for existence and read access
files = arguments$args
ok = file_test("-f", files) & file.access(files, mode = 4L) == 0L
if (! all(ok))
  exit(1L, "Error: Argument '%s' is not a file or not readable", head(files[!ok], 1L))

# "worker" function, iterates over files and handles errors
knitFiles = function(fun, files, keep.running) {
  fun = match.fun(fun)
  errors = character(length(files))
  for (i in seq_along(files)) {
    cat("### Knitting '", files[i], "' ...\n", sep = "")
    ok = try(fun(files[i]))
    if (inherits(ok, "try-error")) {
      if (!keep.running)
        exit(1L, "Error processing file '%s': %s", files[i], as.character(ok))
      errors[i] = as.character(ok)
    }
  }
  errors
}

# process files
status = knitFiles(if (opt$html) knit2html else knit2pdf, files, !opt$nokeeprunning)

# print a little summary
files = basename(files)
str = sprintf("# %%-%is : %%s\n", max(nchar(files)))

is.error = (status != "")
status[ is.error] = gsub("\\s{2, }", " ", gsub("[^[:print:]]", " ", status[is.error]))
status[!is.error] = "[OK]"

cat("\n### Results:\n")
cat(sprintf(str, files, status), sep = "")

exit(0L)
