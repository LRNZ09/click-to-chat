/** @format */

import { AppRegistry, Platform } from 'react-native'
import QuickActions from 'react-native-quick-actions'
import { enableScreens } from 'react-native-screens'

import { Providers } from './providers'

QuickActions.isSupported((error, isNativeSupported) => {
	if (error) {
		console.error(error)
		return
	}

	if (!isNativeSupported) {
		const isPlatformSupported = Platform.select({
			android: Platform.Version >= 25, // Support from Nougat
			ios: parseInt(Platform.Version, 10) >= 13, // Support from iOS 13 without 3D Touch
		})

		if (!isPlatformSupported) {
			console.log(
				'Device does not support 3D Touch or 3D Touch is disabled.',
			)
			return
		}
	}

	QuickActions.setShortcutItems([
		{
			type: 'donate', // Required
			title: 'Donate', // Optional, if empty, `type` will be used instead
			subtitle: 'Thanks for you support',
			icon: 'Love', // Icons instructions below
			userInfo: {
				url: '/donate', // Provide any custom data like deep linking URL
			},
		},
	])
})

enableScreens()

AppRegistry.registerComponent('WhatsAdd', () => Providers)
