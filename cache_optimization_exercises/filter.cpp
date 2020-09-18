#include <stdio.h>
#include <stdlib.h>
#include "filter.h"

// modify this code by fusing loops together
void filter_fusion(pixel_t **image1, pixel_t **image2)
{
    for (int i = 1; i < SIZE - 1; i++)
    {
        filter1(image1, image2, i);
        if (i >= 2 && i < SIZE - 2)
        {
            filter2(image1, image2, i);
        }
        if (i > 5)
        {
            filter3(image2, i - 5);
        }
    }
    filter3(image2, SIZE - 6);
}

// modify this code by adding software prefetching
void filter_prefetch(pixel_t **image1, pixel_t **image2)
{
    for (int i = 1; i < SIZE - 1; i++)
    {
        __builtin_prefetch(image1[i + 15], 0, 3);
        __builtin_prefetch(image2[i + 15], 1, 0);
        filter1(image1, image2, i);
    }

    for (int i = 2; i < SIZE - 2; i++)
    {
        __builtin_prefetch(image1[i + 11], 0, 3);
        __builtin_prefetch(image2[i + 11], 1, 0);
        filter2(image1, image2, i);
    }

    for (int i = 1; i < SIZE - 5; i++)
    {
        __builtin_prefetch(image1[i + 13], 0, 1);
        __builtin_prefetch(image2[i + 13], 1, 0);
        filter3(image2, i);
    }
}

// modify this code by adding software prefetching and fusing loops together
void filter_all(pixel_t **image1, pixel_t **image2)
{
    for (int i = 1; i < SIZE - 1; i++)
    {
        __builtin_prefetch(image1[i + 7], 0, 1);
        __builtin_prefetch(image2[i + 7], 1, 0);
        filter1(image1, image2, i);
        if (i >= 2 && i < SIZE - 2)
        {
            filter2(image1, image2, i);
        }
        if (i > 5)
        {
            filter3(image2, i - 5);
        }
    }
    filter3(image2, SIZE - 6);
}
