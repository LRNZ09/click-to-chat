import { useActionSheet } from '@expo/react-native-action-sheet'
import React, { useCallback } from 'react'
import { Alert, Platform } from 'react-native'
import { BorderlessButton } from 'react-native-gesture-handler'

import { PlatformIcon } from '../../components'

const More = () => {
	const { showActionSheetWithOptions } = useActionSheet()

	const onActionSheetOptionPress = useCallback((buttonIndex) => {
		if (buttonIndex === 1) Alert.alert('About', 'TODO')
	}, [])

	const onPress = useCallback(() => {
		// whatsapp://send?phone=+393519061996

		showActionSheetWithOptions(
			{
				cancelButtonIndex: 2,
				message: 'showActionSheetWithOptions Message',
				options: ['Donate', 'About', 'Cancel'],
				title: 'Show Action Sheet With Options Title',
			},
			onActionSheetOptionPress,
		)
	}, [onActionSheetOptionPress, showActionSheetWithOptions])

	return (
		<BorderlessButton
			onPress={onPress}
			style={Platform.select({
				android: { marginEnd: 16, marginStart: 24, padding: 6 },
			})}
		>
			<PlatformIcon
				name="more"
				size={24}
			/>
		</BorderlessButton>
	)
}

export { More }
