/** @format */

import _ from 'lodash'
import {
	DarkTheme,
	DefaultTheme,
	NavigationNativeContainer,
	useTheme,
} from '@react-navigation/native'
import { createNativeStackNavigator } from '@react-navigation/native-stack'
import React from 'react'
import { useColorScheme } from 'react-native-appearance'
import { ThemeProvider } from 'styled-components/native'

import { Welcome } from './screens/welcome'

const SCREEN_OPTIONS = {
	headerLargeTitle: true,
	headerTranslucent: true,
}

const SCREENS = [Welcome]

const NativeStack = createNativeStackNavigator()

const getThemeFromColorScheme = (colorScheme) => {
	if (colorScheme === 'dark') return DarkTheme
	return DefaultTheme
}

const renderScreen = (screenComponent) => (
	<NativeStack.Screen
		component={screenComponent}
		key={screenComponent.name}
		name={screenComponent.name.toLowerCase()}
		options={screenComponent.options}
	/>
)

const StackContainer = () => {
	const theme = useTheme()

	const children = _.map(SCREENS, renderScreen)

	return (
		<ThemeProvider theme={theme}>
			<NativeStack.Navigator screenOptions={SCREEN_OPTIONS}>
				{children}
			</NativeStack.Navigator>
		</ThemeProvider>
	)
}

const Navigation = () => {
	const colorScheme = useColorScheme()
	const theme = getThemeFromColorScheme(colorScheme)

	return (
		<NavigationNativeContainer theme={theme}>
			<StackContainer />
		</NavigationNativeContainer>
	)
}

export { Navigation }
