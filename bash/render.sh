!#/bin/bash
args=("$@")
for i in ${args[@]}; do
	Rscript -e "Sys.setenv(RSTUDIO_PANDOC='/Applications/RStudio.app/Contents/MacOS/pandoc');library(rmarkdown);  library(utils); render(${i}, 'Theratri_Report.pdf')"
done
