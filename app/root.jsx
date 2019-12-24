/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import { ActionSheetProvider } from '@expo/react-native-action-sheet'
import React, { useEffect } from 'react'
import { AppearanceProvider } from 'react-native-appearance'
import { SafeAreaProvider } from 'react-native-safe-area-context'
import SplashScreen from 'react-native-splash-screen'

import { Stack } from './navigation'

const Root = () => {
	useEffect(() => {
		SplashScreen.hide()
	}, [])

	return (
		<AppearanceProvider>
			<SafeAreaProvider>
				<ActionSheetProvider>
					<Stack />
				</ActionSheetProvider>
			</SafeAreaProvider>
		</AppearanceProvider>
	)
}

export { Root }
