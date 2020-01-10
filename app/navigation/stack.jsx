import _ from 'lodash'
import {
	DarkTheme,
	DefaultTheme,
	NavigationNativeContainer,
} from '@react-navigation/native'
import { createNativeStackNavigator } from '@react-navigation/native-stack'
import React from 'react'
import { useColorScheme } from 'react-native-appearance'

import * as screens from '../screens'

const SCREEN_OPTIONS = {
	headerLargeTitle: true,
	headerTranslucent: true,
}

const NativeStack = createNativeStackNavigator()

const getThemeFromColorScheme = (colorScheme) => {
	if (colorScheme === 'dark') return DarkTheme

	return DefaultTheme
}

const renderScreen = (screenComponent) => (
	<NativeStack.Screen
		component={screenComponent}
		name={screenComponent.name.toLowerCase()}
		options={screenComponent.options}
	/>
)

const Stack = () => {
	const colorScheme = useColorScheme()

	const theme = getThemeFromColorScheme(colorScheme)

	const children = _.map(screens, renderScreen)

	return (
		<NavigationNativeContainer theme={theme}>
			<NativeStack.Navigator screenOptions={SCREEN_OPTIONS}>
				{children}
			</NativeStack.Navigator>
		</NavigationNativeContainer>
	)
}

export { Stack }
