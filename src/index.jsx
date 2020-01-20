/** @format */

import { ActionSheetProvider } from '@expo/react-native-action-sheet'
import React from 'react'
import { AppearanceProvider } from 'react-native-appearance'
import { SafeAreaProvider } from 'react-native-safe-area-context'

import { Stack } from './navigation/stack'

const App = () => (
	<AppearanceProvider>
		<SafeAreaProvider>
			<ActionSheetProvider>
				<Stack />
			</ActionSheetProvider>
		</SafeAreaProvider>
	</AppearanceProvider>
)

export { App }
