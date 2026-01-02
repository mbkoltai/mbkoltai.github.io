library(shinylive); library(httpuv)

export(appdir = ".", destdir = "docs")
runStaticServer("docs/", port=8008)