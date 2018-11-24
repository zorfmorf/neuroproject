#include <mex.h>
#include <math.h>
#include <boost/math/special_functions/erf.hpp>

using boost::math::erf;

const double sqrt2 = sqrt(2.);

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
	const double* params   = (double*) mxGetData(prhs[0]);
	const double xMean     = params[1] - 1;
	const double yMean     = params[2] - 1;
	const double xVar      = params[3];
	const double yVar      = params[4];
	const double offset    = params[5];

	const double* settings = (double*) mxGetData(prhs[1]);
	size_t m               = (size_t) settings[0];
	size_t n               = (size_t) settings[1];
	const double theta     = settings[2];
	const double u1        = cos(theta);
	const double u2        = sin(theta);
	const double v1        = u2;
	const double v2        = -u1;

	plhs[0]                = mxCreateNumericMatrix(m, n, mxDOUBLE_CLASS, mxREAL);
	double* result         = mxGetPr(plhs[0]);
	for(size_t j = 0; j < n; j++) {
		for(size_t i = 0; i < m; i++) {
			double dx = u1*(j-xMean) + u2*(i-yMean);
			double dy = v1*(j-xMean) + v2*(i-yMean);
			result[j*m+i] = params[0] * .25
				* (erf((dx+.5)/sqrt2/xVar) - erf((dx-.5)/sqrt2/xVar))
				* (erf((dy+.5)/sqrt2/yVar) - erf((dy-.5)/sqrt2/yVar))
				+ offset;
		}
	}
}