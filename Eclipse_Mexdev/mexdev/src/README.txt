To get the debug mode too work you MUST compile with matlab and only
matlab in the following manner
mex name.c -g
trying to use the dev environment compiled file does not work for debugging
i have only tried -g3 so maybe if you compile with -g it would but it is
easy enough to just use matlab as above and I know this works

You must set the breakpoints in eclipse however
you must also make sure that your debug C application is pointed to the 
correct process