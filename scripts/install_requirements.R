install.packages(c(
  "ape",
  "caret",
  "cowplot",
  "devtools",
  "fpc",
  "kableExtra",
  "randomForest"
))

# Change in behavior in newer versions lead to an error in `stat_sina`
# computation.
devtools::install_version("ggforce", version = "0.1.1")
