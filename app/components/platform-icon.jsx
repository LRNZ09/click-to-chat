import React from 'react'
import Icon from 'react-native-vector-icons/Ionicons'
import { useTheme } from '@react-navigation/native'
import { Platform } from 'react-native'

Icon.loadFont()

const PlatformIcon = ({ name, ...props }) => {
	const theme = useTheme()

	const platformName = Platform.select({
		android: `md-${name}`,
		ios: `ios-${name}`,
	})

	return (
		<Icon
			color={theme.colors.text}
			// eslint-disable-next-line react/jsx-props-no-spreading
			{...props}
			name={platformName}
		/>)
}

export { PlatformIcon }
