#include "gpio.h"
#include "event.h"
#include <signal.h>
#include <sys/time.h>
class Counter {
  public:
    Counter(unsigned int pin):
      counter(0),
      interrupt(pin, rising) {
        interrupt.pull(down);
    }
    Counter(): counter(-1) {}
    unsigned int inc() {counter++;}
    unsigned int read() {
        unsigned int ret = counter;
        counter = 0;
        return ret;
    }
    int counter;
  private:
    GpioInput interrupt;
};
class PerInterval {
  public:
    PerInterval(long m)/*: output(0)*/ {
        //output.high(false);
        mask = m;
        for(int i = 0; i <= lastPin; i++) {
            if(mask & (1 << i)) counter[i] = Counter(i);
        }
    }
    void *operator()() {
        //signal(SIGINT, sighandler);
        //signal(SIGPIPE, sighandler);
        //signal(SIGTERM, sighandler);
        while(true) {
            if(GpioInput::wait(isr) < 0) break;
            //output.high(false);
        }
        return 0;
    }
    void *operator()(siginfo_t *) {
        static int c[lastPin + 1];
        Time time;
        {
            Lock lock(StaticMutex<PerInterval>::mutex());
            for(int i = 0; i <= lastPin; i++) {
                if(counter[i].counter < 0) c[i] = counter[i].counter;
                else c[i] = counter[i].read();
            }
        }
        int t = time;
        printf("%d 1.0 ", t);
        for(int i = 0; i <= lastPin; i++) {
            if(c[i] >= 0) printf("%d ", c[i]);
        }
        printf("2500\n");
    }
    //GpioOutput output;
    static void isr(unsigned int number) {
        Lock lock(StaticMutex<PerInterval>::mutex());
        static timeval last[lastPin + 1] = {0};
	timeval now;
	gettimeofday(&now, 0);
	int usecDiff = now.tv_usec - last[number].tv_usec;
        int secDiff = now.tv_sec - last[number].tv_sec;
        if(usecDiff < 0) {
            secDiff--;
            usecDiff += 1000000;
        }
        if(secDiff == 0 && usecDiff < 200000) {
            //printf("Discarding int %d because time diff is only %dµs\n", number, usecDiff);
        }
        else {
            //printf("got interrupt on pin %d, last one occurred %d.%06d second ago\n", number, secDiff, usecDiff);
            counter[number].inc();
        }
	last[number] = now;
    }
    static Counter counter[lastPin + 1];
    static void sighandler(int) {}
    static unsigned long long mask;
};
Counter PerInterval::counter[lastPin + 1];
unsigned long long PerInterval::mask;
// The time that a multiple of counter interval should fit in.
const int day = 24 * 60 * 60;
// Just to calculate the maximum pin mask value.
template <unsigned long long N> struct Power {static const unsigned long long value = 2 * Power<N - 1>::value;};
template <> struct Power<0> {static const unsigned long long value = 1;};
int  main(int argc, const char *argv[]) {
    setlinebuf(stdout);
    setlinebuf(stderr);
    failure(argc != 3, -2, "Usage: %s <pinmask> <interval>", argv[0]);
    // Calculate and check pin mask.
    unsigned long long mask = strtoull(argv[1], 0, 0);
    failure(mask <= 0 || mask >= Power<lastPin + 1>::value, -2,
            "The %d bit pinmask must be an integer between 1 and 0x%x",
            lastPin + 1, Power<lastPin + 1>::value - 1);
    // Calculate and check counter interval.
    long interval = atol(argv[2]);
    failure(interval <= 0 || day % interval, -2, "The seconds per day must be a multiple of interval");
    // Day must be a multiple of counter interval.
    sigset_t set;
    sigemptyset(&set);
    //sigaddset(&set, SIGINT);
    //sigaddset(&set, SIGPIPE);
    //sigaddset(&set, SIGTERM);
    //ASSERT(pthread_sigmask(SIG_BLOCK, &set, 0) == 0, "");
    PerInterval intervalObject(mask);     
    Thread<PerInterval> updateThread(intervalObject, "counter", 90);
    EventThread<PerInterval> readerThread(intervalObject, "reader", 80);
    Time time;
    readerThread.run((double) interval, (double ((long long) (time + (double) interval) / interval * interval)));
    updateThread.join();
    fprintf(stderr, "readerThread has terminated!\n");
    readerThread.terminate();
    readerThread.join();
    return 0;
}
