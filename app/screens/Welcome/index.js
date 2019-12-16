/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * Generated with the TypeScript template
 * https://github.com/react-native-community/react-native-template-typescript
 *
 * @format
 */

import React, { useCallback, useEffect } from 'react'
import {
	ScrollView,
	StyleSheet,
	TextInput,
	Button,
	DeviceEventEmitter,
} from 'react-native'
import { useColorScheme } from 'react-native-appearance'
import { useClipboard } from 'react-native-hooks'
import QuickActions from 'react-native-quick-actions'
import RNRestart from 'react-native-restart'

import { More } from './more'

DeviceEventEmitter.addListener('quickActionShortcut', (data) => {
	console.warn({ data })
})

const renderHeaderRight = () => <More />

const Welcome = () => {
	const colorScheme = useColorScheme()

	const onChangeText = useCallback((value) => {
		console.warn({ value })
	}, [])

	const onRestartPress = useCallback(() => {
		// whatsapp://send?phone=+393519061996
		// Alert.alert('About', 'TODO');
		RNRestart.Restart()
	}, [])

	useEffect(() => {
		QuickActions.popInitialAction()
			.then(console.warn)
			.catch(console.error)
	}, [])

	const [data] = useClipboard()

	return (
		<ScrollView
			contentInsetAdjustmentBehavior="automatic"
			style={{ padding: 16 }}
		>
			<TextInput
				blurOnSubmit
				enablesReturnKeyAutomatically
				autoCompleteType="tel"
				// DefaultValue={data}
				clearButtonMode="while-editing"
				keyboardType="phone-pad"
				placeholder="+39 351 123 456"
				returnKeyType="done"
				style={{
					backgroundColor: 'white',
					marginHorizontal: -16,
					padding: 16,
				}}
				textContentType="telephoneNumber"
				underlineColorAndroid="transparent"
				onChangeText={onChangeText}
			/>

			<Button title="Restart" onPress={onRestartPress} />
		</ScrollView>
	)
}

Welcome.options = {
	title: 'WhatsAdd',
	headerRight: renderHeaderRight,
}

// const styles = StyleSheet.create({})

export { Welcome }
