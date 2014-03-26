#ifndef EVENT_H
#define EVENT_H
#include "task.h"
#include <signal.h>
#include <time.h>
class Time {
  public:
    Time(clockid_t clock = CLOCK_REALTIME) {clock_gettime(clock, &time);}
    Time(double t) {
        time.tv_sec = t;
        time.tv_nsec = (t - time.tv_sec) * nanoSecondsPerSecond;
    }
    Time &operator+(double offset) {
        time.tv_sec += offset;
        time.tv_nsec += (offset - (int) offset) * nanoSecondsPerSecond;
        // Overflow in nanoseconds?
        if(time.tv_nsec >= nanoSecondsPerSecond) {
            time.tv_sec++;
            time.tv_nsec -= nanoSecondsPerSecond;
        }
        // Underflow in nanoseconds?
        if(time.tv_nsec < 0) {
            time.tv_sec--;
            time.tv_nsec += nanoSecondsPerSecond;
        }
        return *this;
    };
    operator double() const {
        return time.tv_sec + time.tv_nsec / nanoSecondsPerSecond;
    }
    operator timespec() const {return time;}
  private:
    timespec time;
    static const int nanoSecondsPerSecond = 1000000000;
};
// Signal number management.
class SignalNumbers {
  public:
    // Just to set the proc mask before the creation of any threads.
    SignalNumbers(): dummy(signalNumberIsUsed(1)) {}
    // This could also have been a #define, but this is more local.
    static const int standardSignalEnd() {return 33;}
    // Returns a reference to the EventThread instance belonging to a
    // signal or a reference to 0 if no instance belongs to that signal.
    static bool &signalNumberIsUsed(int signalNumber) {
        // Initialize signal-to instance mapping.
        static bool *usedSignalNumbers = Initialize::signalNumbers();
        // Return the appropriate EventThread instance.
        return usedSignalNumbers[signalNumber];
    }
  private:
    bool dummy;
    // Signal list initialization.
    struct Initialize {
        // Signal numbers that cannot be used (e.g. because they are
        // used elsewhere or cannot be caught) must be listed here.
        static bool *signalNumbers() {
            // NSIG is 65 or 33, depending on whether realtime signals are available.
            static bool usedSignalNumbers[NSIG - 1];
            // Cannot be caught.
            usedSignalNumbers[SIGABRT] = true;
            usedSignalNumbers[SIGKILL] = true;
            // Standard behaviour for these signals may be useful.
            // Add as appropriate.
            usedSignalNumbers[SIGINT] = true;
            usedSignalNumbers[SIGFPE] = true;
            usedSignalNumbers[SIGSEGV] = true;
            usedSignalNumbers[SIGBUS] = true;
            usedSignalNumbers[SIGTRAP] = true;
            // Used internally by libpthread.
            for(int i = standardSignalEnd(); i < SIGRTMIN; i++) {
                usedSignalNumbers[i] = true;
            }
            // All signals that may be used here (i.e. all signals that are not
            // listed in initializeInstanceByNumberList()) must be masked for the
            // entire process. This happens exacty once when the first valid
            // EventThread instance is instantiated, ensuring that all threads
            // see the same signal mask.
            sigset_t set;
            sigemptyset(&set);
            // We start with either 1 or 33.
            for(int i = NSIG - standardSignalEnd() + 1; i < NSIG; i++) {
                if(!usedSignalNumbers[i]) {
                    sigaddset(&set, i);
                }
            }
            // This is an ugly patch allowing to wait for SIGUSR1 in cleanup code.
            //if(audis()) sigaddset(&set, SIGUSR1);
            pthread_sigmask(SIG_BLOCK, &set, 0);
            // Return the initialized list.
            return usedSignalNumbers;
        }
    };
};
class Signals {
  public:
    Signals() {errno_error(sigemptyset(&set));}
    // This is only called by EventFunctors. But as different
    // EventFunctors have different types, a template is needed.
    template<typename T> void operator()(T &t) {errno_error(sigaddset(&set, t.signalNumber()));}
    int wait(siginfo_t *info) {
        int ret = sigwaitinfo(&set, info);
        // This is a dirty hack to make the debugger (gdb) work.
        // We should never enter the if statement without debugger.
        if(ret < 0 && errno == EINTR) {
            //fprintf(stderr,
            //        "system call was interupted by signal %d, si_errno says %s and errno says %s; resuming\n",
            //        info.si_signo,
            //        strerror(info.si_errno),
            //        strerror(errno)
            //       );
            return 0;
        }
        errno_error(ret);
        return ret;
    }
  private:
    sigset_t set;
};
template<typename EventFunctor = void (*)(siginfo_t *info)> class EventThread:
  Mutex, SignalNumbers, public Thread<EventThread<EventFunctor> > {
  public:
    // Creates a new EventThread instance.
    EventThread(EventFunctor &eventFunctor,
                const char *name = "",
                int prio = 1,
                clockid_t clock = CLOCK_REALTIME,
                int stackSize = 20000
               ):
      // We need to derive from Mutex to ensure that it is
      // locked before any member initializers are executed.
      Mutex(true),
      Thread<EventThread>(*this, name, prio, stackSize),
      _eventFunctor(eventFunctor),
      _signalNumber(allocateSignalNumber()),
      _clock(clock),
      _terminate(false),
      _duration(0) {
        if(validClock()) {
            struct sigevent event;
            event.sigev_notify = SIGEV_SIGNAL;
            event.sigev_signo = _signalNumber;
            event.sigev_value.sival_ptr = this;
            errno_error(timer_create(_clock, &event, &_timer));
        }
        unlock();
    }
    // Is designed to be executed by a Thread, waiting for the
    // corresponding signal to execute _eventFunctor.
    void *operator()() {
        Lock lock(*this);
        siginfo_t info;
        Signals signals;
        // Add signals to signal set.
        signals(*this);
        while(true) {
            timespec start, end;
            if(!signals.wait(&info)) continue;
            errno_error(clock_gettime(CLOCK_MONOTONIC, &start));
            if(_terminate) break; else (_eventFunctor)(&info);
            errno_error(clock_gettime(CLOCK_MONOTONIC, &end));
            _duration = (end.tv_sec - start.tv_sec) * 1000000 +
                        (end.tv_sec - start.tv_sec) / 1000;
        }
        return 0;
    }
    // Sends signal once and immediately.
    void run() {
        union sigval info;
        info.sival_ptr = this;
        errno_error(sigqueue(getpid(), _signalNumber, info));
    }
    // Use positive intervals for absolute start time
    // and negative intervals for relative start time.
    // An interval of zero starts a oneshot timer with
    // absolute expiration time. Caveat: Oneshot timers
    // with relative expiration times need to be simulated
    // by calling clock_gettime() and adding the relative
    // time.
    void run(double interval, const Time &start) {
        // We need a valid timer.
        if(validClock()) {
            struct itimerspec time;
            int flags;
            if(interval >= 0) flags = TIMER_ABSTIME; 
            else {
                interval = -interval;
                flags = 0;
            }
            time.it_interval = Time(interval);
            time.it_value = start;
            errno_error(timer_settime(_timer, flags, &time, 0));
        }
    }
    // Stop a periodic timer.
    void stop() {
        if(validClock()) {
            struct itimerspec time;
            // These values disarm the timer.
            time.it_value.tv_sec = time.it_value.tv_nsec = 0;
            time.it_interval.tv_sec = time.it_interval.tv_nsec = 0;
            errno_error(timer_settime(_timer, 0, &time, 0));
        }
    }
    void terminate() {
        stop();
        _terminate = true;
        run();
    }
    // A signal number of 0 indicates an invalid EventThread.
    int signalNumber() const {return _signalNumber;}
    // If access to members of the contained type is needed.
    // This is also the preferred method to check if this
    // is a valid event.
    EventFunctor &eventFunctor() {return _eventFunctor;}
    // Poll timer overruns.
    int overruns() {return timer_getoverrun(_timer);}
    // Returns the last cycle's duration.
    unsigned long duration() {return _duration;}
  private:
    // Returns an unused signal number or 0 if all signal numbers are in use.
    int allocateSignalNumber() {
        // We only consider either standard or realtime signals,
        // i.e incrementing from either 1 or 33 to 32 or 64.
        for(int i = NSIG - SignalNumbers::standardSignalEnd() + 1; i < NSIG; i++) {
            bool &used = SignalNumbers::signalNumberIsUsed(i);
            if(!used) {
                // Mark the signal as being in use.
                used = true;
                return i;
            }
        }
        return 0;
    }
    // Releases a the current signal number.
    void releaseSignalNumber() {SignalNumbers::signalNumberIsUsed(_signalNumber) = false;}
    bool validClock() {
        if(_clock == CLOCK_REALTIME) return true;
        if(_clock == CLOCK_MONOTONIC) return true;
        return false;
    }
    // The pointer to the code that shall run when
    // the corresponding signal is dispatched.
    EventFunctor &_eventFunctor;
    // The signal number that causes the code to
    // be run.
    int _signalNumber;
    // Needed if timers are involved.
    timer_t _timer;
    clockid_t _clock;
    // Test if thread should terminate.
    bool _terminate;
    // The number of µs to process last cycle.
    unsigned long _duration;
};
#endif
