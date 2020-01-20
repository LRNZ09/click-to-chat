/** @format */

import PropTypes from 'prop-types'
import React from 'react'
import { Ionicons as Icon } from '@expo/vector-icons'
import { useTheme } from '@react-navigation/native'
import { Platform } from 'react-native'

const PlatformIcon = (props) => {
	const theme = useTheme()

	const { color = theme.colors.text, name, size } = props

	const platformName = Platform.select({
		android: `md-${name}`,
		ios: `ios-${name}`,
	})

	return <Icon color={color} name={platformName} size={size} />
}

PlatformIcon.propTypes = {
	...Icon.propTypes,
	name: PropTypes.string.isRequired,
}

export { PlatformIcon }
