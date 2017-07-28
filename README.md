[![Build Status](https://ci.sagrid.ac.za/buildStatus/icon?job=netcdf-deploy)](https://ci.sagrid.ac.za/job/netcdf-deploy)

# netcdf-deploy

Build and test scripts necessary to deploy netCDF-c, netCDF-cxx, netCDF fortran and netCDF-python interfaces

# Build Flow

NetCDF consists of several components.
We build them in the same job, triggered by the same repository (this one) as part of a conditional workflow, in the following sequence:

  1. `build-parallel.sh` - build the parallel NetCDF component (pNetCDF)
  2. `check-parallel.sh` - test the build of the parallel NetCDF component and install it in the target directory (with `make install`)
  3. `build.sh` - build the C interface to NetCDF
  4. `check-build.sh` - test the C interface to NetCDF and install it, as well as the modulefile
  5. `build-fortran.sh` - build the Fotran interface to NetCDF
  6. `check-build-fortran.sh` - Test the Fortran interface to NetCDF
  7. `deploy.sh` - rebuild for deploy (C interface)
  8. `deploy-fortran.sh` - rebuild and deploy (Fortran interface)
  9. `deploy-parallel.sh` - rebuild and deploy (parallel component)
