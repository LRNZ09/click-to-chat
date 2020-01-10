import { AppRegistry, Platform } from 'react-native'
import QuickActions from 'react-native-quick-actions'
import { enableScreens } from 'react-native-screens'

import { Root } from './root'

const ANDROID_NOUGAT_PLATFORM_VERSION = 25
const IOS_YUKON_PLATFORM_VERSION = 13

const IS_PLATFORM_SUPPORTED = Platform.select({
	// Support from Android Nougat
	android: Platform.Version >= ANDROID_NOUGAT_PLATFORM_VERSION,
	// Support from iOS 13 without 3D Touch
	ios: Number.parseInt(Platform.Version) >= IOS_YUKON_PLATFORM_VERSION,
})

QuickActions.isSupported((error, isNativeSupported) => {
	if (error) {
		console.warn(error)

		return
	}

	if (!isNativeSupported && !IS_PLATFORM_SUPPORTED) {
		console.log('Device does not support 3D Touch or 3D Touch is disabled.')

		return
	}

	QuickActions.setShortcutItems([
		{
			icon: 'Love',
			subtitle: 'Thanks for you support',
			title: 'Donate',
			type: 'donate',
			userInfo: {
				url: '/donate',
			},
		},
	])
})

enableScreens()

AppRegistry.registerComponent('WhatsAdd', () => Root)
