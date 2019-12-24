/** @format */

import _ from 'lodash'
import { useActionSheet } from '@expo/react-native-action-sheet'
import {
	DefaultTheme,
	DarkTheme,
	NavigationNativeContainer,
} from '@react-navigation/native'
import { createNativeStackNavigator } from '@react-navigation/native-stack'
import React, { useCallback } from 'react'
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

const Stack = () => {
	const colorScheme = useColorScheme()
	const theme = getThemeFromColorScheme(colorScheme)

	const renderScreen = useCallback(
		(screenComponent) => (
			<NativeStack.Screen
				component={screenComponent}
				name={screenComponent.name.toLowerCase()}
				options={screenComponent.options}
			/>
		),
		[],
	)

	return (
		<NavigationNativeContainer theme={theme}>
			<NativeStack.Navigator screenOptions={SCREEN_OPTIONS}>
				{_.map(screens, renderScreen)}
			</NativeStack.Navigator>
		</NavigationNativeContainer>
	)
}

export { Stack }
