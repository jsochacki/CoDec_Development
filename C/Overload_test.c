#include <stdio.h>

int main()
{
    if (__builtin_types_compatible_p(float,float))
        {
        printf("yes");
        }
    else
        {
        printf("no");
        }
    return 0;
}
