/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * Generated with the TypeScript template
 * https://github.com/react-native-community/react-native-template-typescript
 *
 * @format
 */

import { Picker } from '@react-native-community/picker'
import { useTheme } from '@react-navigation/native'
import axios from 'axios'
import _ from 'lodash'
import React, { useCallback, useEffect, useRef, useState } from 'react'
import {
	Button,
	DeviceEventEmitter,
	Platform,
	ScrollView,
	StyleSheet,
	Text,
	TextInput,
	View,
	Animated,
	ActivityIndicator,
	Linking,
} from 'react-native'
import { RectButton, BorderlessButton } from 'react-native-gesture-handler'
import { useClipboard } from 'react-native-hooks'
import * as RNLocalize from 'react-native-localize'
import QuickActions from 'react-native-quick-actions'
import RNRestart from 'react-native-restart'
import { conformToMask } from 'text-mask-core'
import Modal from 'react-native-modal'
import { human } from 'react-native-typography'

import { More } from './more'
import { PlatformIcon } from '../../components'

const BASE_TEXT_INPUT_MASK = _.initial(
	_.flatten(_.times(5, _.constant([/\d/, /\d/, /\d/, ' ']))),
)

const UNICODE_BASE = 127462 - 'A'.charCodeAt()

DeviceEventEmitter.addListener('quickActionShortcut', (data) => {
	// console.warn({ data })
})

const renderHeaderRight = () => <More />

const getFlagFromAlpha2Code = (alpha2Code) => {
	const codePoints = _.map(
		alpha2Code,
		(char) => UNICODE_BASE + char.charCodeAt(),
	)

	return String.fromCodePoint(...codePoints)
}

const getLabelFromCountry = (country) => {
	const flag = getFlagFromAlpha2Code(country.alpha2Code)

	return `${country.nativeName} ${flag}`
}

const CountryPickerItem = (country) => {
	const label = getLabelFromCountry(country)

	return (
		<Picker.Item
			key={country.alpha2Code}
			label={label}
			value={country.alpha2Code}
		/>
	)
}

const fetchCountriesData = async () => {
	try {
		const response = await axios.get('https://restcountries.eu/rest/v2/all')
		return response.data
	} catch (error) {
		console.warn(error)
	}
}

const Form = () => {
	const theme = useTheme()

	const [countries, setCountries] = useState([])
	const [isPickerVisible, setPickerVisible] = useState(false)
	const [phoneNumber, setPhoneNumber] = useState('')
	const [selectedCountry, setSelectedCountry] = useState(null)

	const onCountryValueChange = useCallback(
		(alpha2Code) => {
			const country = _.find(countries, { alpha2Code })
			setPhoneNumber(`+${country.callingCodes[0]}`)
			setSelectedCountry(country)
		},
		[countries],
	)

	useEffect(() => {
		fetchCountriesData().then(setCountries)
	}, [])

	useEffect(() => {
		if (_.isEmpty(countries)) return

		const initialCountry = RNLocalize.getCountry()
		onCountryValueChange(initialCountry)
	}, [countries])

	// useEffect(() => {
	// 	QuickActions.popInitialAction()
	// 		.then(console.warn)
	// 		.catch(console.error)
	// }, [])

	// const [data] = useClipboard()

	const onChangeText = useCallback(
		(value) => {
			const mask = [
				'+',
				..._.split(selectedCountry.callingCodes[0], ''),
				' ',
				...BASE_TEXT_INPUT_MASK,
			]

			setPhoneNumber((previousConformedValue) => {
				const { conformedValue } = conformToMask(value, mask, {
					guide: false,
					previousConformedValue,
				})
				return conformedValue
			})
		},
		[selectedCountry],
	)

	const onOpenPress = useCallback(() => {
		const url = `whatsapp://send?phone=${phoneNumber}`

		Linking.openURL(url, {
			appName: 'WhatsApp',
			appStoreId: '310633997',
			appStoreLocale: RNLocalize.getLocales()[0].languageCode,
			playStoreId: 'com.whatsapp',
		})
			.then(() => {
				// do stuff
				console.warn('ok?')
			})
			.catch((err) => {
				console.warn(err)
			})
	}, [phoneNumber])

	if (!selectedCountry) return <ActivityIndicator size="large" />

	const countryText = getLabelFromCountry(selectedCountry)

	const placeholder = `+${selectedCountry.callingCodes[0]}`

	return (
		<>
			<View
				style={[
					styles.container,
					{
						backgroundColor: Platform.select({
							android: 'transparent',
							ios: theme.colors.card,
						}),
						borderTopColor: theme.colors.border,
						borderBottomColor: theme.colors.border,
					},
				]}
			>
				<RectButton
					onPress={() => {
						setPickerVisible((prevState) => !prevState)
					}}
					style={[styles.countryContainer]}
				>
					<Text style={{ color: theme.colors.text }}>Country</Text>
					<View
						style={{
							flex: 1,
							flexDirection: 'row',
							justifyContent: 'flex-end',
						}}
					>
						<Text
							style={[
								styles.countryText,
								{ color: theme.colors.border },
							]}
						>
							{countryText}
						</Text>
						<PlatformIcon
							color={theme.colors.border}
							name="arrow-forward"
							size={16}
						/>
					</View>
				</RectButton>

				{isPickerVisible && (
					<Picker
						selectedValue={selectedCountry.alpha2Code}
						isVisible={isPickerVisible}
						onValueChange={onCountryValueChange}
					>
						{_.map(countries, CountryPickerItem)}
					</Picker>
				)}

				<View
					style={[
						styles.separator,
						{ borderBottomColor: theme.colors.border },
					]}
				/>

				<View style={[styles.textInputContainer]}>
					<Text
						style={[
							styles.textInputLabel,
							{ color: theme.colors.text },
						]}
					>
						Phone number
					</Text>
					<TextInput
						blurOnSubmit
						enablesReturnKeyAutomatically
						autoCompleteType="tel"
						// defaultValue={data}
						clearButtonMode="while-editing"
						keyboardType="phone-pad"
						placeholder={placeholder}
						placeholderTextColor={Platform.select({
							android: theme.colors.text,
						})}
						onChangeText={onChangeText}
						returnKeyType="done"
						style={styles.textInput}
						textContentType="telephoneNumber"
						underlineColorAndroid={theme.colors.primary}
						value={phoneNumber}
					/>
				</View>
			</View>

			<BorderlessButton
				onPress={onOpenPress}
				style={{ margin: 16, alignSelf: 'center' }}
			>
				<Text style={[human.callout, { color: theme.colors.primary }]}>
					Open In WhatsApp
				</Text>
			</BorderlessButton>
		</>
	)
}

const Welcome = ({ ...props }) => {
	const onRestartPress = useCallback(() => {
		RNRestart.Restart()
	}, [])

	return (
		<ScrollView
			contentInsetAdjustmentBehavior="automatic"
			style={styles.scrollContainer}
		>
			<Form />

			<Button title="Restart" onPress={onRestartPress} />
		</ScrollView>
	)
}

Welcome.options = {
	title: 'WhatsAdd',
	headerRight: renderHeaderRight,
}

const styles = StyleSheet.create({
	scrollContainer: {
		padding: 16,
	},
	picker: {
		marginHorizontal: -16,
	},
	container: {
		marginHorizontal: -16,
		borderTopWidth: StyleSheet.hairlineWidth,
		borderBottomWidth: StyleSheet.hairlineWidth,
	},
	countryContainer: {
		flexDirection: 'row',
		padding: 16,
	},
	countryText: {
		marginEnd: 16,
	},
	separator: {
		borderBottomWidth: StyleSheet.hairlineWidth,
		marginStart: 16,
	},
	textInputContainer: {
		flexDirection: 'row',
		padding: 16,
	},
	textInputLabel: { marginEnd: 16 },
	textInput: { flex: 1 },
})

export { Welcome }
