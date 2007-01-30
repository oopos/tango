# Makefile to build the examples of tango for Linux
# Designed to work with GNU make
# Targets:
#	make
#		Same as make all
#	make all
#		Build all examples
#
#	make <executable-name>
#		Build a specified example
#   	make clean
#   		remove all build examples
#   
# 

# Relative path to the tango include dir
# This is where the tango tree is located
TANGO_DIR = ..

# The build tool executable from dsource.org/projects/build
BUILDTOOL = bud
BUILDOPTS = -noautoimport -op -clean -full -g -debug -I$(TANGO_DIR)

PHOBOS_DIR = $(TANGO_DIR)/phobos
ZLIB_DIR = $(PHOBOS_DIR)/etc/c/zlib
ZLIB = $(ZLIB_DIR)/zlib.a

.PHONY: all clean

# Standart target
all : 

# 	networking/httpserver	\
# 	networking/servlets	\
#	networking/selector	\
#	networking/servletserver\

SIMPLE_EXAMPLES =\
	concurrency/fiber_test	\
	conduits/FileBucket	\
	conduits/composite	\
	conduits/filebubbler	\
	conduits/filecat	\
	conduits/filecopy	\
	conduits/fileops	\
	conduits/filepathname	\
	conduits/filescan	\
	conduits/filescanregex	\
	conduits/lineio		\
	conduits/mmap		\
	conduits/randomio	\
	conduits/unifile	\
	console/hello		\
	console/stdout		\
	logging/chainsaw	\
	logging/logging		\
	networking/homepage	\
	networking/httpget	\
	networking/sockethello	\
	networking/socketserver	\
	system/argparser	\
	system/localtime	\
	system/normpath		\
	system/process		\
	text/formatalign	\
	text/formatindex	\
	text/formatspec		\
	text/localetime		\
	text/token

PHOBOS_EXAMPLES =		\
	./test_phobos		\
	./phobos/htmlget 	\
	./phobos/hello 		\
	./phobos/listener 	\
	./phobos/dhry 		\
	./phobos/pi 		\
	./phobos/wc 		\
	./phobos/d2html 	\
	./phobos/sieve 		\
	./phobos/wc2 

REFERENCE_EXAMPLES =		\
	./reference/chapter4	\
	./reference/chapter11

$(SIMPLE_EXAMPLES) : % : %.d
	@echo "Building : " $@
	$(BUILDTOOL) $< $(BUILDOPTS) -T$@ -unittest

$(PHOBOS_EXAMPLES) : % : %.d $(ZLIB)
	@echo "Building : " $@
	$(BUILDTOOL) $< $(BUILDOPTS) -T$@ -Mphobos $(ZLIB) -L-ldl

$(REFERENCE_EXAMPLES) : % : %.d
	@echo "Building : " $@
	$(BUILDTOOL) $< $(BUILDOPTS) -T$@

$(ZLIB) :
	@echo "Building *** Phobos ZLIB ***"
	$(MAKE) -C $(ZLIB_DIR) -f linux.mak

all : $(SIMPLE_EXAMPLES)

clean :
	@echo "Removing all examples"
	rm -f $(SIMPLE_EXAMPLES) $(PHOBOS_EXAMPLES) $(REFERENCE_EXAMPLES)
	rm -f random.bin




