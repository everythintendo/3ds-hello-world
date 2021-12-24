/*
  Used to get VSCode IntelliSense working correctly for header definitions
  protected by compiler-specific feature flags.
  Shamelessy stolen from https://github.com/cuibonobo/nds_vscode_template.
*/

#ifdef __GNUC__
#define _ATTRIBUTE(attrs) __attribute__(attrs)
#else
#define _ATTRIBUTE(attrs)
#endif

int iprintf(const char *, ...)
    _ATTRIBUTE((__format__(__printf__, 1, 2)));
