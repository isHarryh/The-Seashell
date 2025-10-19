#include "my_application.h"
#include <cstdlib>
#include <cstring>

int main(int argc, char** argv) {
  // Set GDK_BACKEND to prefer Wayland, with X11 fallback
  const char* session_type = getenv("XDG_SESSION_TYPE");
  
  // If running on Wayland, set backend preference
  if (session_type && strcmp(session_type, "wayland") == 0) {
    setenv("GDK_BACKEND", "wayland", 1);
  }
  
  // Disable GTK scaling - let Flutter handle DPI internally
  setenv("GDK_SCALE", "1", 1);
  setenv("GDK_DPI_SCALE", "1", 1);
  
  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
