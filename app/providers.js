/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import { ActionSheetProvider } from '@expo/react-native-action-sheet'
import React from 'react'
import { AppearanceProvider } from 'react-native-appearance'
import { SafeAreaProvider } from 'react-native-safe-area-context'

import { Root } from './navigation'

const Providers = () => (
	<AppearanceProvider>
		<SafeAreaProvider>
			<ActionSheetProvider>
				<Root />
			</ActionSheetProvider>
		</SafeAreaProvider>
	</AppearanceProvider>
)

export { Providers }
