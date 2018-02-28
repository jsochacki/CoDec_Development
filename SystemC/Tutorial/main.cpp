//This the top level structural host module
//PS, dont forget to link systemc, stdc++, and m

#include <systemc.h>
#include "fir.h"
#include "tb.h"

SC_MODULE( SYSTEM )
{
    //module declarations
    //Done by doing module_name Pointer_to_instance i.e. name *iname;
    tb  *tb0;
    fir *fir0;
    //signal declarations
    sc_signal<bool>             rst_sig;
    sc_signal< sc_int<16> >     inp_sig;
    sc_signal< sc_int<16> >     outp_sig;
    sc_clock                    clk_sig;

    sc_signal<bool>             inp_sig_vld;
    sc_signal<bool>             inp_sig_rdy;
    sc_signal<bool>             outp_sig_vld;
    sc_signal<bool>             outp_sig_rdy;

    //module instance signal connections
    //There are three arguements
    //The first is a character pointer string and can be anything you want
    //The second is the number of units long the clock signal is
    //The third arguement is a sc_time_unit
    //SC_US is microsecond units
    //SC_NS is nanoseconds units
    //SC_PS is picoseconds units
    //This is a copy constructor the the clock class will generate a repetitive clock signal
    SC_CTOR( SYSTEM )
        : clk_sig ("clk_sig_name", 10, SC_NS)
    {
        //Since these are SC_MODULES we need to pass the a charcter pointer string
        tb0 = new  tb("tb0");
        fir0 = new fir("fir0");
        //Since these are pointers (new allocates memory and returns a pointer to the first
        //  location in that memory) we can use the arrow style derefferencing operator to
        //  specify a particular port and then bind it to a signal with parenthesis
        tb0->clk( clk_sig );
        tb0->rst( rst_sig );
        tb0->inp( inp_sig );
        tb0->outp( outp_sig );
        fir0->clk( clk_sig );
        fir0->rst( rst_sig );
        fir0->inp( inp_sig );
        fir0->outp( outp_sig );

        tb0->inp_sig_vld( inp_sig_vld );
        tb0->inp_sig_rdy( inp_sig_rdy );
        tb0->outp_sig_vld( outp_sig_vld );
        tb0->outp_sig_rdy( outp_sig_rdy );
        fir0->inp_sig_vld( inp_sig_vld );
        fir0->inp_sig_rdy( inp_sig_rdy );
        fir0->outp_sig_vld( outp_sig_vld );
        fir0->outp_sig_rdy( outp_sig_rdy );
    }

    //Destructor
    ~SYSTEM()
    {
        //free the memory up from the functions that are no longer needed
        delete tb0;
        delete fir0;
    }
};

//Module declaration just like we did in main for fir and tb but we just assign at
//instantiation time NULL, could have done this above as well
SYSTEM *top = NULL;

//Make it int in case the compiler requires it
int sc_main( int argc, char *argv[])
{
    top = new SYSTEM( "top" );
    sc_start();
    return 0;
}

/*
This is what you need to ad to your make file to auto check results
GOLD_DIR = ./golden
GOLD_FILE = $(GOLD_DIR)/ref_output.dat

cmp_result:
    @echo "*******************************************************"
    @if diff -w $(GOLD_FILE) ./output.dat; then \
        echo "SIMULAITON PASSED"; \
    else \
        echo "SIMULATION FAILED"; \
        fi
    @echo "*******************************************************"

 */

/*
 * sc_time represents anything in systemc that can be measured in time units
 *
 */
