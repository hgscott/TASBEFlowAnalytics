# TASBE Flow Analytics
[![Build Status](https://travis-ci.org/TASBE/TASBEFlowAnalytics.svg?branch=master)](https://travis-ci.org/TASBE/TASBEFlowAnalytics)

TASBE Flow Analytics is a flow cytometry analysis package.

## Features

- Runs on both Matlab and Octave
- Flow cytometry analysis
- Plotting and comparison templates for many experiments
- Unit conversion to ERF from multiple channels
- Compensation for autofluorescence and spectral overlap
- Distributed under a permissive free and open license

**If you use TASBE Flow Analytics in your work, please cite the following publication:**

- A Method for Fast, High-Precision Characterization of Synthetic Biology Devices, Jacob Beal, Ron Weiss, Fusun Yaman, Noah Davidsohn, and Aaron Adler, MIT CSAIL Tech Report 2012-008, April, 2012. http://hdl.handle.net/1721.1/69973

## Installation

- Using the shell (requires a Unix-like operating system such as GNU/Linux or Apple OSX):

    ```bash
    git clone https://github.com/TASBE/TASBEFlowAnalyics.git
    cd TASBEFlowAnalyics
    make install
    ```
    This will add the TASBEFlowAnalyics directory to the Matlab and/or GNU Octave searchpath. If both Matlab and GNU Octave are available on your machine, it will install TASBEFlowAnalyics for both.

- Manual installation:
  - Download the package from [GitHub](https://github.com/TASBE/TASBEFlowAnalyics)
  - Start Matlab or Octave
  - Go to the ``TASBEFlowAnalyics/code`` directory
  - Add and save the set of paths:
  
      ```
    addpath(genpath(pwd));
    savepath;
    ```

## Usage

In use of this package, you will typically want to split your
processing into three stages:

- Creation of a ColorModel that translates raw FCS to comparable unit data
- Using a ColorModel for batch processing of experimental data
- Comparison and plotting of the results of batch processing

Example files are provided in the [TASBE Tutorial](https://github.com/TASBE/TASBEFlowAnalytics-tutorial) that show how these stages typically work.
