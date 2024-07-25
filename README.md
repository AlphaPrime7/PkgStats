[![](https://img.shields.io/badge/R-323330?style=for-the-badge&logo=R&logoColor=F7DF1E)](https://cran-e.com/author/Tingwei%20Adeck)

# PkgStats

-   A simple app to view package stats and compare stats if you are into that kind of thing.

## Packrat

```{R}
packrat::status() #1
packrat::snapshot() #2 tricky but removes my packages
packrat::clean() #2.5
packrat::init() #3
packrat::bundle(bundle="PkgStats-2024-07-24.tar.gz", where="/home/alphaprime7/Documents/Done/R") #4
packrat::disable()
```

```{bash}
tar -xzf PkgStats-2024-07-24.tar.gz --directory /home/alphaprime7/Documents/Done/R
```
