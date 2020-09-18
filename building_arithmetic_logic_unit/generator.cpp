#include <cstdio>
using std::printf;

int main() {
    int width = 32;
    for (int i = 2 ; i < width ; i ++) {
        printf("alu1 a%d(out[%d], c[%d], A[%d], B[%d], c[%d], control);\n", i, i, i, i, i, i-1);
    }
}
