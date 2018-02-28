#include "tb.h"

sc_time start_time, end_time;

void tb::source(void)
{
    inp_sig_vld.write(0);
    // Reset, initialize rst and inp
    //set inp = 0
    inp.write(0);
    //set rst high
    rst.write(1);
    //clock cycle
    wait();
    //deassert rst
    rst.write(0);
    //clock cycle
    wait();

    //Need handshaking signals to make sure data transfers are valid
    sc_int<16> tmp;
    int i = 0;
    //Send stimulus to FIR
    for(i = 0; i < 64; i++)
    {
        if(i > 23 && i < 29)
        {
            tmp = 256;
        }
        else
        {
            tmp = 0;
        }

        //Handshaking
        inp_sig_vld.write(1);
        inp.write( tmp );
        start_time[i] = sc_time_stamp();
        do
        {
            wait();
        }
        while( !inp_sig_rdy.read() );
        inp_sig_vld.write(0);

        wait();
    }
    // To prevent hanging
    wait(10000);
    printf("Simulation was hanging and force shut down, please check dut.\n");
    sc_stop();

}

void tb::sink(void)
{
    sc_int<16>      indata;
    int i = 1;

    // use the get_interface on the clock to get the info about the clock
    // cast it to the sc_clock type
    // then look at the period and assign to our variable
    sc_clock *clk_p = dynamic_cast<sc_clock*>(clk.get_interface());
    clock_period = clk_p->period();

    char output_file[256];
    sprintf( output_file, "./output.dat");
    outfp = fopen( output_file, "w");
    if( outfp == NULL )
    {
        printf("failed to open the file output.dat\n");
        //This exits the simulation
        exit(0);
    }

    outp_sig_rdy.write(0);

    double total_cycles = 0;
    //Read data from the dut
    for(i = 0; i < 64; i++)
    {
        //Handshaking
        outp_sig_rdy.write(1);
        do
        {
            wait();
        }
        while( !outp_sig_vld.read() );
        indata = outp.read();

        //Benchmarking
        end_time[i] = sc_time_stamp();
        total_cycles += (end_time[i] - start_time[i]) / clock_period;

        outp_sig_rdy.write(0);

        fprintf( outfp, "%d\n", indata.to_int());
        std::cout << i << " :\t" <<
             indata.to_int() << std::endl;

        wait();

    }

    //Status reporting
    printf("average latency is %g cycles. \n", (double) (total_cycles / 64));
    double total_throughput = (start_time[63] - start_time[0]) / clock_period;
    printf("average throughput is %g cycles per input. \n", (double) (total_throughput / (64 - 1)));

    //Close file
    fclose(outfp);
    //stop the simulation and call the module destructors
    sc_stop();
}



