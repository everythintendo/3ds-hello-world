/*
  3DS Homebrew Hello World example made by @lambdagg for Everythintendo. Also
  includes a button tester, system language informations... And a lot more.

  Last time modified on the 19th of December 2021, 15:00 GMT+1.
  Heavily inspired from LIBCTRU's examples.
*/

#include <stdio.h>
#include <3ds.h>

/// Moves the cursor to the wanted column (x), row (y).
#define moveCursor(x, y) printf("\033[%d;%dH", y, x)

int main(int argc, char **argv)
{
  PrintConsole topScreen, botScreen;

  Result sysLangRes;
  u8 sysLang;

  // Init routine.
  {
    /*
      Here, we start all of the services we need in order for the application to
      work.
    */

    // Initialize the LCD frame buffers.
    gfxInitDefault();

    // Initialize the console into the topmost variables.
    consoleInit(GFX_TOP, &topScreen);
    consoleInit(GFX_BOTTOM, &botScreen);

    // Initialize our variables.
    sysLangRes = CFGU_GetSystemLanguage(&sysLang);
  }

  // Post-init routine.
  {
    /*
      Here, we do all of the work we have to after the services have been
      fully initialized.
    */

    // Switch to the top screen.
    consoleSelect(&topScreen);

    // Print "Hello World" in bold magenta, with a new line at the end, at
    // X0;Y0 on the top screen.
    moveCursor(0, 0);
    printf("Hello World\n");

    // Print "Press START to exit" in bold cyan, with a new line at the end.
    printf("Press START to exit\n");

    // Switch back to the bottom screen.
    consoleSelect(&botScreen);
  }

  // A bitmask for pressed buttons that are pressed, whether they were pressed
  // during the last frame or not, whereas hidKeysDown() o.e. will only return
  // a bitmask for pressed buttons that weren't during the previous frame.
  u32 oldHeldKeys = 0, currHeldKeys;

  // A value between 0 and 63 defining the value of the volume slider.
  u8 oldVolumeSlider = 0, currVolumeSlider;

  // A value between 0 and 100 defining the value of the 3D slider.
  float old3dSlider = 0, curr3dSlider;

  // The main loop ; if we get out of here, the application exits.
  while (aptMainLoop())
  {
    {
      /*
        Here, we do what we need to do once per frame before anything else.
      */

      // Scan input data.
      hidScanInput();

      // Set our variables.
      currHeldKeys = hidKeysHeld();
      HIDUSER_GetSoundVolume(&currVolumeSlider);
      curr3dSlider = osGet3DSliderState() * 100;

      // Move to 0;0.
      moveCursor(0, 0);
    }

    {
      /*
        Here, we put the content of our application that has to be executed
        every frame.
      */

      if (currHeldKeys & KEY_START)
      {
        // We break out of the loop if we press START, meaning the application
        // will exit.
        break;
      }

      if (oldHeldKeys != currHeldKeys ||
          old3dSlider != curr3dSlider ||
          oldVolumeSlider != currVolumeSlider)
      {
        consoleClear();
      }

      // Print the language code to X0;Y0 on the bottom screen.
      printf("Language code: %d (res: 0x%x)\n", (int)sysLang, (int)sysLangRes);

      printf("Keymask: %d\n", (int)currHeldKeys);
      printf("3D slider: %f/100\n", curr3dSlider);
      printf("Volume slider: %d/63\n", (int)currVolumeSlider);
    }

    {
      /*
        Here, we do everything we have to in order to render a frame.
      */

      oldHeldKeys = currHeldKeys;
      old3dSlider = curr3dSlider;
      oldVolumeSlider = currVolumeSlider;

      /*
        Swap and flush the frame buffers, and wait for the VBlank0 event. This
        should be done every time a frame has to be rendered.
      */
      gfxSwapBuffers();
      gfxFlushBuffers();
      gspWaitForEvent(GSPGPU_EVENT_VBlank0, true);
    }
  }

  // Exit routine.
  {
    /*
      Here, we have to exit all of the services we initialized during the
      init routine, preferably in the reverse order as they've been
      initialized.
    */

    // Free the LCD frame buffers.
    gfxExit();
  }

  // The exit code. Most likely to always be zero.
  return 0;
}
