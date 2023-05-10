import sys
from matplotlib import pyplot, cm, colors
import numpy
from scipy.fft import fft, fftfreq, rfft, irfft
from scipy.interpolate import LinearNDInterpolator
import scipy.signal as signal
import scipy
from tools.timer import timer
t=timer.time
s=timer.set


SAMPLES_PER = 51200
MAX_ROWS_TO_IMPORT = 51200*10

file_list = []
def main() :
    s()
    # Command line options
    if(len(sys.argv) == 1) :
        print("Incorrect Usage,\n Usage: python data_hist.py <data options> <plot options> <realitive_file_path>")
        return

    
    data_options = sys.argv[1]
    plot_options = sys.argv[2]

    t("data load")


    if(len(sys.argv) < 4) : print("No files entered")
    #Additional files input to plot at the same time all with the same options
    file_list = sys.argv[3:]
    import re

    # get_end = lambda path: re.match("[0-z]*(?=.csv)", path)
    # file_ending_name_list = [get_end(i) for i in file_list]
    # print(file_ending_name_list)
    # return

    data = []

    t("data import")
    for i in file_list:
        data_csv = numpy.loadtxt(i, delimiter=',',skiprows=1, max_rows=30000)
        ch_0:numpy.ndarray = data_csv[:, 0]
        ch_1:numpy.ndarray = data_csv[:, 1]
        ch_2:numpy.ndarray = data_csv[:, 2]
        ch_3:numpy.ndarray = data_csv[:, 3]

        # Data Modification Options
        if("a" in data_options) : data.extend([ch_0, ch_1])
        if(("r" not in data_options) and ("0" not in data_options) and ("1" not in data_options) and ("d" not in data_options)) : data.extend([ch_0, ch_1])
        if("0" in data_options) : data.append(ch_0)
        if("1" in data_options) : data.append(ch_1)
        if("d" in data_options) : data.append(ch_1-ch_0) #this order to maintain backwards compatibiity
        if("IZ" in data_options) : data.append(interspace_data(ch_0, ch_1))
        if("IO" in data_options) : data.append(interspace_data(ch_1, ch_0))
        if("m" in data_options) : data.append(remove_dom_freq(ch_0))
        if("c" in data_options) : data.extend([decimate(ch_0), decimate(ch_1)])
        if("i" in data_options) : data.append(ch_0/ch_1)

        if("p" in data_options) : 
            d = ch_1-ch_0
            mean = numpy.average(d)
            # SR = 51.2*1000 #S/s
            # F = 119

            gain = 0
            data.append(d-mean-gain)

        if("e" in data_options) : 
            a,b = add_delay(ch_0, ch_1, 1)
            data.append(b-a)

    # Visualisation Options
    if("p" in plot_options) : plot(data)
    if("h" in plot_options) : histagram(data)
    if("t" in plot_options) : fftt(data) #Intensity-Frequency
    if("s" in plot_options) : fftp(data) #Intensity-Phase
    if("c" in plot_options) : 
        s()
        for i in data: colour_plot(i)
  


# method to interspace data from both channels
def interspace_data(ch_0, ch_1) :
    array = numpy.empty(len(ch_0) + len(ch_1), dtype=float)
    array[0::2] = ch_0
    array[1::2] = ch_1
    return array

def decimate(ch): return signal.decimate(ch, 5)

from math import pi
def remove_dom_freq(ch) :
    xf = fftfreq(len(ch), 1 / SAMPLES_PER)
    yf = fft(ch)

    max_index = numpy.argmax( abs( yf ) ) #Get index of fft with highest frequency in the positive range
    
    print(f"frequency: {xf[max_index]} Intensity: {numpy.abs(yf[max_index])}, phase: {numpy.angle(yf[max_index])}")

    p = numpy.angle(yf[max_index])

    A = numpy.abs(yf[max_index])/len(xf)*2

    w = xf[max_index]*2*pi #Convert to angular frequency

    x = numpy.linspace(0,100, 99999)

    sin_to_subt = A*numpy.sin(w*x + p)
    print(f"{A}sin({w}t + {p})")
    return ch-sin_to_subt



    # Number of samplepoints
    N = 500
    # sample spacing
    T = 0.1

    x = np.linspace(0.0, (N-1)*T, N)
    # x = np.arange(0.0, N*T, T)  # alternate way to define x
    y = 5*np.sin(x) + np.cos(2*np.pi*x) 

    yf = fft(y)
    xf = fftfreq(len(ch), 1 / SAMPLES_PER)
    xf = np.linspace(0.0, 1.0/(2.0*T), N//2)
    # fft end

    f_signal = rfft(ch)
    W = fftfreq(len(ch), 1 / SAMPLES_PER)
    # W = fftfreq(y.size, d=x[1]-x[0])

    cut_f_signal = f_signal.copy()
    mfreq = max(cut_f_signal)
    cut_f_signal[(W>0.6)] = 0  # filter all frequencies above 0.6

    cut_signal = irfft(cut_f_signal)
    return cut_signal


    # plot results
    f, axarr = plt.subplots(1, 3, figsize=(9, 3))
    axarr[0].plot(x, y)
    axarr[0].plot(x,5*np.sin(x),'g')

    axarr[1].plot(xf, 2.0/N * np.abs(yf[:N//2]))
    axarr[1].legend(('numpy fft * dt'), loc='upper right')
    axarr[1].set_xlabel("f")
    axarr[1].set_ylabel("amplitude")


    axarr[2].plot(x,cut_signal)
    axarr[2].plot(x,5*np.sin(x),'g')

    plt.show()


def rem_dom_f(ch) :
    # Number of samplepoints
    N = 500
    # sample spacing
    T = 0.1

    x = linspace(0.0, (N-1)*T, N)
    # x = np.arange(0.0, N*T, T)  # alternate way to define x
    y = 5*sin(x) + cos(2*pi*x) 

    yf = fft(y)
    xf = linspace(0.0, 1.0/(2.0*T), N//2)
    #fft end

    f_signal = rfft(y)
    W = fftfreq(y.size, d=x[1]-x[0])

    cut_f_signal = f_signal.copy()
    cut_f_signal[(W>0.6)] = 0  # filter all frequencies above 0.6

    cut_signal = irfft(cut_f_signal)

    # plot results
    f, axarr = plt.subplots(1, 3, figsize=(9, 3))
    axarr[0].plot(x, y)
    axarr[0].plot(x,5*np.sin(x),'g')

    axarr[1].plot(xf, 2.0/N * np.abs(yf[:N//2]))
    axarr[1].legend(('numpy fft * dt'), loc='upper right')
    axarr[1].set_xlabel("f")
    axarr[1].set_ylabel("amplitude")


    axarr[2].plot(x,cut_signal)
    axarr[2].plot(x,5*np.sin(x),'g')

    plt.show()

def add_delay(ch0, ch1, delay) :
    return ch0[0:-delay], ch1[delay:]



GLOBAL_TRANSPARENT = 0.8
# Visualisation methods
def plot(data) :
    for ic, i in enumerate(data):
        if ic == 2 or ic == 3: 
            i = i/100

        pyplot.plot(i, label=f"Data: {ic}", alpha= (1 if len(file_list)==1 else GLOBAL_TRANSPARENT))
    
    
    pyplot.title("Plot")
    pyplot.legend(loc='upper right') #Show input Labels
    pyplot.xlabel("Sample Number")
    pyplot.ylabel("Voltage (V)")

    pyplot.show()
l = ["MCC 172", "NI 9215"]
def histagram(data, file="Histogram") :
    DYNAMIC_BUCKETS = 1000/(51200*15)
    BUCKETS= 1000
    for ic, i in enumerate(data):
        if ic == 1: 
            i = i/100
        # weight = numpy.ones(len(i)) / len(i)
        print("std dev",numpy.std(i))
        pyplot.hist(i, int(BUCKETS), label=f"{l[ic]}", alpha= (1 if len(file_list)==1 else GLOBAL_TRANSPARENT) )

    pyplot.xlabel("Voltage Difference")
    pyplot.ylabel("Percentage of Samples")
    pyplot.title(file)
    # pyplot.xlim(-0.0010, 0.0010)
    # pyplot.ylim(0, 0.006)
    pyplot.legend(loc='upper right') #Show input Labels
    pyplot.show()

def fftt(data) :
    #FFT
    pyplot.title("FFT: Frequency vs Power")

    for ic, i in enumerate(data):
        xf = fftfreq(len(i), 1 / SAMPLES_PER)
        # pyplot.plot(xf, numpy.log(abs(fft(i))))
        fft_data = fft(i)
        abs_fft = abs(fft_data)

        pyplot.plot(xf, abs_fft,label=f"Data: {[ic]}", alpha= (1 if len(file_list)==1 else GLOBAL_TRANSPARENT))

        peak_index = numpy.argmax(abs_fft)

        peak_freq = xf[peak_index]
        peak_phase = numpy.angle(fft_data[peak_index])
        peak_power = numpy.abs(fft_data[peak_index])

        print(f"Max peak info: ", peak_freq, peak_phase, peak_power  )

    # pyplot.xlim(left=-5)
    pyplot.xlabel("Frequency")
    pyplot.ylabel("Power")
    pyplot.legend(loc=7)
    pyplot.show()

def fftp(data):
    pyplot.title("FFT: Phase Shift vs Power")

    for ic, i in enumerate(data):
        ft = fft(i)
        pyplot.plot(numpy.angle(ft), abs(ft), label=f"Data {ic}", marker=None ,alpha= (1 if len(file_list)==1 else GLOBAL_TRANSPARENT))

    pyplot.legend(loc='upper right')
    pyplot.xlim((-3.17, 3.17))
    pyplot.ylim(bottom=-5)
    pyplot.xlabel("Phase")
    pyplot.ylabel("Power")
    pyplot.show()


def colour_plot(ch) :
    
    C_fft_data = fft(ch)
   
    x = fftfreq(len(ch), 1 / SAMPLES_PER) #Frequency
    y = numpy.angle(C_fft_data) #Phase shift
    z = numpy.abs(C_fft_data) #Intensity 

    X = numpy.linspace(0, 5000, 500)
    Y = numpy.linspace(-pi, pi, 60)

    s()
    X, Y = numpy.meshgrid(X, Y)  # 2D grid for interpolation
    t('meshgrid')
    interp = LinearNDInterpolator(list(zip(x, y)), z)
    t('linNdinterp')
    Z = interp(X, Y)
    
    t(f'mass interp {Z.size}')
    
    MAX = Z[Z.argmax()]


    def _forward(d) :
        return d/MAX  
    def _inverse(d) :
        return d*MAX

    # # Log PCT
    # def _forward(d) :
    #     return numpy.log(d/MAX +1)
    # def _inverse(d) :
    #     return ((10**d) -1)*MAX

    # def _forward(d) :
    #     return (d/MAX)**3  
    # def _inverse(d) :
    #     return (d*MAX)**3
    
    class cus_norm(colors.Normalize):
        def _forward(d) :
            return numpy.log(d/MAX +1)
        def _inverse(d) :
            return ((10**d) -1)*MAX

    # pyplot.pcolormesh(X, Y, Z, shading='nearest', cmap='rainbow')
    # pyplot.pcolormesh(X, Y, Z, shading='nearest', cmap='rainbow', norm=colors.LogNorm())
    pyplot.pcolormesh(X, Y, Z, shading='auto', cmap='rainbow', norm=cus_norm())
    t("colour mesh")
    # pyplot.plot(X, Y)
    pyplot.scatter(X, Y, 400, facecolors="none")

    t("scatter")
    pyplot.colorbar()

    pyplot.title("FFT")
    pyplot.xlabel("Frequency (Hz)")
    pyplot.ylabel("Phase Shift (Rads)")

    pyplot.xlim([-5, 5000])
    pyplot.ylim([-pi, pi])
    t("before show")
    pyplot.show()
    t("after show")



# Random tools
from tools.RMSE import RMSE 
def fft_lin_test(ch0, ch1):
    a = fft(ch0) - fft(ch1)
    b = fft((ch0-ch1))
    print("fft linear" , RMSE(a, b), max(abs(a-b)))


if __name__ == '__main__' :
    main()