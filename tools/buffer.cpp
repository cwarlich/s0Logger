#include <string>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include "trace.h"
int main(void) {
    std::string queue;
    fd_set rfds, wfds;
    int ret, rsize = 1, wsize, qsize;
    const int maxSize = 1000;
    char buffer[maxSize];
    FD_ZERO(&rfds);
    FD_SET(0, &rfds);
    FD_ZERO(&wfds);
    FD_SET(1, &wfds);
    while(true) {
        if(queue.size()) {
            if(rsize) {
                ret = select(2, &rfds, &wfds, 0, 0);
                failure(ret < 0, -4, "select() read or write: %s", strerror(errno)); 
            }
            else {
                ret = select(2, 0, &wfds, 0, 0);
                failure(ret < 0, -4, "select() write: %s", strerror(errno)); 
            }
        }
        else {
            if(rsize) ret = select(1, &rfds, 0, 0, 0);
            else {
                failure(ret < 0, -4, "select() write: %s", strerror(errno)); 
            }
        }
        if(rsize && FD_ISSET(0, &rfds)) {
            rsize = read(0, buffer, maxSize);
            if(rsize) queue.append(buffer, rsize);
            else {
                while((qsize = queue.size())) {
                    wsize = write(3, queue.c_str(), qsize);
                    if(wsize) queue.erase(0, wsize);
                    else failure(1, -7, "save read(): %s", strerror(errno));
                }
                failure(1, -5, "read(): %s", strerror(errno)); 
            }
        }
        if(queue.size() && FD_ISSET(1, &wfds)) {
            wsize = write(1, buffer, queue.size());
            if(wsize) queue.erase(0, wsize);
            else {
                while((qsize = queue.size())) {
                    wsize = write(3, queue.c_str(), qsize);
                    if(wsize) queue.erase(0, wsize);
                    else failure(1, -7, "save write(): %s", strerror(errno));
                }
                failure(1, -5, "write(): %s", strerror(errno)); 
            }
        }
    }
    failure(1, -6, "reader ended unexpected"); 
    return 0;
}
