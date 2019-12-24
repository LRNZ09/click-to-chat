/** @format */

module.exports = {
	extends: [
		'@react-native-community',
		'eslint:recommended',
		'plugin:prettier/recommended',
	],
	root: true,
	rules: {
		'prettier/prettier': 'error',
		'react-native/no-color-literals': 'error',
		'react-native/no-inline-styles': 'error',
		'react-native/no-raw-text': 'error',
		'react-native/no-unused-styles': 'error',
		'react-native/split-platform-components': 'warn',
	},
}
