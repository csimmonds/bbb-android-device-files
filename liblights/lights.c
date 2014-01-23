/*
 *  Copyright (C) 2008 The Android Open Source Project
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */


#define LOG_TAG "lights"

#include <cutils/log.h>

#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <pthread.h>

#include <sys/ioctl.h>
#include <sys/types.h>

#include <hardware/lights.h>

/******************************************************************************/

static pthread_once_t g_init = PTHREAD_ONCE_INIT;
static pthread_mutex_t g_lock = PTHREAD_MUTEX_INITIALIZER;

char const *const LCD7_FILE
	= "/sys/class/backlight/pwm-backlight/brightness";
char const *const LCD3_FILE
	= "/sys/class/backlight/tps65217-bl/brightness";

void init_globals(void)
{
    /* init the mutex */
	pthread_mutex_init(&g_lock, NULL);
}

static int
write_int(char const *path, int value)
{
	int fd;
	static int already_warned;

	fd = open(path, O_RDWR);
	if (fd >= 0) {
		char buffer[20];
		int bytes = sprintf(buffer, "%d\n", value);
		int amt = write(fd, buffer, bytes);
		close(fd);
		return amt == -1 ? -errno : 0;
	} else {
	if (already_warned == 0) {
		ALOGE("write_int failed to open %s\n", path);
		already_warned = 1;
	}
	return -errno;
	}
}

static int
rgb_to_brightness(struct light_state_t const *state)
{
	int color = state->color & 0x00ffffff;
	return ((77*((color>>16)&0x00ff))
		+ (150*((color>>8)&0x00ff)) + (29*(color&0x00ff))) >> 8;
}

static int
set_light_backlight(struct light_device_t *dev,
	struct light_state_t const *state)
{
	int err = 0;
	int brightness = rgb_to_brightness(state);

	/* change 0-255 scale to 0-100 */
	brightness = ((brightness/255.0)*100);

	pthread_mutex_lock(&g_lock);
	/* Try to write to LCD7 Backlight node */
	err = write_int(LCD7_FILE, brightness);
	if (err != 0) {
		/* LCD7 Backlight node not available, Try to write to LCD3 Backlight node */
		err = write_int(LCD3_FILE, brightness);
		if (err != 0)
			/* LCD3 and LCD7 Backlight node not available */
			ALOGI("write_int failed to open \n\t %s and %s\n",
						LCD7_FILE, LCD3_FILE);
	}

	pthread_mutex_unlock(&g_lock);
	return err;
}

static int
close_lights(struct light_device_t *dev)
{
	if (dev)
		free(dev);
	return 0;
}


/******************************************************************************/
static int open_lights(const struct hw_module_t *module, char const *name,
	struct hw_device_t **device)
{
	int (*set_light)(struct light_device_t *dev,
		struct light_state_t const *state);

	if (0 == strcmp(LIGHT_ID_BACKLIGHT, name))
		set_light = set_light_backlight;
	else
		return -EINVAL;

	pthread_once(&g_init, init_globals);

	struct light_device_t *dev = malloc(sizeof(struct light_device_t));
	memset(dev, 0, sizeof(*dev));

	dev->common.tag = HARDWARE_DEVICE_TAG;
	dev->common.version = 0;
	dev->common.module = (struct hw_module_t *)module;
	dev->common.close = (int (*)(struct hw_device_t *))close_lights;
	dev->set_light = set_light;

	*device = (struct hw_device_t *)dev;
	return 0;
}


static struct hw_module_methods_t lights_module_methods = {
	.open =  open_lights,
};

struct hw_module_t HAL_MODULE_INFO_SYM = {
	.tag = HARDWARE_MODULE_TAG,
	.version_major = 1,
	.version_minor = 0,
	.id = LIGHTS_HARDWARE_MODULE_ID,
	.name = "TI OMAP lights Module",
	.author = "Google, Inc.",
	.methods = &lights_module_methods,
};
