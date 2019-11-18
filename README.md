![BRKGA-MP-IPR logo](https://github.com/ceandrade/brkga_mp_ipr_julia/blob/master/docs/src/assets/logo.png)

BrkgaMpIpr.jl - Julia version
===============================

[![Build Status](https://travis-ci.org/ceandrade/brkga_mp_ipr_julia.svg?branch=master)](https://travis-ci.org/ceandrade/brkga_mp_ipr_julia)

[![Coverage Status](https://coveralls.io/repos/ceandrade/brkga_mp_ipr_julia/badge.svg?branch=master&service=github)](https://coveralls.io/github/ceandrade/brkga_mp_ipr_julia?branch=master)

[![codecov.io](http://codecov.io/github/ceandrade/brkga_mp_ipr_julia/coverage.svg?branch=master)](http://codecov.io/github/ceandrade/brkga_mp_ipr_julia?branch=master)

BrkgaMpIpr.jl provides a _very easy-to-use_ framework for the
Multi-Parent Biased Random-Key Genetic Algorithm with Implict Path Relink
(**BRKGA-MP-IPR**). Assuming that your have a _decoder_ to your problem,
we can setup, run, and extract the value of the best solution in less than
5 commands (obvisiously, you may need few other lines fo code to do a proper
test).

This Julia version provides a framework as fast as C/C++, as easy-to-code as
Python, and it is much cheaper (indeed, free) than Matlab. Unit and coverage
tests are fully implemented, and all pseudo-random test data were carefully
crafted to guarantee reproducibility (although it is possible that some tests
fail because of different versions of the random number generator).
Therefore, BrkgaMpIpr.jl should be suitable to be used in production
environments.

If you are like me and also like C++, check out the [**C++
version.**](https://github.com/ceandrade/brkga_mp_ipr_cpp) 
We are also developing a 
[Python version](https://github.com/ceandrade/brkga_mp_ipr_python)
which is in its earlier stages.
At this moment, we
have no plans to implement the BRKGA-MP-IPR in other languages such as
Java or C#. But if you want to do so, you are must welcome. But
please, keep the API as close as possible to the C++ API (or Julia API in
case you decide go C), and use the best coding and documentation practices of
your chosen language/framework.

If you are not familiar with how BRKGA works, take a look on
[Standard BRKGA](http://dx.doi.org/10.1007/s10732-010-9143-1) and
[Multi-Parent BRKGA](http://dx.doi.org/xxx).
In the future, we will provide a _Prime on BRKGA-MP_
section.

Tutorial
--------------------------------------------------------------------------------

Check out the tutorial and documentation:
(https://ceandrade.github.io/brkga_mp_ipr_julia)

License and Citing
--------------------------------------------------------------------------------

BRKGA-MP-IPR uses a permissive BSD-like license and it can be used as it
pleases you. And since this framework is also part of an academic effort, we
kindly ask you to remember to cite the originating paper of this work. Indeed,
Clause 4 estipulates that "all publications, softwares, or any other materials
mentioning features or use of this software and/or the data used to test it
must cite explicitly the following article":

> C.E. Andrade. R.F. Toso, J.F. Gonçalves, M.G.C. Resende. The Multi-Parent
> Biased Random-key Genetic Algorithm with Implicit Path Relinking. _European
> Jornal of Operational Research_, volume XX, issue X, pages xx-xx, 2019.
> DOI [to be determined](http://dx.doi.org/xxx)

Contributing
--------------------------------------------------------------------------------

[Contribution guidelines for this project](CONTRIBUTING.md)
