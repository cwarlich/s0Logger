#ifndef GPIO_H
#define GPIO_H
#include "tribool.h"
#include "mutex.h"
#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <poll.h>
#include <signal.h>
#include <sstream>
#include <vector>
#include <map>
static const unsigned int lastPin = 53;
class GpioCheck {
  public:
    GpioCheck(unsigned int pin): bit(pin < 32 ? 1 << pin : 1 << (pin - 32)) {
        ASSERT(pin <= lastPin, "");
        std::ostringstream stream;
        stream << pin;
        spin = stream.str();
    }
    GpioCheck():
      bit(0),
      spin() {
  }
  protected:
    unsigned int bit;
    std::string spin;
};
// Creating /sys/class/gpio/gpio* files exactly once per pin.
class GpioBase: protected GpioCheck {
  public:
    GpioBase(unsigned int pin):
      GpioCheck(pin),
      pin(pin) {
        // To simplify things, we use a common mutex for all pins.
        Lock lock(StaticMutex<GpioBase>::mutex());
        if(!instancesPerPin()[pin]) {
            if(access(("/sys/class/gpio/gpio" + spin).c_str(), R_OK | W_OK)) {
                fprintf(stderr, "echo %s >/sys/class/gpio/export\n", spin.c_str());
                int fd = open("/sys/class/gpio/export", O_WRONLY);
                ASSERT(fd > 0, "/sys/class/gpio/export"); 
                ASSERT(write(fd, spin.c_str(), spin.length()) > 0, spin.c_str());
                close(fd);
            }
            else fprintf(stderr, "/sys/class/gpio/gpio%s already existing\n", spin.c_str());
        }
        instancesPerPin()[pin]++;
    }
    GpioBase():
      GpioCheck(),
      pin(0) {
    }
    GpioBase(const GpioBase &other) {
        Lock lock(StaticMutex<GpioBase>::mutex());
        bit = other.bit;
        spin = other.spin;
        pin = other.pin;
        if(bit) instancesPerPin()[pin]++;
    }
    GpioBase &operator=(const GpioBase &other) {
        Lock lock(StaticMutex<GpioBase>::mutex());
        if(bit != other.bit) {
            if(bit || !other.bit) cleanup();
            if(!bit || other.bit) instancesPerPin()[other.pin]++;
        }
        pin = other.pin;
        bit = other.bit;
        spin = other.spin;
    }
    ~GpioBase() {
        Lock lock(StaticMutex<GpioBase>::mutex());
        cleanup();
    }
  private:
    unsigned int pin;
    // Only be used within locked sections.
    static unsigned int *instancesPerPin() {
        static unsigned int ret[lastPin + 1];
        return ret;
    }
    // Only be used within locked sections.
    void cleanup() {
        instancesPerPin()[pin]--;
        if(!instancesPerPin()[pin]) {
            fprintf(stderr, "echo %s >/sys/class/gpio/unexport\n", spin.c_str());
            int fd = open("/sys/class/gpio/unexport", O_WRONLY);
            ASSERT(fd > 0, "/sys/class/gpio/unexport"); 
            ASSERT(write(fd, spin.c_str(), spin.length()) > 0, spin.c_str());
            close(fd);
        }
    }
};
// Forward declaration is needed here as the function's implementation
// uses class Registers defined below, which in turn needs to be a friend
// of that function.
static volatile unsigned int *registers();
// Get / set pin function.
enum Values {in, out, function5, function4, function0, function1, function2, function3, nofunction};
class GpioFunction: public GpioCheck {
  public:
    GpioFunction(unsigned int pin):
      GpioCheck(pin),
      // Precalculate as much as possible.
      reg(registers() + pin / 10),
      pos((pin % 10) * 3),
      clr(~(0x7 << pos)) {
    }
    GpioFunction() {}
    Values function(Values v = nofunction) {
        ASSERT(v <= nofunction, "");
        Lock lock(StaticMutex<GpioFunction>::mutex());
        if(bit) {
            unsigned int ret = *reg;
            if(v != nofunction) *reg = (ret & clr) | (v << pos);
            return (Values) ((ret >> pos) & 0x7);
        }
        else return nofunction;
    }
  private:
    volatile unsigned int *reg;
    unsigned int pos;
    unsigned int clr;
};
// Get / set pin level.
class GpioLevel: public GpioCheck {
  public:
    GpioLevel(unsigned int pin):
      GpioCheck(pin),
      set(registers() + (pin < 32 ? 7 : 8)),
      clear(set + 3),
      read(clear + 3) {
    }
    GpioLevel() {}
    tribool level(tribool high = indeterminate) {
        Lock lock(StaticMutex<GpioLevel>::mutex());
        if(bit) {
            tribool ret = *read & bit;
            if(!indeterminate(high)) high ? *set = bit : *clear = bit;
            return ret;
        }
        return indeterminate;
    }
  private:
    volatile unsigned int *set;
    volatile unsigned int *clear;
    volatile unsigned int *read;
};
// Get / set pin event detection type.
static const unsigned int none = 0;
static const unsigned int syncRising = 1 << 0;
static const unsigned int syncFalling = 1 << 1;
static const unsigned int high = 1 << 2;
static const unsigned int low = 1 << 3;
static const unsigned int asyncRising = 1 << 4;
static const unsigned int asyncFalling = 1 << 5;
static const unsigned int noevent = 1 << 6;
static const unsigned int syncBoth = syncRising | syncFalling;
static const unsigned int asyncBoth = asyncRising | asyncFalling;
class GpioEvent: public GpioCheck {
  public:
    GpioEvent(unsigned int pin): GpioCheck(pin) {
        regs[0] = registers() + (pin < 32 ? 19 : 20);
        for(int i = 1; i < 6; i++) regs[i] = regs[i - 1] + 3;
    }
    GpioEvent() {}
    unsigned int event(unsigned int v = noevent) {
        ASSERT(v < asyncFalling << 1 || v == noevent, "");
        Lock lock(StaticMutex<GpioEvent>::mutex());
        if(bit) {
            unsigned int ret = 0;
            for(int i = 0; i < 6; i++) {
                ret |= *regs[i] & bit ? 1 << i : 0;
                if(v != noevent) {
                    if(v & (1 << i)) *regs[i] |= bit;
                    else *regs[i] &= ~bit;
                }
            }
            return ret;
        }
        else return noevent;
    }
  private:
    volatile unsigned int *regs[6];
};
// Test and reset pin event.
class GpioDetect: public GpioCheck {
  public:
    GpioDetect(unsigned int pin):
      GpioCheck(pin),
      reg(registers() + (pin < 32 ? 16 : 17)) {
    }
    GpioDetect() {}
    tribool detect() {
        Lock lock(StaticMutex<GpioDetect>::mutex());
        if(bit) {
            if(*reg & bit) {
                *reg = bit;
                return true;
            }
            else return false;
        }
        else return indeterminate;
    }
  private:
    volatile unsigned int *reg;
};
// Get / set pull up / down resistors. Note that the returned
// value is only valid when it has been written using this
// interface before, because the real value cannot be read back.
enum Resistance {tristate, down, up, nopull};
class GpioPull: public GpioCheck {
  public:
    GpioPull(unsigned int pin):
      GpioCheck(pin),
      enable(registers() + 37),
      clk(registers() + (pin < 32 ? 38 : 39)),
      value(tristate) {
    }
    GpioPull() {}
    Resistance pull(Resistance v = nopull) {
        ASSERT(v <= up && v >= tristate, "");
        Lock lock(StaticMutex<GpioPull>::mutex());
        if(bit) {
            Resistance ret = value;
            value = v;
            if(v != nopull) {
                *enable = v;
                usleep(10);
                // RPI GPIO header bits: 0x03e6cf83
                *clk = bit;
                usleep(10);
                *enable = 0;
                *clk = 0;
            }
            return ret;
        }
        else return nopull;
    }
  private:
    volatile unsigned int *enable;
    volatile unsigned int *clk;
    Resistance value;
   
};
// Only use this class if you know what you are doing.
// Most notably, consider that direct register changes will
// not be visible through the /sys/class/gpio interface and
// that it doesn't work using GPIO interrupts as provided by
// http://www.raspberrypi.org/phpBB3/viewtopic.php?f=44&t=7509
class GpioRegisters: public GpioFunction, public GpioLevel, public GpioEvent, public GpioDetect, public GpioPull {
  public:
    GpioRegisters(unsigned int pin):
      GpioFunction(pin),
      GpioLevel(pin),
      GpioEvent(pin),
      GpioDetect(pin),
      GpioPull(pin) {
    }
  GpioRegisters() {}
};
// Get / set pin direction.
class GpioDirection: public GpioBase {
  public:
    GpioDirection(unsigned int pin): GpioBase(pin) {
        s = "/sys/class/gpio/gpio" + spin + "/direction";
    }
    GpioDirection() {}
    tribool input(tribool in = indeterminate) {
        Lock lock(StaticMutex<GpioDirection>::mutex());
        if(bit) {
            char buffer[4];
            int fd = open(s.c_str(), O_RDWR);
            ASSERT(fd > 0, "");
            ASSERT(read(fd, buffer, 4) > 0, "");
            tribool ret = (bool) memcmp("out", buffer, 3);
            if(!indeterminate(in)) {
                if(in) ASSERT(write(fd, "in", 2) > 0, "");
                else ASSERT(write(fd, "out", 3) > 0, "");
            }
            ASSERT(close(fd) == 0, "");
            return ret;
        }
        else return indeterminate;
    }
  private:
    std::string s;
};
// Get / set pin value.
class GpioValue: public GpioBase {
  public:
    GpioValue(unsigned int pin): GpioBase(pin) {
        s = "/sys/class/gpio/gpio" + spin + "/value";
    }
    GpioValue() {}
    tribool high(tribool v = indeterminate) {
        Lock lock(StaticMutex<GpioValue>::mutex());
        if(bit) {
            char buffer[4];
            tribool ret;
            int fd;
            if(indeterminate(v)) {
                fd = open(s.c_str(), O_RDONLY);
                ASSERT(fd > 0, "");
                ASSERT(read(fd, buffer, 4) > 0, "");
                ret = (bool) memcmp("0", buffer, 1);
            }
            else {
                fd = open(s.c_str(), O_RDWR);
                ASSERT(fd > 0, "");
                ASSERT(read(fd, buffer, 4) > 0, "");
                ret = (bool) memcmp("0", buffer, 1);
                if(v) ASSERT(write(fd, "1", 1) > 0, "");
                else ASSERT(write(fd, "0", 1) > 0, "");
            }
            ASSERT(close(fd) == 0, "");
            return ret;
        }
        else return indeterminate;
    }
  private:
    std::string s;
};
// Get / set interrupt detection.
enum Edge {neither, rising, falling, both, nointerrupt};
class GpioEdge: public GpioBase {
  public:
    GpioEdge(unsigned int pin): GpioBase(pin) {
        s = "/sys/class/gpio/gpio" + spin + "/edge";
    }
    GpioEdge() {}
    Edge edge(Edge v = nointerrupt) {
        Lock lock(StaticMutex<GpioEdge>::mutex());
        if(bit) {
            char buffer[8];
            Edge ret;
            int fd = open(s.c_str(), O_RDWR);
            ASSERT(fd > 0, "");
            ASSERT(read(fd, buffer, 8) > 0, "");
            if(!memcmp("none", buffer, 6)) ret = neither;
            if(!memcmp("rising", buffer, 6)) ret = rising;
            if(!memcmp("falling", buffer, 6)) ret = falling;
            if(!memcmp("both", buffer, 6)) ret = both;
            if(v != nointerrupt) {
                switch(v) {
                  case neither:
                    ASSERT(write(fd, "none", 4) > 0, "");
                    break;
                  case rising:
                    ASSERT(write(fd, "rising", 6) > 0, "");
                    break;
                  case falling:
                    ASSERT(write(fd, "falling", 7) > 0, "");
                    break;
                  case both:
                    ASSERT(write(fd, "both", 4) > 0, "");
                    break;
                }
            }
            ASSERT(close(fd) == 0, "");
            return ret;
        }
        else return nointerrupt;
    }
  private:
    std::string s;
};
class GpioSysfs: public GpioDirection, public GpioValue, public GpioEdge {
  public:
    GpioSysfs(unsigned int pin):
      GpioDirection(pin),
      GpioValue(pin),
      GpioEdge(pin) {
    }
  GpioSysfs() {}
};
class GpioOutput: public GpioValue {
  public:
    GpioOutput(unsigned int pin):
      GpioValue(pin),
      direction(pin) {
        direction.input(false);
    }
    GpioOutput() {}
  private:
    GpioDirection direction;
};
class GpioInput: public GpioPull {
  public:
    GpioInput(unsigned int pin, Edge e = neither):
      GpioPull(pin),
      direction(pin),
      value(pin),
      edge(pin) {
        direction.input(true);
        edge.edge(e);
        std::string s = "/sys/class/gpio/gpio" + spin + "/value";
        pollfd pfd;
        pfd.fd = open(s.c_str(), O_RDWR);
        ASSERT(pfd.fd > 0, "");
        pfd.events = POLLPRI;
        char readbuffer[10];
        ASSERT(read(pfd.fd, readbuffer, 10 - 1) > 0, "");
        ASSERT(lseek(pfd.fd, 0, SEEK_SET) >= 0, "");
        pollfds().first.push_back(pfd);
        pollfds().second[pfd.fd] = pin;
    }
    tribool high() {return value.high();}
    GpioInput() {}
    template<typename Functor> static int wait(Functor f) {
        int ret = ppoll(&pollfds().first[0], pollfds().first.size(), NULL, signalmask());
        ASSERT(ret >= 0 || errno == EINTR, "");
        for(unsigned int i = 0; i < pollfds().first.size(); i++) {
            if(pollfds().first[i].revents & POLLPRI) {
                char buffer[10];
                ASSERT(read(pollfds().first[i].fd, buffer, 10) > 0, "");
                ASSERT(lseek(pollfds().first[i].fd, 0, SEEK_SET) >= 0, "");
                f(pollfds().second[pollfds().first[i].fd]);
            }
        }
        return ret;
    }
  private:
    GpioDirection direction;
    GpioValue value;
    GpioEdge edge;
    static sigset_t *signalmask() {
        static sigset_t ret;
        sigfillset(&ret);
        sigdelset(&ret, SIGINT);
        sigdelset(&ret, SIGPIPE);
        sigdelset(&ret, SIGTERM);
        return &ret;
    }
    static std::pair<std::vector<pollfd>, std::map<int, unsigned int> > &pollfds() {
        static Lock lock(StaticMutex<GpioInput>::mutex());
        static std::pair<std::vector<pollfd>, std::map<int, unsigned int> > ret;
        return ret;
    }
};
// The only purpose of the encapsulating class is to
// restrict access to its registers() member function
// to its friend, the registers() wrapper.
class Registers {
    friend volatile unsigned int *registers();
    static volatile unsigned int *registers() {
        // Map GPIO registers.
        const int periBase = 0x20000000;
        const int gpioBase = periBase + 0x200000;
        const int gpioSize = 4 * 1024;
        const char *device = "/dev/mem";
        int fd = open(device, O_RDWR | O_SYNC);
        ASSERT(fd > 0, device);
        volatile unsigned int *ret = (volatile unsigned int *) mmap(0, gpioSize, PROT_READ | PROT_WRITE, MAP_SHARED, fd, gpioBase);
        ASSERT(ret > 0, "");
        ASSERT(close(fd) == 0, "");
        // Initialize mutexes as long as no concurrency exists.
        StaticMutex<GpioBase>::mutex();
        StaticMutex<GpioFunction>::mutex();
        StaticMutex<GpioLevel>::mutex();
        StaticMutex<GpioEvent>::mutex();
        StaticMutex<GpioDetect>::mutex();
        StaticMutex<GpioPull>::mutex();
        StaticMutex<GpioDirection>::mutex();
        StaticMutex<GpioValue>::mutex();
        StaticMutex<GpioEdge>::mutex();
        StaticMutex<GpioInput>::mutex();
        return ret;
    }
};
// We don't need a mutex here, because the static
// variable is instantiated before any concurency
// exists.
inline volatile unsigned int *registers() {
    static volatile unsigned int *ret = Registers::registers();
    return ret;
}
// Although dummy is allocated and assigned once per module,
// Register::register() (and thus, mmap()) will only be
// executed once globally due to the static assignment in
// the registers() wrapper.
// Furthermore, the unnamed namespace hides dummy from
// from anywhere else, making it inaccessible for anyone
// outside that namespace.
namespace {static volatile unsigned int *dummy = registers();}
#endif
