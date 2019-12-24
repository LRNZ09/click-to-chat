/** @format */

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
				options: ['Donate', 'About', 'Cancel'],
				cancelButtonIndex: 2,
				title: 'Show Action Sheet With Options Title',
				message: 'showActionSheetWithOptions Message',
			},
			onActionSheetOptionPress,
		)
	}, [onActionSheetOptionPress, showActionSheetWithOptions])

	return (
		<>
			<BorderlessButton
				style={Platform.select({
					android: { marginStart: 24, marginEnd: 16, padding: 6 },
				})}
				onPress={onPress}
			>
				<PlatformIcon name="more" size={24} />
			</BorderlessButton>
		</>
	)
}

export { More }
