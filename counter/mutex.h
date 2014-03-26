#ifndef MUTEX_H
#define MUTEX_H
#include "trace.h"
#include <pthread.h>
class Mutex {
  public:
    Mutex(bool locked = false, int kind = PTHREAD_MUTEX_FAST_NP) {
        pthread_mutexattr_init(&attr);
        ASSERT(pthread_mutexattr_settype(&attr, kind) == 0, "");
        pthread_mutex_init(&mutex, &attr);
        if(locked) return_error(pthread_mutex_lock(&mutex));
    }
    bool lock() {
        int ret = pthread_mutex_lock(&mutex);
        ASSERT(ret == 0 || ret == EDEADLK, "");
        return ret == 0;
    }
    bool trylock() {
        int ret = pthread_mutex_trylock(&mutex);
        ASSERT(ret == 0 || ret == EBUSY, "");
        return ret == 0;
    }
    bool unlock() {
        int ret = pthread_mutex_unlock(&mutex);
        ASSERT(ret == 0 || ret == EPERM, "");
        return ret == 0;
    }
    ~Mutex() {
        ASSERT(pthread_mutex_destroy(&mutex) == 0, "");
        ASSERT(pthread_mutexattr_destroy(&attr) == 0, "");
    }
  private:
    pthread_mutex_t mutex;
    pthread_mutexattr_t attr;
};
class Lock {
  public:
    Lock(Mutex &mutex): mutex(mutex) {mutex.lock();}  
    ~Lock() {mutex.unlock();}
  private:
    Mutex &mutex;
};
// This template doesn't use its template parameter:
// It is only used so that its mutex() member function
// returns a different mutex for each different type.
// Note that it is essential to instantiate mutexes
// before any concurrency exists.
template<typename T> class StaticMutex {
  public:
    static Mutex &mutex() {
        static Mutex ret;
        return ret;
    }
};
#endif
