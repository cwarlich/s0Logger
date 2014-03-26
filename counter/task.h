#ifndef TASK_H
#define TASK_H
#include "mutex.h"
#include <math.h>
#include <string>
#include <map>
#define SCHEDULING_POLICY SCHED_FIFO
class ThreadBase;
ThreadBase *self();
#define PTHREAD_TIMEDOUT ((void *) -2)
class ThreadBase {
  public:
    int getPriority() {return _param.sched_priority;}
    void setPriority(int priority) {
        _param.sched_priority = priority;
        if(priority) return_error(pthread_setschedparam(_id, SCHEDULING_POLICY, &_param));
        else return_error(pthread_setschedparam(_id, SCHED_OTHER, &_param));
    }
    const char *name() {return _name.c_str();}
    // Joins an existing thread. Returns the exit status of the joined thread.
    // Negative values cause timeout to be infinite.
    // Note that POSIX returns PTHREAD_CANCELED ((void *) -1) if the thread is
    // canceled; similarly, we return the newly defined PTHREAD_TIMEDOUT
    // ((void *) -2) if a timeout occurred.
    // Further note that a timeout of 0 is perfectly fine and succeeds if the
    // joined thread has terminated already.   
    void *join(double timeout = -1) {
        void *ret;
        if(timeout < 0) {
            return_error(pthread_join(_id, &ret));
        }
        else {
            timespec now;
            errno_error(clock_gettime(CLOCK_REALTIME, &now));
            const unsigned long nanosPerS = 1000000000;
            double integer;
            now.tv_nsec += modf(timeout, &integer) * nanosPerS;
            now.tv_sec += integer;
            if(now.tv_nsec >= nanosPerS) {
                now.tv_nsec -= nanosPerS;
                now.tv_sec++;
            }
            int error = pthread_timedjoin_np(_id, &ret, &now);
            if(error == ETIMEDOUT) ret = PTHREAD_TIMEDOUT;
            else return_error(error);
        }
        return ret;
    }
    // Returns 0 if the thread is not valid.
    pthread_t posixThreadId() {return _id;}
  protected:
    ThreadBase(const char *name, int prio, int stackSize):
      _name(name) {
        return_error(pthread_attr_init(&_attr));
        return_error(pthread_attr_setstacksize(&_attr, stackSize));
        return_error(pthread_attr_setinheritsched (&_attr, PTHREAD_EXPLICIT_SCHED));
        if(prio) {
            return_error(pthread_attr_setschedpolicy(&_attr, SCHEDULING_POLICY));
            return_error(pthread_attr_getschedparam(&_attr, &_param));
            _param.sched_priority = prio;
            return_error(pthread_attr_setschedparam(&_attr, &_param));
        }
    }
    // Only used while locked!
    static std::map<pthread_t, ThreadBase *> &instanceByThreadId() {
        static std::map<pthread_t, ThreadBase *> _instanceByThreadId;
        return _instanceByThreadId;
    }
    pthread_t _id;
    pthread_attr_t _attr;
  private:
    friend ThreadBase *self();
    ThreadBase(const ThreadBase &other);
    ThreadBase &operator=(const ThreadBase &other);
    std::string _name;
    struct sched_param _param;
};
// Typeless self(). Easier to use, but doesn't know the threadFunctor instance.
inline ThreadBase *self() {
    Lock lock(StaticMutex<ThreadBase>::mutex());
    std::map<pthread_t, ThreadBase *>::iterator it = ThreadBase::instanceByThreadId().find(pthread_self());
    assert(it != ThreadBase::instanceByThreadId().end());
    ThreadBase *ret = it->second;
    return ret;
}
// Test if type T is a function pointer.
template<typename T> struct IsFunctionPointer {static const bool value = false;};
template<typename T> struct IsFunctionPointer<T (*)()> {static const bool value = true;};
// Define type U as type T or as reference to type T
// depending on whether type T is a function pointer.
template<typename T, bool = IsFunctionPointer<T>::value> struct RefIfFunctor {typedef T & U;};
template<typename T> struct RefIfFunctor<T, true> {typedef T U;};
// A Thread may either take functions or references to functors.
template<typename ThreadFunctor = void *(*)()> class Thread: public ThreadBase {
  public:
    // Creates a new Thread instance that takes a pointer to its thread functor.
    Thread(typename RefIfFunctor<ThreadFunctor>::U threadFunctor, const char *name = "", int prio = 0, int stackSize = 20000):
      ThreadBase(name, prio, stackSize),
      _threadFunctor(threadFunctor) {
        Lock lock(StaticMutex<ThreadBase>::mutex());
        return_error(pthread_create(&_id, &_attr, _wrapper, &_threadFunctor));
        // As we have a valid thread id now, we store it in the map.
        instanceByThreadId().insert(std::make_pair(_id, this));
    }
    // Cleanup of Thread instance.
    ~Thread() {
        Lock lock(StaticMutex<ThreadBase>::mutex());
        instanceByThreadId().erase(_id);
        pthread_detach(_id);
    }
    // If access to members of the contained type is needed.
    typename RefIfFunctor<ThreadFunctor>::U threadFunctor() {return _threadFunctor;}
  private:
    typename RefIfFunctor<ThreadFunctor>::U _threadFunctor;
    static void *_wrapper(void *threadFunctor) {
        return (*reinterpret_cast<ThreadFunctor *>(threadFunctor))();
    }
};
namespace {static Mutex &threadBase = StaticMutex<ThreadBase>::mutex();}
#endif
