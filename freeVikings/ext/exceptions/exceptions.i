/*
exceptions.i
igneus 6.11.2005

SWIG interface file for exceptions used in the compiled C++ written extensions.
!!!! This interface file isn't standalone! It belongs to extensions.i !!!!
*/

%{
#include "exceptions.hpp"
%}

%init %{
init_exception_classes();
%}

%include "exceptions.hpp"
