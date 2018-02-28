#ifndef TB_H
#define TB_H

#include <systemc.h>

SC_MODULE( tb )
{
    sc_in<bool>             clk;
    sc_out<bool>            rst;
    sc_out< sc_int<16> >    inp;
    sc_in< sc_int<16> >     outp;
    sc_out<bool>            inp_sig_vld;
    sc_out<bool>            outp_sig_rdy;
    sc_in<bool>             inp_sig_rdy;
    sc_in<bool>             outp_sig_vld;

    //need to declare the threads that we will use in the tb module
    //You always want to keep the source and sink portions of the tb separate
    //rst and inp
    void source(void);
    //outp and clk
    void sink(void);

    FILE *outfp;
    sc_time start_time[64], end_time[64], clock_period;

    SC_CTOR( tb )
    {
        SC_CTHREAD( source, clk.pos() );
        SC_CTHREAD( sink, clk.pos() );
    }
};

#endif
