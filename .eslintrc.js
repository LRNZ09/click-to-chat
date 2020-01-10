module.exports = {
	env: {
		'react-native/react-native': true,
	},
	extends: [
		'@lrnz09',
		'plugin:react/all',
		'plugin:react-native/all',
		'plugin:import/recommended',
		'plugin:import/react',
		'plugin:import/react-native',
		'plugin:import/typescript',
	],
	root: true,
	rules: {
		// Import
		'import/order': [
			'error',
			{
				// alphabetize: { order: 'asc' },
				'newlines-between': 'always'
			},
		],

		// React
		'react/prop-types': 'off',
		'react/no-multi-comp': ['warn', { ignoreStateless: true }],
		'react/jsx-max-depth': ['warn', { max: 5 }],
		'react/jsx-indent': [
			'error',
			'tab',
			{ checkAttributes: true, indentLogicalExpressions: true },
		],
		'react/jsx-indent-props': ['error', 'tab'],

		// React Native
		// * FIXME false positive for style prop on RN
		'react/forbid-component-props': ['warn', { forbid: ['className'] }],
	},
	settings: {
		'import/ignore': [
			'@react-native-community/picker',
			'react-native-gesture-handler',
		],
		react: {
			version: 'detect',
		},
	},
}
