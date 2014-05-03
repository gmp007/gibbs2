#! /bin/bash

# Use:
#   makemake.sh
#
# Assumes files and modules share name and general common sense.

awk '
{ 
    if(FILENAME != f[fs]){
	fs++
	f[fs] = FILENAME
    }
}
/^( |\t)*module( |\t)*[^ \t\n]*( |\t)*$/{
    ismodule[fs] = 1
}
/^( |\t)*use( |\t)*[^ \t\n]*/{
    nm = tolower($2)
    uses[nm]++
    use[nm,uses[nm]] = fs
}

END{
    make="Makefile"
    print "# This file is automatically generated by makemake.awk " > make
    print "# Set compiler and options in Makefile.inc" > make
    print "include Makefile.inc" > make
    print "" > make
    print "BINS=gibbs2" > make
    print "BINS_dbg=gibbs2_dbg" > make
    str="OBJS="
    for (i=1;i<=fs;i++){
	sub(/\..+/,"",f[i])
	str=sprintf("%s %s.o",str,f[i])
    }
    print str > make

    print "LIBS=slatec/libslatec.a minpack/libminpack.a pppack/libpppack.a" > make
    print "INCLUDE=" > make
    print "" > make
    print "%.o: %.f90" > make
    print "	$(FC) -c $(FCFLAGS) $(INCLUDE) -o $@ $<" > make
    print "" > make
    print "%.o: %.f" > make
    print "	$(FC) -c $(FCFLAGS) $(INCLUDE) -o $@ $<" > make
    print "" > make
    print "%.mod: %.o" > make
    print "	@if [ ! -f $@ ]; then rm $< ; $(MAKE) $< ; fi" > make
    print "" > make
    print "# General targets" > make
    print "" > make
    print "all: $(BINS)" > make
    print "" > make
    print "debug: " > make
    print "	DEBUG=1 $(MAKE) $(BINS_dbg)" > make
    print "" > make
    print "clean:" > make
    print "	rm -f core *.mod *.o " > make
    print "" > make
    print "mrproper:" > make
    print "	rm -f core *.mod *.o $(BINS) $(BINS_dbg)" > make
    print "" > make
    print "gibbs2: $(OBJS)" > make
    print "	$(FC) -o gibbs2 $(LDFLAGS) $(OBJS) $(LIBS)" > make
    print "" > make
    print "gibbs2_dbg: $(OBJS)" > make
    print "	$(FC) -o gibbs2_dbg $(LDFLAGS) $(OBJS) $(LIBS)" > make
    print "" > make
    print "dummy: " > make
    print "	@true" > make
    print "" > make
    print "# Object dependencies" > make

    for (i=1;i<=fs;i++){
	if (ismodule[i] && uses[tolower(f[i])]){
	    str = sprintf(": %s.mod",f[i])
	    for (j=1;j<=uses[tolower(f[i])];j++)
		str = sprintf("%s.o %s",f[use[f[i],j]],str)
	    print str > make
	}
    }
}
' *.f90