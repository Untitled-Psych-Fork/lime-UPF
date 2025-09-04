#ifndef LIME_UI_GAMEPAD_H
#define LIME_UI_GAMEPAD_H

#include <SDL_joystick.h>
#include "utils/stdint.h"


namespace lime {


	class Gamepad {

		public:

			static void AddMapping (const char* content);
			static const char* GetDeviceGUID (int id);
			static const char* GetDeviceName (int id);

			static SDL_Joystick* GetJoystick (int id);

			static bool HasRumble(int id);
			static void Rumble(int id, uint16_t low_frequency_rumble, uint16_t high_frequency_rumble, uint32_t duration_ms);
			// static void Rumble (int id, double lowFrequencyRumble, double highFrequencyRumble, int duration);

			static bool HasRumbleTriggers(int id);
			static void RumbleTriggers(int id, uint16_t left_rumble, uint16_t right_rumble, uint32_t duration_ms);

			static bool HasLED(int id);
			static void SetLED(int id, uint8_t red, uint8_t green, uint8_t blue);

	};


}

	};


}


#endif
