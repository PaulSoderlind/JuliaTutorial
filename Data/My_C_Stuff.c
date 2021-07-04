#include <stddef.h>

// calculate the inner (dot) product of vectors Y and Y, returns the result (Sxy)
double c_dot(size_t n, double *Y, double *X) {
    double Sxy = 0.0;
    for (size_t i = 0; i < n; ++i) {
        Sxy += X[i]*Y[i];
    }
    return Sxy;
}

// calculate a simple regression, Y = a + b*X + u, puts (a,b) in vector ab, returns nothing
void c_ols(size_t n, double *Y, double *X, double *ab) {
    double Sx = 0.0, Sy = 0.0, Sxx = 0.0, Sxy = 0.0;
    for (size_t i = 0; i < n; ++i) {
        Sx  += X[i];
        Sy  += Y[i];
        Sxx += X[i]*X[i];
        Sxy += X[i]*Y[i];
    }
    ab[1] = (Sxy-Sx*Sy/n)/(Sxx-Sx*Sx/n);   //slope
    ab[0] = (Sy - ab[1]*Sx)/n;             //intercept
}