# Includes the generated lexer and parser (as they can be built easily
# and the resulting files may have deps), but exclude the coq
# extracted code and ocaml that it relies upon.  NB: we need to add an
# explicit dep on coqextract.cmi though.
ML_SOURCE:=BasicsImpl.ml BasicResourceAlgebra.ml \
           ill_absyn.ml ill_lexer.ml ill_parser.ml \
           FileNativeImpl.ml \
           CoqModules.ml Coqutil.ml TranslateTools.ml ILL_Translate.ml \
           TranslateAnnos.mli TranslateAnnos.ml BuiltinClasses.ml Translate.ml \
           resverifier.ml

ML_OBJ:=$(COQML_PREREQ:.ml=.cmo) coqextract.cmo $(patsubst %.ml,%.cmo,$(filter %.ml,$(ML_SOURCE)))
ML_OBJI:=$(ML_OBJ:.cmo=.cmi)

# You will also need to change mkcoqml if you change this
COQ_DIR_OPT:=-R ../ill ILL -R . Verifier

DEBUG:=-g

OCAMLC_OPTS:=-I ../../extlib-1.5/ -I ../../ocaml-jvml-bob/lib $(DEBUG)

.PHONY: all clean recclean

resverifier: common.cmo coqextract.cmo $(ML_OBJ)
	ocamlc.opt $(OCAMLC_OPTS) -o $@ unix.cma extLib.cma ocaml_jvml.cmo $^

all: resverifier ResourceSafety.vo

common.cmo common.cmi:
	$(MAKE) -C ../common
	cp ../common/common.cmo ../common/common.cmi .

coqextract.cmo coqextract.cmi: common.cmo common.cmi
	./mkcoqml

resverifier.cmo: coqextract.cmi common.cmi
BasicsImpl.cmo: coqextract.cmi
BuiltinClasses.cmo: common.cmi
CoqModules.cmo: coqextract.cmi
Coqutil.cmo: coqextract.cmi 
ILL_Translate.cmo: common.cmi
Translate.cmo: common.cmi
TranslateAnnos.cmo: common.cmi

clean:
	rm -f $(ML_OBJ) $(ML_OBJI) \
	      ill_lexer.ml ill_parser.mli ill_parser.ml \
	      coqextract.ml coqextract.mli \
	      common.cmo common.cmi \
	      resverifier \
	      *.vo \
	      deps-coq deps-ml
	@echo To clean up everything use make recclean.

recclean: clean
	$(MAKE) -C ../ill clean
	$(MAKE) -C .. clean

%.cmo: %.ml
	ocamlc.opt $(OCAMLC_OPTS) -c $<

%.cmi: %.mli
	ocamlc.opt $(OCAMLC_OPTS) -c $<

%.ml %.mli: %.mly
	ocamlyacc $<

%.ml: %.mll
	ocamllex $<

# For external coq modules we switch to that directory and make it.
# Note that the order is important.

../ill/%.vo: ../ill/%.v
	$(MAKE) -C ../ill $*.vo

../%.vo: ../%.v
	$(MAKE) -C .. $*.vo

%.vo: %.v
	coqc -I .. $(COQ_DIR_OPT) $*

deps-coq: *.v
	coqdep -I .. $(COQ_DIR_OPT) $^ | sed -e 's/^Extraction.vo/coqextract.cmo coqextract.cmi/' > $@

deps-ml: $(ML_SOURCE)
	ocamldep $^ > $@

include deps-coq
include deps-ml
