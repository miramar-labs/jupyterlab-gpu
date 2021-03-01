## Container Notes


                                  cudabase
                                     |
                                  base-nb
                                  /       
                             minimal-nb              
                                  |
                             minimal-ext-nb (common)
                +-----------------+------------------+
            scipy-nb          spark-ext-nb          ihaskell-nb          
            /      \                  \             xeus-cling-nb
	datascience-nb  tensorflow-nb   pyspark-nb      r-nb
    pytorch-nb            |             \           q-nb
                         tfx-nb      all-spark-nb
                                     
                                               
           
                     


Rebuilding containers (FULL)

- `pushd jup/containers`
- `make clean-sources baseprep`
- update `hosts/_ver_ds_container` to new TAG version
- update TAG to same value in makefile
- `make nukeimages` (if you want to remove all previous docker images first)
- `make` (with caching disabled) OR
- `make NOCACHE=` (with caching enabled)