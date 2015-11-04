#include <fst/fstlib.h>

namespace fst {

  template<typename Arc>
  void PhiCompose(const Fst<Arc> &fst1,
                  const Fst<Arc> &fst2,
                  MutableFst<Arc> *ofst,
                  typename Arc::Label phi_label) {

    typedef PhiMatcher<Matcher<Fst<Arc> > > PM;

    CacheOptions copts;
    copts.gc_limit = 0;  // Cache only the last state for fastest copy.
    ComposeFstOptions<Arc, PM> opts(copts);
    opts.matcher1 = new PM(fst1, MATCH_NONE, kNoLabel);
    opts.matcher2 = new PM(fst2, MATCH_INPUT, phi_label);

    *ofst = ComposeFst<Arc>(fst1, fst2, opts);
    Connect(ofst);
  }

}