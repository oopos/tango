for i in *.d;do dmd -debug=${i/.d/} $i; done
