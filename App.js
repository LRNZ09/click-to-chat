/** @format */

import * as FacebookAds from 'expo-ads-facebook'
import Constants from 'expo-constants'
import { enableScreens } from 'react-native-screens'
import * as Sentry from 'sentry-expo'

enableScreens()

Sentry.init({
	debug: __DEV__,
	dsn: 'https://f91b3d447f0b409ab0f0f241c293be69@sentry.io/1890424',
	enableInExpoDevelopment: false,
})
Sentry.setRelease(Constants.manifest.revisionId)

if (__DEV__) FacebookAds.AdSettings.addTestDevice(FacebookAds.AdSettings.currentDeviceHash)

export { App as default } from './src'
