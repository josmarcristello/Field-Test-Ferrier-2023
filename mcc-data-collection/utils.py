from numpy import arange, interp

def resample_data_lin(data, times):
    if times == 0 : return data
    Y = data
    N = len(Y)
    X = arange(0, times*N, 2)
    X_new = arange(times*N-1)       # Where you want to interpolate
    Y_new = interp(X_new, X, Y) 
    print("actually linearly interpolated")
    return Y_new
