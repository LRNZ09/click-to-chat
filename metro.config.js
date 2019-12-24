/**
 * Metro configuration for React Native
 * https://github.com/facebook/react-native
 *
 * @format
 */

const { getDefaultConfig } = require('metro-config')

module.exports = (async () => {
	const config = await getDefaultConfig()

	return {
		resolver: {
			sourceExts: [...config.resolver.sourceExts, 'jsx'],
		},
		transformer: {
			getTransformOptions: () => ({
				transform: {
					experimentalImportSupport: false,
					inlineRequires: false,
				},
			}),
		},
	}
})()
