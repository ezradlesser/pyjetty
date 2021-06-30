# pyjetty

- meant as an extension of [https://github.com/matplo/heppy](https://github.com/matplo/heppy)

# recommended build/setup

 - install heppy and `export HEPPY_DIR=<path to heppy>`
 - execute "cpptools/build.sh" - that's it...

# modules

- modules/pyjetty contains an env module

# example python script

```
module use <where pyjetty>/modules
module load pyjetty/1.0
pyjettypython $PYJETTY_DIR/cpptools/tests/pythia_gen_fj_lund_test.py
```


# add/extend c++ (swig) to python

- in the `cpptools/src` directory create your code/directory
- edit `cpptools/src/pyjetty.i`, `cpptools/src/CMakeLists.txt` as needed
- run `./cpptools/scripts/build_cpptools.sh`

# contributing

Please fork and make a pull request.
Please let us know if you are using this code - we are very much open for collaboration - email us at heppy@lbl.gov
