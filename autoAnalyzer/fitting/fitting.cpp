#include <mex.h>
#include <math.h>
#include <boost/math/special_functions/erf.hpp>

using boost::math::erf;

const double sqrt2 = sqrt(2.);

//nrhs = number right hand side: array length of prhs
//prhs = pointer right hand side: introduces initialFitParams from Matlab
//nlhs = number left hand
//prhs = pointe left hand side: returns fitParams to Matlab

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) 
{
	const double* params   = (double*) mxGetData(prhs[0]); //Guessing values for starting the fit
	//params[0] = sum of all pixels minus offset(Background)
	const double xMean     = params[1] - 1; //centre of image
	const double yMean     = params[2] - 1; //centre of image
	const double xVar      = params[3]; //Variance in x
	const double yVar      = params[4]; //Variance in y
	const double offset    = params[5]; //(min(spotsImage)*windowSize)^2 (Background)
    const double theta     = params[6]; //Orientation of 2D-Gaussian

	const double* settings = (double*) mxGetData(prhs[1]);
	size_t m               = (size_t) settings[0]; //x-pixels
	size_t n               = (size_t) settings[1]; //y-pixels
	
	const double u1        = cos(theta);
	const double u2        = sin(theta);
	const double v1        = u2;
	const double v2        = -u1;

	plhs[0]                = mxCreateNumericMatrix(m, n, mxDOUBLE_CLASS, mxREAL);
	double* result         = mxGetPr(plhs[0]);
	for(size_t j = 0; j < n; j++) { //Iterate through y-pixels
		for(size_t i = 0; i < m; i++) { //Iterate through x-pixels
			double dx = u1*(j-xMean) + u2*(i-yMean);
			double dy = v1*(j-xMean) + v2*(i-yMean);
			result[j*m+i] = params[0] * .25
				* (erf((dx+.5)/sqrt2/xVar) - erf((dx-.5)/sqrt2/xVar))
				* (erf((dy+.5)/sqrt2/yVar) - erf((dy-.5)/sqrt2/yVar))
				+ offset; //Gaussian function defined over error-function
		}
	}
}