//
// SWIG typemaps for STL types
// Luigi Ballabio
// Apr 8, 2002
//
// Python implementation


// ------------------------------------------------------------------------
// std::string is typemapped by value
// This can prevent exporting methods which return a string
// in order for the user to modify it.
// However, I think I'll wait until someone asks for it...
// ------------------------------------------------------------------------

%include exception.i

%{
#include <string>
%}

namespace std {

    class string;

    %typemap(in) string {
        if (PyString_Check($input))
            $1 = std::string(PyString_AsString($input));
        else
            SWIG_exception(SWIG_TypeError, "string expected");
    }

    %typemap(in) const string & (std::string temp) {
        if (PyString_Check($input)) {
            temp = std::string(PyString_AsString($input));
            $1 = &temp;
        } else {
            SWIG_exception(SWIG_TypeError, "string expected");
        }
    }

    %typemap(out) string {
        $result = PyString_FromString($1.c_str());
    }

    %typemap(out) const string & {
        $result = PyString_FromString($1->c_str());
    }
}


// containers

// __getitem__ is required to raise an IndexError for for-loops to work
// other methods which can raise are made to throw an IndexError as well
%exception std::vector::__getitem__ {
    try {
        $action
    } catch (std::out_of_range& e) {
        SWIG_exception(SWIG_IndexError,const_cast<char*>(e.what()));
    }
}

%exception std::vector::__setitem__ {
    try {
        $action
    } catch (std::out_of_range& e) {
        SWIG_exception(SWIG_IndexError,const_cast<char*>(e.what()));
    }
}

%exception std::vector::__delitem__  {
    try {
        $action
    } catch (std::out_of_range& e) {
        SWIG_exception(SWIG_IndexError,const_cast<char*>(e.what()));
    }
}

%exception std::vector::pop  {
    try {
        $action
    } catch (std::out_of_range& e) {
        SWIG_exception(SWIG_IndexError,const_cast<char*>(e.what()));
    }
}


// ------------------------------------------------------------------------
// std::vector
// 
// The aim of all that follows would be to integrate std::vector with 
// Python as much as possible, namely, to allow the user to pass and 
// be returned Python tuples or lists.
// const declarations are used to guess the intent of the function being
// exported; therefore, the following rationale is applied:
// 
//   -- f(std::vector<T>), f(const std::vector<T>&), f(const std::vector<T>*):
//      the parameter being read-only, either a Python sequence or a
//      previously wrapped std::vector<T> can be passed.
//   -- f(std::vector<T>&), f(std::vector<T>*):
//      the parameter must be modified; therefore, only a wrapped std::vector
//      can be passed.
//   -- std::vector<T> f():
//      the vector is returned by copy; therefore, a Python sequence of T:s 
//      is returned which is most easily used in other Python functions
//   -- std::vector<T>& f(), std::vector<T>* f(), const std::vector<T>& f(),
//      const std::vector<T>* f():
//      the vector is returned by reference; therefore, a wrapped std::vector
//      is returned
// ------------------------------------------------------------------------

%{
#include <vector>
#include <algorithm>
#include <stdexcept>

double SwigNumber_Check(PyObject* o) {
    return PyFloat_Check(o) || PyInt_Check(o);
}

double SwigNumber_AsDouble(PyObject* o) {
    return (PyFloat_Check(o) ? PyFloat_AsDouble(o) : double(PyInt_AsLong(o)));
}
%}

// exported class

namespace std {
    
    template<class T> class vector {
        %typemap(in) vector<T> (std::vector<T>* v) {
            if (PyTuple_Check($input) || PyList_Check($input)) {
                unsigned int size = (PyTuple_Check($input) ?
                                     PyTuple_Size($input) :
                                     PyList_Size($input));
                $1 = std::vector<T>(size);
                for (unsigned int i=0; i<size; i++) {
                    T* x;
                    PyObject* o = PySequence_GetItem($input,i);
                    if ((SWIG_ConvertPtr(o,(void **) &x, 
                                         $descriptor(T *),0)) != -1) {
                        (($1_type &)$1)[i] = *x;
                        Py_DECREF(o);
                    } else {
                        Py_DECREF(o);
                        PyErr_SetString(PyExc_TypeError,
                                        "vector<" #T "> expected");
                        return NULL;
                    }
                }
            } else if (SWIG_ConvertPtr($input,(void **) &v, 
                                       $&1_descriptor,1) != -1){
                $1 = *v;
            } else {
                PyErr_SetString(PyExc_TypeError,"vector<" #T "> expected");
                return NULL;
            }
        }
        %typemap(in) const vector<T>& (std::vector<T> temp,
                                       std::vector<T>* v),
                     const vector<T>* (std::vector<T> temp,
                                       std::vector<T>* v) {
            if (PyTuple_Check($input) || PyList_Check($input)) {
                unsigned int size = (PyTuple_Check($input) ?
                                     PyTuple_Size($input) :
                                     PyList_Size($input));
                temp = std::vector<T>(size);
                $1 = &temp;
                for (unsigned int i=0; i<size; i++) {
                    T* x;
                    PyObject* o = PySequence_GetItem($input,i);
                    if ((SWIG_ConvertPtr(o,(void **) &x, 
                                         $descriptor(T *),0)) != -1) {
                        temp[i] = *x;
                        Py_DECREF(o);
                    } else {
                        Py_DECREF(o);
                        PyErr_SetString(PyExc_TypeError,
                                        "vector<" #T "> expected");
                        return NULL;
                    }
                }
            } else if (SWIG_ConvertPtr($input,(void **) &v, 
                                       $1_descriptor,1) != -1){
                $1 = v;
            } else {
                PyErr_SetString(PyExc_TypeError,"vector<" #T "> expected");
                return NULL;
            }
        }
        %typemap(out) vector<T> {
            $result = PyTuple_New($1.size());
            for (unsigned int i=0; i<$1.size(); i++) {
                T* ptr = new T((($1_type &)$1)[i]);
                PyTuple_SetItem($result,i,
                                SWIG_NewPointerObj((void *) ptr, 
                                                   $descriptor(T *), 1));
            }
        }
      public:
        vector(unsigned int size = 0);
        %rename(__len__) size;
        unsigned int size() const;
        %rename(__nonzero__) empty;
        bool empty() const;
        void clear();
        %rename(append) push_back;
        void push_back(const T& x);
        %extend {
            T pop() {
                if (self->size() == 0)
                    throw std::out_of_range("pop from empty vector");
                T x = self->back();
                self->pop_back();
                return x;
            }
            T& __getitem__(int i) {
                int size = int(self->size());
                if (i<0) i += size;
                if (i>=0 && i<size)
                    return (*self)[i];
                else
                    throw std::out_of_range("vector index out of range");
            }
            std::vector<T> __getslice__(int i, int j) {
                int size = int(self->size());
                if (i<0) i = size+i;
                if (j<0) j = size+j;
                if (i<0) i = 0;
                if (j>size) j = size;
                std::vector<T> tmp(j-i);
                std::copy(self->begin()+i,self->begin()+j,tmp.begin());
                return tmp;
            }
            void __setitem__(int i, const T& x) {
                int size = int(self->size());
                if (i<0) i+= size;
                if (i>=0 && i<size)
                    (*self)[i] = x;
                else
                    throw std::out_of_range("vector index out of range");
            }
            void __setslice__(int i, int j, const std::vector<T>& v) {
                int size = int(self->size());
                if (i<0) i = size+i;
                if (j<0) j = size+j;
                if (i<0) i = 0;
                if (j>size) j = size;
                if (int(v.size()) == j-i) {
                    std::copy(v.begin(),v.end(),self->begin()+i);
                } else {
                    self->erase(self->begin()+i,self->begin()+j);
                    if (i+1 <= size)
                        self->insert(self->begin()+i+1,v.begin(),v.end());
                    else
                        self->insert(self->end(),v.begin(),v.end());
                }
            }
            void __delitem__(int i) {
                int size = int(self->size());
                if (i<0) i+= size;
                if (i>=0 && i<size)
                    self->erase(self->begin()+i);
                else
                    throw std::out_of_range("vector index out of range");
            }
            void __delslice__(int i, int j) {
                int size = int(self->size());
                if (i<0) i = size+i;
                if (j<0) j = size+j;
                if (i<0) i = 0;
                if (j>size) j = size;
                self->erase(self->begin()+i,self->begin()+j);
            }
        }
    };


    // specializations for built-ins

    %define specialize_std_vector(T,CHECK,CONVERT_FROM,CONVERT_TO)
    template<> class vector<T> {
        %typemap(in) vector<T> (std::vector<T>* v) {
            if (PyTuple_Check($input) || PyList_Check($input)) {
                unsigned int size = (PyTuple_Check($input) ?
                                     PyTuple_Size($input) :
                                     PyList_Size($input));
                $1 = std::vector<T>(size);
                for (unsigned int i=0; i<size; i++) {
                    PyObject* o = PySequence_GetItem($input,i);
                    if (CHECK(o)) {
                        (($1_type &)$1)[i] = T(CONVERT_FROM(o));
                        Py_DECREF(o);
                    } else {
                        Py_DECREF(o);
                        PyErr_SetString(PyExc_TypeError,
                                        "vector<" #T "> expected");
                        return NULL;
                    }
                }
            } else if (SWIG_ConvertPtr($input,(void **) &v, 
                                       $&1_descriptor,1) != -1){
                $1 = *v;
            } else {
                PyErr_SetString(PyExc_TypeError,"vector<" #T "> expected");
                return NULL;
            }
        }
        %typemap(in) const vector<T>& (std::vector<T> temp,
                                       std::vector<T>* v),
                     const vector<T>* (std::vector<T> temp,
                                       std::vector<T>* v) {
            if (PyTuple_Check($input) || PyList_Check($input)) {
                unsigned int size = (PyTuple_Check($input) ?
                                     PyTuple_Size($input) :
                                     PyList_Size($input));
                temp = std::vector<T>(size);
                $1 = &temp;
                for (unsigned int i=0; i<size; i++) {
                    PyObject* o = PySequence_GetItem($input,i);
                    if (CHECK(o)) {
                        temp[i] = T(CONVERT_FROM(o));
                        Py_DECREF(o);
                    } else {
                        Py_DECREF(o);
                        PyErr_SetString(PyExc_TypeError,
                                        "vector<" #T "> expected");
                        return NULL;
                    }
                }
            } else if (SWIG_ConvertPtr($input,(void **) &v, 
                                       $1_descriptor,1) != -1){
                $1 = v;
            } else {
                PyErr_SetString(PyExc_TypeError,"vector<" #T "> expected");
                return NULL;
            }
        }
        %typemap(out) vector<T> {
            $result = PyTuple_New($1.size());
            for (unsigned int i=0; i<$1.size(); i++)
                PyTuple_SetItem($result,i,
                                CONVERT_TO((($1_type &)$1)[i]));
        }
      public:
        vector(unsigned int size = 0);
        %rename(__len__) size;
        unsigned int size() const;
        %rename(__nonzero__) empty;
        bool empty() const;
        void clear();
        %rename(append) push_back;
        void push_back(T x);
        %extend {
            T pop() {
                if (self->size() == 0)
                    throw std::out_of_range("pop from empty vector");
                T x = self->back();
                self->pop_back();
                return x;
            }
            T __getitem__(int i) {
                int size = int(self->size());
                if (i<0) i += size;
                if (i>=0 && i<size)
                    return (*self)[i];
                else
                    throw std::out_of_range("vector index out of range");
            }
            std::vector<T> __getslice__(int i, int j) {
                int size = int(self->size());
                if (i<0) i = size+i;
                if (j<0) j = size+j;
                if (i<0) i = 0;
                if (j>size) j = size;
                std::vector<T> tmp(j-i);
                std::copy(self->begin()+i,self->begin()+j,tmp.begin());
                return tmp;
            }
            void __setitem__(int i, T x) {
                int size = int(self->size());
                if (i<0) i+= size;
                if (i>=0 && i<size)
                    (*self)[i] = x;
                else
                    throw std::out_of_range("vector index out of range");
            }
            void __setslice__(int i, int j, const std::vector<T>& v) {
                int size = int(self->size());
                if (i<0) i = size+i;
                if (j<0) j = size+j;
                if (i<0) i = 0;
                if (j>size) j = size;
                if (int(v.size()) == j-i) {
                    std::copy(v.begin(),v.end(),self->begin()+i);
                } else {
                    self->erase(self->begin()+i,self->begin()+j);
                    if (i+1 <= size)
                        self->insert(self->begin()+i+1,v.begin(),v.end());
                    else
                        self->insert(self->end(),v.begin(),v.end());
                }
            }
            void __delitem__(int i) {
                int size = int(self->size());
                if (i<0) i+= size;
                if (i>=0 && i<size)
                    self->erase(self->begin()+i);
                else
                    throw std::out_of_range("vector index out of range");
            }
            void __delslice__(int i, int j) {
                int size = int(self->size());
                if (i<0) i = size+i;
                if (j<0) j = size+j;
                if (i<0) i = 0;
                if (j>size) j = size;
                self->erase(self->begin()+i,self->begin()+j);
            }
        }
    };
    %enddef

    specialize_std_vector(int,PyInt_Check,PyInt_AsLong,PyInt_FromLong);
    specialize_std_vector(short,PyInt_Check,PyInt_AsLong,PyInt_FromLong);
    specialize_std_vector(long,PyInt_Check,PyInt_AsLong,PyInt_FromLong);
    specialize_std_vector(unsigned int,PyInt_Check,\
                          PyInt_AsLong,PyInt_FromLong);
    specialize_std_vector(unsigned short,PyInt_Check,\
                          PyInt_AsLong,PyInt_FromLong);
    specialize_std_vector(unsigned long,PyInt_Check,\
                          PyInt_AsLong,PyInt_FromLong);
    specialize_std_vector(double,SwigNumber_Check,\
                          SwigNumber_AsDouble,PyFloat_FromDouble);
    specialize_std_vector(float,SwigNumber_Check,\
                          SwigNumber_AsDouble,PyFloat_FromDouble);

}

