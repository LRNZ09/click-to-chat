/** @format */

import { useActionSheet } from '@expo/react-native-action-sheet'
import { NavigationNativeContainer } from '@react-navigation/native'
import { createNativeStackNavigator } from '@react-navigation/native-stack'
import React from 'react'

import { Welcome } from '../screens'

const SCREEN_OPTIONS = {
	headerLargeTitle: true,
	headerTranslucent: true,
}

const Stack = createNativeStackNavigator()

const Root = () => (
	<NavigationNativeContainer>
		<Stack.Navigator screenOptions={SCREEN_OPTIONS}>
			<Stack.Screen
				component={Welcome}
				name={Welcome.name.toLowerCase()}
				options={Welcome.options}
			/>
		</Stack.Navigator>
	</NavigationNativeContainer>
)

export { Root }
