/** @format */

import { useTheme } from '@react-navigation/native'
import React from 'react'
import { Platform } from 'react-native'
import Icon from 'react-native-vector-icons/Ionicons'

Icon.loadFont()

const PlatformIcon = ({ name, ...props }) => {
	const theme = useTheme()

	const platformName = Platform.select({
		android: `md-${name}`,
		ios: `ios-${name}`,
	})

	return <Icon color={theme.colors.text} {...props} name={platformName} />
}

export { PlatformIcon }
