#include "init_openfst.h"

#include <fst/util.h>

void PyFST_init_openfst() {
  // put any other special initalization code here
  FLAGS_fst_error_fatal = false;
}
