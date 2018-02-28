
#include "fir.h"

// Coefficients for the FIR filter

const sc_uint<9> coef[5] =
{
18,
77,
107,
77,
18
};

//fir_main thread
//Since we are defining the function outside of the fir module declaration we need some way
//to associate this fit_main function with the module fir as
//We could have multiple modules with their own member function with the same name
//This is called scoping and says fir_main belongs to fir

//How do you check whether the reset is asserted in the functionality of the thread

void fir::fir_main(void)
{
    sc_int<16> taps[5];
    unsigned int i = 0;
    sc_int<16> accumulator = 0;

    //Reset code
    //Reset internal variables
    //Reset outputs
    for(i = 0; i < 5; i++)
    {
        taps[0] = 0;
    }
    outp.write(0);
    inp_sig_rdy.write(0);
    outp_sig_vld.write(0);
    wait();
    //This means to wait for 1 clock cycle
    //Everything from the beginning of the thread to the first wait statement will become
    //a reset state in the generated RTL
    //Note that in acutal operation the thread will do a reset first as the operation begins
    //i.e. it will run the code from top to bottom
    //Also, note that the reset is syncronous, the reset signal is checked (by
    //reset_signal_is) on the clock edge
    //as that (the clock edge) is what you have declared to be the sensitivity
    ///input to the cthread

    while( true )
    {
        //read inputs
        //Algorithm code
        //Write outputs

        for(i = 4; i > 0; i--)
        {
            taps[i] = taps[i - 1];
        }

        //Handshaking
        inp_sig_rdy.write(1);
        do
        {
            wait();
        }
        while( !inp_sig_vld.read() );
        taps[0] = inp.read();
        inp_sig_rdy.write(0);

        accumulator = 0;
        for(i = 0; i < 5; i++)
        {
            accumulator = accumulator + (taps[i] * coef[i]);
        }

        //Handshaking
        outp_sig_vld.write(1);
        outp.write(accumulator);
        do
        {
            wait();
        }
        while( !outp_sig_rdy.read() );
        outp_sig_vld.write(0);

        wait();
        //wait 1 cycle and repeat
    }
}
