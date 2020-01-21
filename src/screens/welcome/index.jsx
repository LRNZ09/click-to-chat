/** @format */

import { useTheme } from '@react-navigation/native'
import axios from 'axios'
import * as FacebookAds from 'expo-ads-facebook'
import _ from 'lodash'
import React, { useCallback, useEffect, useState } from 'react'
import {
	ActivityIndicator,
	Alert,
	DeviceEventEmitter,
	Linking,
	Platform,
	ScrollView,
	StyleSheet,
	Text,
	TextInput,
	View,
	Picker,
} from 'react-native'
import { BorderlessButton, RectButton } from 'react-native-gesture-handler'
import { SafeAreaView } from 'react-native-safe-area-context'
import { human } from 'react-native-typography'
import styled from 'styled-components/native'
import { conformToMask } from 'text-mask-core'

import { PlatformIcon } from '../../components/platform-icon'

import { More } from './more'

const ThemedText = styled.Text(({ theme }) => ({
	color: theme.colors.text,
}))

const getBaseTextInputMask = () => {
	const numbers = Array.from({ length: 3 }, () => /\d/u)

	const space = ' '

	const mask = Array.from({ length: 5 }, () => [...numbers, space]).flat()

	mask.pop()

	return mask
}

const BASE_TEXT_INPUT_MASK = getBaseTextInputMask()

const UNICODE_BASE = 127462 - 'A'.charCodeAt(0)

DeviceEventEmitter.addListener('quickActionShortcut', (/* data */) => {
	// Console.warn({ data })
})

const renderHeaderRight = () => <More />

const getCodePointFromChar = (char) => UNICODE_BASE + char.charCodeAt(0)

const getFlagFromAlpha2Code = (alpha2Code) => {
	const codePoints = _.map(alpha2Code, getCodePointFromChar)

	return String.fromCodePoint(...codePoints)
}

const getLabelFromCountry = (country) => {
	const flag = getFlagFromAlpha2Code(country.alpha2Code)

	return `${country.nativeName} ${flag}`
}

const CountryPickerItem = (country) => {
	const label = getLabelFromCountry(country)

	return <Picker.Item key={country.alpha2Code} label={label} value={country.alpha2Code} />
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
			.catch(console.error)
	}, [])

	useEffect(() => {
		if (_.isEmpty(countries)) return

		const initialCountry = 'IT' // Localization.getCountry()

		onCountryValueChange(initialCountry)
	}, [countries, onCountryValueChange])

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

	const onOpenPress = useCallback(async () => {
		const url = `whatsapp://send?phone=${phoneNumber}`

		/* {
		   	appName: 'WhatsApp',
		   	appStoreId: '310633997',
		   	appStoreLocale: Localization.getLocales()[0].languageCode,
		   	playStoreId: 'com.whatsapp',
		   } */

		try {
			if (await Linking.canOpenURL(url)) await Linking.openURL(url)
		} catch (error) {
			console.warn(error)
		}

		Alert.alert('TODO', 'Cannot open URL')
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
				<RectButton onPress={onCountryPress} style={styles.countryButton}>
					<ThemedText>Country</ThemedText>
					<View style={styles.countryContainer}>
						<Text style={[styles.countryText, { color: theme.colors.border }]}>
							{countryText}
						</Text>
						<PlatformIcon color={theme.colors.border} name="arrow-forward" size={16} />
					</View>
				</RectButton>

				{isPickerVisible && (
					<Picker
						onValueChange={onCountryValueChange}
						selectedValue={selectedCountry.alpha2Code}
					>
						{_.map(countries, CountryPickerItem)}
					</Picker>
				)}

				<View style={[styles.separator, { borderBottomColor: theme.colors.border }]} />

				<View style={styles.textInputContainer}>
					<ThemedText style={styles.textInputLabel}>Phone number</ThemedText>
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

			<BorderlessButton onPress={onOpenPress}>
				<Text style={[human.callout, { color: theme.colors.primary }]}>
					Open In WhatsApp
				</Text>
			</BorderlessButton>
		</>
	)
}

const adsManager = new FacebookAds.NativeAdsManager('763053297519162_763065954184563', 1)
const { AdIconView, AdMediaView, AdTriggerView } = FacebookAds

const TestAd = (props) => (
	<View style={{ padding: 16 }}>
		<AdIconView />
		<AdTriggerView>
			<ThemedText>advertiserName: {props.nativeAd.advertiserName}</ThemedText>
			<ThemedText>headline: {props.nativeAd.headline}</ThemedText>
			<ThemedText>linkDescription: {props.nativeAd.linkDescription}</ThemedText>
			<ThemedText>adTranslation: {props.nativeAd.adTranslation}</ThemedText>
			<ThemedText>promotedTranslation: {props.nativeAd.promotedTranslation}</ThemedText>
			<ThemedText>sponsoredTranslation: {props.nativeAd.sponsoredTranslation}</ThemedText>
			<ThemedText>bodyText: {props.nativeAd.bodyText}</ThemedText>
			<ThemedText>callToActionText: {props.nativeAd.callToActionText}</ThemedText>
			<ThemedText>socialContext: {props.nativeAd.socialContext}</ThemedText>
		</AdTriggerView>
		<AdMediaView />
	</View>
)
const NativeTestAd = FacebookAds.withNativeAd(TestAd)

const Welcome = () => (
	<>
		<ScrollView contentInsetAdjustmentBehavior="automatic" style={styles.scrollContainer}>
			<Form />
		</ScrollView>

		<SafeAreaView
			style={{
				position: 'absolute',
				bottom: 0,
			}}
		>
			{/* <FacebookAds.BannerAd
				placementId="763053297519162_763060940851731"
				type="large"
				onPress={() => console.warn('clicked')}
				onError={(error) => console.warn(error)}
			/> */}
			<NativeTestAd adsManager={adsManager} />
		</SafeAreaView>
	</>
)

Welcome.options = {
	headerRight: renderHeaderRight,
	title: 'WhatsAdd',
}

export { Welcome }
