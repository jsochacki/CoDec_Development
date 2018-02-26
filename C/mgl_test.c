// totally works, I installed it and qt5 etc
// with apt get

// then all I had to do was link the library
// with -lmgl
// and the path with -L /usr/lib

#include <mgl2/mgl_cf.h>

int main()
{
    HMGL gr = mgl_create_graph(600,400);
    mgl_fplot(gr,"abs(sin(pi*x))","","");
    mgl_write_frame(gr,"test.png","");
    mgl_delete_graph(gr);
}
