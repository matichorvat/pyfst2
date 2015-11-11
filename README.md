# pyfst2

Python interface to [OpenFst](http://openfst.org)

Documentation: http://pyfst.github.io

Forked from: https://github.com/UFAL-DSG/pyfst which was forked from https://github.com/vchahun/pyfst

I have made some changes that are incompatible with the original pyfst interface. Namely, I do not initialize fst.SymbolTable, it needs to be specified when creating the FST. This means that the default FST will anticipate integer labels for arcs. How to use symbol table is shown in the example below. 

## Requirements Installation

### OpenFST

#### 1. Create a prefix directory if one does not yet exist

```bash
cd /path/to/parent/dir
mkdir -p openfst-1.5.0
cd openfst-1.5.0
export PREFIX=$PWD
echo $PREFIX
```

#### 2. Download OpenFST

```bash
mkdir -p openfst
cd openfst
wget http://www.openfst.org/twiki/pub/FST/FstDownload/openfst-1.5.0.tar.gz
tar xzf openfst-1.5.0.tar.gz
```

#### 3. Build OpenFST (specify configure options, e.g. FAR, PDT, etc., as desired)

```bash
rm -rf objdir
mkdir objdir
cd objdir/
../openfst-1.5.0/configure --prefix=$PREFIX --enable-far --enable-pdt --enable-bin --enable-ngram-fsts
make -j 4
make install
```

#### 4. Set up environment variables

```bash
echo "export OPENFSTDIR=$PREFIX" >> ~/.bashrc

echo 'export CPLUS_INCLUDE_PATH=$OPENFSTDIR/include:$CPLUS_INCLUDE_PATH
export LIBRARY_PATH=$OPENFSTDIR/lib:$LIBRARY_PATH
export LIBRARY_PATH=$OPENFSTDIR/lib/fst:$LIBRARY_PATH
export LD_LIBRARY_PATH=$OPENFSTDIR/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$OPENFSTDIR/lib/fst:$LD_LIBRARY_PATH
export PATH=$OPENFSTDIR/bin:$PATH
export PYTHONPATH=$OPENFSTDIR/lib/python2.7/site-packages:$PYTHONPATH' >> ~/.bashrc
```

### Other

Install python libraries ``sudo pip install --upgrade pyyaml pystache cython distribute``

## Installation

If installing as a library: ``LIBRARY_PATH=$OPENFSTDIR/lib:$OPENFSTDIR/lib/fst CPLUS_INCLUDE_PATH=$OPENFSTDIR/include python setup.py install``

If installing to local directory (e.g. for development): ``LIBRARY_PATH=$OPENFSTDIR/lib:$OPENFSTDIR/lib/fst CPLUS_INCLUDE_PATH=$OPENFSTDIR/include python setup.py build_ext --inplace``

## Basic Usage

```python
import fst

t = fst.Transducer(isyms=fst.SymbolTable(), osyms=fst.SymbolTable())

t.add_arc(0, 1, 'a', 'A', 0.5)
t.add_arc(0, 1, 'b', 'B', 1.5)
t.add_arc(1, 2, 'c', 'C', 2.5)

t[2].final = 3.5

t.shortest_path() # 2 -(a:A/0.5)-> 1 -(c:C/2.5)-> 0/3.5 
```

The pyfst API is [IPython notebook](http://ipython.org/ipython-doc/dev/interactive/htmlnotebook.html)-friendly: the transducers objects are [automatically drawn](http://nbviewer.ipython.org/3835477/) using [Graphviz](http://www.graphviz.org).

## License

Copyright 2013 Victor Chahuneau
          2013 Ondrej Platek
          2015 Matic Horvat

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
