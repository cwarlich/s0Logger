#ifndef TRACE_H
#define TRACE_H
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <error.h>
#include <assert.h>
#include <stdarg.h>
#include <limits.h>
#include <time.h>
#include <string>
#define ASSERT(x, y) do {if(!(x)) {error_at_line(1, errno, __FILE__, __LINE__, y); exit(-1);}} while(false)
#define errno_error(value)\
    do {\
        if(value < 0) {\
            fprintf(stderr, "%s in file %s at line %d\n", strerror(errno), __FILE__, __LINE__);\
            exit(1);\
        }\
    } while(false)
#define return_error(value)\
    do {\
        if(value) {\
            fprintf(stderr, "%s in file %s at line %d\n", strerror(value), __FILE__, __LINE__);\
            exit(1);\
        }\
    } while(false)
#define FAILURE_DONT_EXIT INT_MAX
#define FAILURE_EXIT_CONDITION INT_MIN
// This fucction is the opposite to assert(). Furthermore, it allows
// to pass a formatted string and allows to define the exit behaviour.
inline std::string now() {
    time_t t = time(0); 
    std::string ret = ctime(&t);
    return ret.erase(ret.length() - 1);
}
inline int failure(int condition, int exitcode, const char *format, ...) {
    if(condition) {
        va_list args;
        va_start (args, format);
        vfprintf(stderr, format, args);
        fprintf(stderr, " at %s.\n", now().c_str());
        va_end (args);
        if(exitcode != FAILURE_DONT_EXIT) {
            if(exitcode == FAILURE_EXIT_CONDITION) exit(condition);
            else exit(exitcode);
        }
    }
    return condition;
}
#endif
