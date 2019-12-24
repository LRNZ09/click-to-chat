/** @format */

module.exports = {
	env: {
		'react-native/react-native': true,
	},
	extends: [
		'@react-native-community',
		'eslint:all',
		'plugin:react/all',
		'plugin:react-native/all',
		'plugin:prettier/recommended',
	],
	parserOptions: {
		ecmaFeatures: {
			jsx: true,
		},
	},
	root: true,
	rules: {
		'prettier/prettier': 'error',
	},
}
