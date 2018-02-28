//This file is to demonstrate the use of sc_cthread

//In SC_METHOD, one iteration of a thread takes exactly one cycle of the clock if
//  there is a clock in its sensitivity list
//  So SC_METHODS are fine for simple sequential designs like counters (but simple RTL
//  is recommended for this)
//SC_CTHREADS are not limited to 1 cycle and can contain continuous loops and complex
//  control and algorithms

#ifndef FIR_H
#define FIR_H

#include <systemc.h>

SC_MODULE( fir )
{
    sc_in<bool> clk;
    sc_in<bool> rst;
    sc_in< sc_int<16> > inp;
    sc_out< sc_int<16> > outp;

    sc_in<bool>              inp_sig_vld;
    sc_in<bool>              outp_sig_rdy;
    sc_out<bool>             inp_sig_rdy;
    sc_out<bool>             outp_sig_vld;

    //Just prototype this here as you have a lot to type and we don't want to
    //inline the whole behavioral in this file
    //this should just be ports, threads, and constructors
    void fir_main(void);

    SC_CTOR( fir )
    {
        //Takes 2 arguments
        //name of the clock thread function
        //edge of the clock the thread is sensitive to
        SC_CTHREAD( fir_main, clk.pos() );
        //Takes 2 arguments
        //name of the reset input port
        //polarity of the reset (true = reset is asserted high, false = reset is asserted low)
        reset_signal_is( rst, true );
    }

};

#endif
