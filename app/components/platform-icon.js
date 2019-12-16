/** @format */

import React from 'react'
import {Platform} from 'react-native'
import Icon from 'react-native-vector-icons/Ionicons'

Icon.loadFont()

const PlatformIcon = ({name, ...props}) => {
	const platformName = Platform.select({
		android: `md-${name}`,
		ios: `ios-${name}`,
	})

	return <Icon {...props} name={platformName} />
}

export {PlatformIcon}
