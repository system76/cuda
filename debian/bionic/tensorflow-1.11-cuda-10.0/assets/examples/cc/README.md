# C++ Example

To build this project, simply run the following commands:

```sh
# cd to $HOME and copy the example to it.
cd $HOME
cp -r /usr/lib/tensorflow/examples/cc $HOME/tf-cc-example

# cd to the project example in $HOME, build it, and run it.
cd $HOME/tf-cc-example
mkdir build && cd build && cmake .. && make
./example
```

The CMakeLists.txt file contains the information for linking to the C++ library and locating its header files.
