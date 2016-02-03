# distutils: language = c++
from libcpp.vector cimport vector
from libcpp.string cimport string
from libcpp.pair cimport pair
from libc.stdint cimport uint64_t, uint32_t
from util cimport ostream, istream

cimport sym

cdef extern from "init_openfst.h":
    void PyFST_init_openfst()

cdef extern from "<fst/fstlib.h>" namespace "fst":
    enum:
        kError
        kIDeterministic
        kODeterministic
        kAcceptor
        kTopSorted
        kWeighted

    cdef cppclass Weight:
        pass

    cdef cppclass Arc[W]:
        int ilabel
        int olabel
        int nextstate
        Arc(int ilabel, int olabel, W& weight, int nextstate)
        W weight

    cdef cppclass ArcIterator[T]:
        ArcIterator(T& fst, int state)
        bint Done()
        void Next()
        Arc& Value()

    cdef cppclass Fst:
        int Start()
        unsigned NumArcs(int s)
        Fst* Copy()
        bint Write(string& filename)
        uint64_t Properties(uint64_t mask, bint compute)

    cdef cppclass ExpandedFst(Fst):
        int NumStates()

    cdef cppclass MutableFst(ExpandedFst):
        int AddState()
        void SetFinal(int s, Weight w)
        void SetStart(int s)
        void SetInputSymbols(sym.SymbolTable* isyms)
        void SetOutputSymbols(sym.SymbolTable* osyms)
        sym.SymbolTable* MutableInputSymbols()
        sym.SymbolTable* MutableOutputSymbols()

    cdef cppclass FstHeader:
        void Read(istream& stream, string& source) except +
        string ArcType()
        string FstType()

{{#types}}
    cdef cppclass {{weight}}(Weight):
        float Value()
        {{weight}}(float value)
        {{weight}}({{weight}} weight)
        bint operator==({{weight}}& other)
        {{weight}}& set_value "operator=" ({{weight}}& other)

    cdef {{weight}} Plus({{weight}} &w1, {{weight}}& w2)
    cdef {{weight}} Times({{weight}} &w1, {{weight}}& w2)
    cdef {{weight}} Divide({{weight}} &w1, {{weight}}& w2)

    cdef {{weight}} {{weight}}Zero "fst::{{weight}}::Zero" ()
    cdef {{weight}} {{weight}}One "fst::{{weight}}::One" ()

    cdef bint ApproxEqual({{weight}} &w1, {{weight}} &w2)

    ctypedef Arc[{{weight}}] {{arc}}

{{/types}}

    cdef cppclass StdVectorFst(MutableFst):
        TropicalWeight Final(int s)
        void AddArc(int s, StdArc &arc)

    cdef cppclass LogVectorFst "fst::VectorFst<fst::LogArc>" (MutableFst):
        LogWeight Final(int s)
        void AddArc(int s, LogArc &arc)

    cdef StdVectorFst* StdVectorFstRead "fst::StdVectorFst::Read" (string& filename) except +
    cdef LogVectorFst* LogVectorFstRead "fst::VectorFst<fst::LogArc>::Read" (string& filename) except +

    cdef cppclass ILabelCompare[A]:
        pass

    cdef cppclass OLabelCompare[A]:
        pass

    cdef cppclass ArcMapper:
        pass

    cdef cppclass EncodeMapper[A]:
        EncodeMapper(int flags, EncodeType type) except +
        EncodeMapper(const EncodeMapper[A]& mapper, EncodeType type) except +

{{#types}}
    cdef cppclass Plus{{arc}}Mapper "fst::PlusMapper<fst::{{arc}}>"(ArcMapper):
        Plus{{arc}}Mapper({{weight}})
    cdef cppclass Times{{arc}}Mapper "fst::TimesMapper<fst::{{arc}}>"(ArcMapper):
        Times{{arc}}Mapper({{weight}})
    cdef cppclass Invert{{weight}}Mapper "fst::InvertWeightMapper<fst::{{arc}}>"(ArcMapper):
        Invert{{weight}}Mapper()
    cdef cppclass Rm{{weight}}Mapper "fst::RmWeightMapper<fst::{{arc}}>"(ArcMapper):
        Rm{{weight}}Mapper()
    cdef cppclass {{convert}}WeightConvertMapper "fst::WeightConvertMapper<fst::{{other}}Arc, fst::{{arc}}>"(ArcMapper):
        {{convert}}WeightConvertMapper()
    cdef cppclass LogProb{{arc}}Selector "fst::LogProbArcSelector<fst::{{arc}}>":
        LogProb{{arc}}Selector(int seed)
    cdef cppclass Uniform{{arc}}Selector "fst::UniformArcSelector<fst::{{arc}}>":
        Uniform{{arc}}Selector(int seed)
    cdef cppclass RandGenOptions:
        pass
    cdef cppclass LogProb{{arc}}RandGenOptions "fst::RandGenOptions< fst::LogProbArcSelector<fst::{{arc}}> >"(RandGenOptions):
        LogProb{{arc}}RandGenOptions(LogProb{{arc}}Selector& selector, int maxlen, int npath, bint weighted)
    cdef cppclass Uniform{{arc}}RandGenOptions "fst::RandGenOptions< fst::UniformArcSelector<fst::{{arc}}> >"(RandGenOptions):
        Uniform{{arc}}RandGenOptions(Uniform{{arc}}Selector& selector, int maxlen, int npath, bint weighted)
{{/types}}

    enum ProjectType:
        PROJECT_INPUT
        PROJECT_OUTPUT

    enum ClosureType:
        CLOSURE_STAR
        CLOSURE_PLUS

    enum ReweightType:
        REWEIGHT_TO_INITIAL
        REWEIGHT_TO_FINAL

    enum:
        kPushWeights
        kPushLabels

    enum EncodeType:
        ENCODE
        DECODE

    enum:
        kEncodeLabels
        kEncodeWeights
        kEncodeFlags

    cdef bint Equivalent(Fst& fst1, Fst& fst2)

    # Constructive operations
    cdef void Compose(Fst &ifst1, Fst &ifst2, MutableFst* ofst) except +
    cdef void Determinize(Fst& ifst, MutableFst* ofst) except +
    cdef void Difference(Fst &ifst1, Fst &ifst2, MutableFst* ofst) except +
    cdef void Intersect(Fst &ifst1, Fst &ifst2, MutableFst* ofst) except +
    cdef void Reverse(Fst &ifst, MutableFst* ofst) except +
    cdef void ShortestPath(Fst &ifst, MutableFst* ofst, unsigned n, bint unique) except +
    cdef void ArcMap (Fst &ifst, MutableFst* ofst, ArcMapper mapper) except +
{{#types}}
    cdef void ShortestDistance(Fst &fst, vector[{{weight}}]* distance, bint reverse) except +
    cdef void {{arc}}PushInitial "fst::Push<fst::{{arc}}, fst::REWEIGHT_TO_INITIAL>" (Fst &ifst,
        MutableFst* ofst, uint32_t ptype) except +
    cdef void {{arc}}PushFinal "fst::Push<fst::{{arc}}, fst::REWEIGHT_TO_FINAL>" (Fst &ifst,
        MutableFst* ofst, uint32_t ptype) except +
    cdef void RandGen(Fst &ifst, MutableFst* ofst, const RandGenOptions& opts) except +
{{/types}}
    # Destructive operations
    cdef void Closure(MutableFst* ifst, ClosureType type) except +
    cdef void Invert(MutableFst* ifst) except +
    cdef void Minimize(MutableFst* fst) except +
    cdef void Project(MutableFst* fst, ProjectType type) except +
    cdef void Relabel(MutableFst* fst, 
            vector[pair[int, int]]& ipairs,
            vector[pair[int, int]]& opairs) except +
    cdef void RmEpsilon(MutableFst* fst) except +
    cdef void TopSort(MutableFst* fst) except +
{{#types}}
    cdef void ArcSort(MutableFst* fst, ILabelCompare[{{arc}}]& compare) except +
    cdef void ArcSort(MutableFst* fst, OLabelCompare[{{arc}}]& compare) except +
    cdef void Encode(MutableFst* ifst, EncodeMapper[{{arc}}]* encoder) except +
    cdef void Decode(MutableFst* ifst, const EncodeMapper[{{arc}}]& encoder) except +
    cdef void Prune(MutableFst* ifst, {{weight}} threshold) except +
    cdef void Connect(MutableFst *fst) except +
    cdef void {{arc}}Reweight "fst::Reweight<fst::{{arc}}>" (MutableFst* fst,
        vector[{{weight}}] potentials, ReweightType rtype) except +
{{/types}}
    # Other
    cdef void Union(MutableFst* ifst1, Fst &ifst2) except +
    cdef void Concat(MutableFst* ifst1, Fst &ifst2) except +

{{#types}}
    ctypedef Fst* Const{{fst}}Ptr 'const fst::Fst<fst::{{arc}}>*'
    cdef void Replace(vector[pair[int, Const{{fst}}Ptr]] label_fst_pairs, 
             MutableFst *ofst,
             int root,
             bint epsilon_on_replace) except +
{{/types}}


cdef extern from "<fst/script/draw.h>" namespace "fst":
    cdef cppclass FstDrawer[A]:
        FstDrawer(Fst& fst, 
                  sym.SymbolTable *isyms,
                  sym.SymbolTable *osyms,
                  sym.SymbolTable *ssyms,
                  bint accep,
                  string title,
                  float width,
                  float height,
                  bint portrait,
                  bint vertical, 
                  float ranksep,
                  float nodesep,
                  int fontsize,
                  int precision,
                  bint show_weight_one)

        void Draw(ostream *strm, string &dest)

cdef extern from "phi_compose.cpp" namespace "fst":
    cdef void PhiCompose(Fst &ifst1, Fst &ifst2, MutableFst* ofst, int phi_label) except +

