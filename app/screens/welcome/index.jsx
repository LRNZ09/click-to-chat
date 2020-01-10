import { Picker } from '@react-native-community/picker'
import { useTheme } from '@react-navigation/native'
import axios from 'axios'
import _ from 'lodash'
import React, { useCallback, useEffect, useState } from 'react'
import {
	ActivityIndicator,
	Button,
	DeviceEventEmitter,
	Linking,
	Platform,
	ScrollView,
	StyleSheet,
	Text,
	TextInput,
	View,
} from 'react-native'
import { BorderlessButton, RectButton } from 'react-native-gesture-handler'
import * as RNLocalize from 'react-native-localize'
import RNRestart from 'react-native-restart'
import { human } from 'react-native-typography'
import { conformToMask } from 'text-mask-core'

import { PlatformIcon } from '../../components'

import { More } from './more'

const getBaseTextInputMask = () => {
	const numbers = Array.from({ length: 3 }, () => /\d/u)

	const space = ' '

	const mask = Array.from({ length: 5 }, () => [...numbers, space])
		.flat()

	mask.pop()

	return mask
}

const BASE_TEXT_INPUT_MASK = getBaseTextInputMask()

const UNICODE_BASE = 127462 - 'A'.charCodeAt()

DeviceEventEmitter.addListener('quickActionShortcut', (/* data */) => {
	// Console.warn({ data })
})

const renderHeaderRight = () => <More />

const getCodePointFromChar = (char) => UNICODE_BASE + char.charCodeAt()

const getFlagFromAlpha2Code = (alpha2Code) => {
	const codePoints = _.map(alpha2Code, getCodePointFromChar)

	return String.fromCodePoint(...codePoints)
}

const getLabelFromCountry = (country) => {
	const flag = getFlagFromAlpha2Code(country.alpha2Code)

	// eslint-disable-next-line no-irregular-whitespace
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

const styles = StyleSheet.create({
	container: {
		borderBottomWidth: StyleSheet.hairlineWidth,
		borderTopWidth: StyleSheet.hairlineWidth,
		marginHorizontal: -16,
	},
	countryButton: {
		flexDirection: 'row',
		padding: 16,
	},
	countryContainer: {
		flex: 1,
		flexDirection: 'row',
		justifyContent: 'flex-end',
	},
	countryText: {
		marginEnd: 16,
	},
	scrollContainer: {
		padding: 16,
	},
	separator: {
		borderBottomWidth: StyleSheet.hairlineWidth,
		marginStart: 16,
	},
	textInput: { flex: 1 },
	textInputContainer: {
		flexDirection: 'row',
		padding: 16,
	},
	textInputLabel: { marginEnd: 16 },
})

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
		fetchCountriesData()
			.then(setCountries)
	}, [])

	useEffect(() => {
		if (_.isEmpty(countries)) return

		const initialCountry = RNLocalize.getCountry()

		onCountryValueChange(initialCountry)
	}, [countries, onCountryValueChange])

	/* UseEffect(() => {
	   	QuickActions.popInitialAction()
	   		.then(console.warn)
	   		.catch(console.error)
	   }, []) */

	// Const [data] = useClipboard()

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

		/* {
		   	appName: 'WhatsApp',
		   	appStoreId: '310633997',
		   	appStoreLocale: RNLocalize.getLocales()[0].languageCode,
		   	playStoreId: 'com.whatsapp',
		   } */

		Linking.openURL(url)
	}, [phoneNumber])

	const onCountryPress = useCallback(() => {
		setPickerVisible((prevState) => !prevState)
	}, [])

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
						borderBottomColor: theme.colors.border,
						borderTopColor: theme.colors.border,
					},
				]}
			>
				<RectButton
					onPress={onCountryPress}
					style={styles.countryButton}
				>
					<Text style={{ color: theme.colors.text }}>
						Country
					</Text>
					<View style={styles.countryContainer}>
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
						isVisible={isPickerVisible}
						onValueChange={onCountryValueChange}
						selectedValue={selectedCountry.alpha2Code}
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

				<View style={styles.textInputContainer}>
					<Text
						style={[
							styles.textInputLabel,
							{ color: theme.colors.text },
						]}
					>
						Phone number
					</Text>
					<TextInput
						autoCompleteType="tel"
						blurOnSubmit
						clearButtonMode="while-editing"
						enablesReturnKeyAutomatically
						keyboardType="phone-pad"
						onChangeText={onChangeText}
						placeholder={placeholder}
						placeholderTextColor={Platform.select({
							android: theme.colors.text,
						})}
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
			>
				<Text style={[human.callout, { color: theme.colors.primary }]}>
					Open In WhatsApp
				</Text>
			</BorderlessButton>
		</>
	)
}

const Welcome = () => {
	const onRestartPress = useCallback(() => {
		// eslint-disable-next-line new-cap
		RNRestart.Restart()
	}, [])

	return (
		<ScrollView
			contentInsetAdjustmentBehavior="automatic"
			style={styles.scrollContainer}
		>
			<Form />

			<Button
				onPress={onRestartPress}
				title="Restart"
			/>
		</ScrollView>
	)
}

Welcome.options = {
	headerRight: renderHeaderRight,
	title: 'WhatsAdd',
}

export { Welcome }
