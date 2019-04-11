# Results

All results were generated using [DTU Computing
Center](https://www.hpc.dtu.dk/)'s high-performance computing infrastructure.

## Environment

Due to user permission restrictions we could not use Docker images but instead
used a [conda virtual environment](https://conda.io/). This environment is fully
defined in the file [`environment.yml`](environment.yml) which can be used to
reproduce the results.

```
conda env create -f environment.yml
```

That said, if you are able to use Docker in your setting you can get an image
that should be very close to the above environment using:

```
docker pull opencobra/memote:0.9.6
```

## Licensing

All results are published under the [CC BY 4.0
license](https://creativecommons.org/licenses/by/4.0/).
