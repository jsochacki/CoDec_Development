//This is my first system c file, YAY!!

#include <systemc.h>

#define DT sc_uint<1>

//and2 is the name of the module
SC_MODULE( and2a )
{
    //DT is a macro for data type
    //However it doesn't need to be DT as there are other options you will use
    //There are a variety of different data types available in systemc
    //One of which is the integer
    //  System c has bit accurate versions of the integer data type that has a fixed width
    //      and allow bit select and part(chunk) select opperations
    //  This is different from the generic int in c
    //      You can use int if you want and it will synthesize but it will not have
    //      many features and it will always be the bit width of your processor
    //  There are two types of integer: signed and unsigned
    //  sc_uint<N> is the template to declare a unsigned int where N is the bit width and
    //  sc_int<N> is the template to declare a signed int where N is the bit width
    //sc_in has the method .read() to read values from it e.g. f = a.read();
    sc_in<DT>   a, b;
    //Here we use bool as the clock is just a single wire
    //sc_in<bool> clk;
    //sc_out has the method .write() to write values to it e.g. f.write(a);
    sc_out<DT>  f;

    //We add a member function to our module do operations
    void func()
    {
        f.write( a.read() & b.read() );
    }

    //Threads are made to act like a hardware process and each of them will run concurrently
    // in parallel.  As the user you have no control of them once you construct them
    // and they will continue to run and simulate concurrency and event driven actions.
    //There are 3 types of threads
    //SC_METHOD()
    //  Threads that execute once in their entirety every time they are triggered by a
    //      sensitive event
    //  They run continuously
    //  They are analagous to a verilog @always block
    //  They are synthesizable and useful for combinational logic or small single clock
    //      cycle combinational logic
    //SC_THREAD()
    //  These run once and only once at the beginning of a simulation and then are suspended
    //      when done
    //  If you want them to execute continuously you can put an infinite loop
    //      in them if you want and execute code at a fixed rate of time
    //  They are similar to a verilog initial block EXCEPT THEY ARE NOT SYNTHESIZABLE while
    //      a verilog initial block is
    //  They are useful in test benches or inital start up signals
    //SC_CTHREAD()
    //  The c stands clocked
    //  They run continuously and can only be sensitive to a clock edge
    //  They are synthesizable
    //  They are different from SC_METHODS as they can take 1 or more clock cycled to
    //      execute
    //  You are going to use them in almost everything

    //This is the constructor, it must have the same name as the module
    //It goes inside the module.
    //It is only run once when the module is instatiated for simulation
    //It is where you specify if your modules sensitivity list or designate
    //Waveform trace signals
    SC_CTOR( and2a )
    {
        SC_METHOD( func );      //This now designates that func is a SC_METHOD thread
        sensitive << a << b;    //This specifies the sensitivity list for this SC_METHOD
        //sensitive << clk.pos(); //clk is a class in systemc and has the .pos() method

    }
};  //UNLIKE IN C OR C++ YOU NEED A SEMICOLON HERE!!!!!!!!!!!!!
