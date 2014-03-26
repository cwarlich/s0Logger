// Taken from the three-state boolean logic library:
//
// Copyright Douglas Gregor 2002-2004. Use, modification and
// distribution is subject to the Boost Software License, Version
// 1.0. (See accompanying file LICENSE_1_0.txt or copy at
// http://www.boost.org/LICENSE_1_0.txt)
// For more information, see http://www.boost.org
//
// Just removed commments, namespace wrapper
// and compiler-specific workarounds.
#ifndef TRIBOOL_H
#define TRIBOOL_H
class tribool;
namespace detail {struct indeterminate_t {};}
typedef bool (*indeterminate_keyword_t)(tribool, detail::indeterminate_t);
inline bool indeterminate(tribool x, detail::indeterminate_t dummy = detail::indeterminate_t());
class tribool {
  private:
    struct dummy {void nonnull() {};};
    typedef void (dummy::*safe_bool)();
  public:
    tribool() : value(false_value) {}
    tribool(bool value) : value(value? true_value : false_value) {}
    tribool(indeterminate_keyword_t) : value(indeterminate_value) {}
    operator safe_bool() const {
        return value == true_value? &dummy::nonnull : 0;
    }
    enum value_t { false_value, true_value, indeterminate_value } value;
};
inline bool indeterminate(tribool x, detail::indeterminate_t) {
    return x.value == tribool::indeterminate_value;
}
inline tribool operator!(tribool x) {
    return x.value == tribool::false_value? tribool(true)
          :x.value == tribool::true_value? tribool(false)
          :tribool(indeterminate);
}
inline tribool operator&&(tribool x, tribool y) {
    if (static_cast<bool>(!x) || static_cast<bool>(!y)) return false;
    else if (static_cast<bool>(x) && static_cast<bool>(y)) return true;
    else return indeterminate;
}
inline tribool operator&&(tribool x, bool y) {return y? x : tribool(false);}
inline tribool operator&&(bool x, tribool y) {return x? y : tribool(false);}
inline tribool operator&&(indeterminate_keyword_t, tribool x) {
    return !x? tribool(false) : tribool(indeterminate);
}
inline tribool operator&&(tribool x, indeterminate_keyword_t) {
    return !x? tribool(false) : tribool(indeterminate);
}
inline tribool operator||(tribool x, tribool y) {
    if (static_cast<bool>(!x) && static_cast<bool>(!y)) return false;
    else if (static_cast<bool>(x) || static_cast<bool>(y)) return true;
    else return indeterminate;
}
inline tribool operator||(tribool x, bool y) {return y? tribool(true) : x;}
inline tribool operator||(bool x, tribool y) {return x? tribool(true) : y;}
inline tribool operator||(indeterminate_keyword_t, tribool x) {
    return x? tribool(true) : tribool(indeterminate);
}
inline tribool operator||(tribool x, indeterminate_keyword_t) {
    return x? tribool(true) : tribool(indeterminate);
}
inline tribool operator==(tribool x, tribool y) {
    if (indeterminate(x) || indeterminate(y)) return indeterminate;
    else return (x && y) || (!x && !y);
}
inline tribool operator==(tribool x, bool y) { return x == tribool(y); }
inline tribool operator==(bool x, tribool y) { return tribool(x) == y; }
inline tribool operator==(indeterminate_keyword_t, tribool x) {
    return tribool(indeterminate) == x;
}
inline tribool operator==(tribool x, indeterminate_keyword_t) {
    return tribool(indeterminate) == x;
}
inline tribool operator!=(tribool x, tribool y) {
    if (indeterminate(x) || indeterminate(y)) return indeterminate;
    else return !((x && y) || (!x && !y));
}
inline tribool operator!=(tribool x, bool y) { return x != tribool(y); }
inline tribool operator!=(bool x, tribool y) { return tribool(x) != y; }
inline tribool operator!=(indeterminate_keyword_t, tribool x) {
    return tribool(indeterminate) != x;
}
inline tribool operator!=(tribool x, indeterminate_keyword_t) {
    return x != tribool(indeterminate);
}
#define TRIBOOL_THIRD_STATE(Name) \
inline bool Name(tribool x, detail::indeterminate_t dummy = detail::indeterminate_t()) { \
    return x.value == tribool::indeterminate_value; \
}
#endif
