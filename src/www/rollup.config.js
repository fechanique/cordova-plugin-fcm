const nodeResolve = require('rollup-plugin-node-resolve')
const commonjs = require('rollup-plugin-commonjs')

export default {
    input: '../../www/tmp/index.js',
    output: {
        file: '../../www/FCMPlugin.js',
        format: 'cjs',
        name: 'FCM',
        globals: {}
    },
    plugins: [
        commonjs({
            include: 'node_modules/**'
        }),
        nodeResolve({ browser: true })
    ],
    external: []
}
