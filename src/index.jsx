/** @format */

import { ActionSheetProvider } from '@expo/react-native-action-sheet'
import React from 'react'
import { AppearanceProvider } from 'react-native-appearance'
import { SafeAreaProvider } from 'react-native-safe-area-context'

import { Navigation } from './navigation'

const App = () => (
	<AppearanceProvider>
		<SafeAreaProvider>
			<ActionSheetProvider>
				<Navigation />
			</ActionSheetProvider>
		</SafeAreaProvider>
	</AppearanceProvider>
)

export { App }
